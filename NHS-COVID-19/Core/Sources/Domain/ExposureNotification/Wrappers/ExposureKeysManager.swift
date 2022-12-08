//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import ExposureNotification
import Foundation
import UserNotifications

struct ExposureKeysManager {
    enum KeySharerResult {
        case markInitialFlowComplete
        case markToDelete

        init(
            result: DiagnosisKeySharer.ShareResult,
            flowType: DiagnosisKeySharer.ShareFlowType,
            acknowledgementTime: Date,
            currentDateProvider: DateProviding
        ) {
            switch result {
            case .sent:
                self = .markToDelete
            case .notSent:
                switch flowType {
                case .reminder:
                    self = .markToDelete
                case .initial:
                    let twentyFourHours: Double = 24 * 60 * 60
                    if currentDateProvider.currentDate <= acknowledgementTime.advanced(by: twentyFourHours) {
                        self = .markInitialFlowComplete
                    } else {
                        self = .markToDelete
                    }
                }
            }
        }
    }

    var controller: ExposureNotificationDetectionController
    var submissionClient: HTTPClient
    var trafficObfuscationClient: TrafficObfuscationClient
    var contactCaseIsolationDuration: DayDuration
    var currentDateProvider: DateProviding

    init(controller: ExposureNotificationDetectionController,
         submissionClient: HTTPClient,
         trafficObfuscationClient: TrafficObfuscationClient,
         contactCaseIsolationDuration: DayDuration,
         currentDateProvider: DateProviding) {
        self.controller = controller
        self.submissionClient = submissionClient
        self.trafficObfuscationClient = trafficObfuscationClient
        self.contactCaseIsolationDuration = contactCaseIsolationDuration
        self.currentDateProvider = currentDateProvider
    }

    func send(keys: Result<[ENTemporaryExposureKey], Error>?,
              for onsetDay: GregorianDay,
              token: DiagnosisKeySubmissionToken,
              acknowledgementDay: GregorianDay,
              isPrivateJourney: Bool,
              testKitType: TestKitType,
              flowType: DiagnosisKeySharer.ShareFlowType) -> AnyPublisher<Void, Error> {
        let interestedDateRange = TemporaryExposureKey.dateRangeConsideredForUploadIgnoringInfectiousness(
            acknowledgmentDay: acknowledgementDay,
            isolationDuration: contactCaseIsolationDuration,
            today: currentDateProvider.currentGregorianDay(timeZone: .current)
        )
        if let keys = keys {
            switch keys {
            case .success(let temporaryExposureKeys):
                Metrics.signpost(.consentedToShareExposureKeysInTheInitialFlow)
                let tempKeys: [TemporaryExposureKey] = temporaryExposureKeys.map { TemporaryExposureKey(exposureKey: $0, onsetDay: onsetDay) }
                    .filter { $0.transmissionRiskLevel > 0 }
                    .filter { interestedDateRange.contains($0.gregorianDay) }
                return post(token: token, diagnosisKeys: tempKeys, isPrivateJourney: true, testKit: testKitType)
                    .mapError { $0 as Error }
                    .eraseToAnyPublisher()
            case .failure(let error):
                return Fail(error: error).eraseToAnyPublisher()
            }
        } else {
            return controller.getDiagnosisKeys()
                .map { keys in
                    switch flowType {
                    case .initial:
                        Metrics.signpost(.consentedToShareExposureKeysInTheInitialFlow)
                    case .reminder:
                        Metrics.signpost(.consentedToShareExposureKeysInReminderScreen)
                    }

                    return keys.map { TemporaryExposureKey(exposureKey: $0, onsetDay: onsetDay) }
                        .filter { $0.transmissionRiskLevel > 0 }
                        .filter {
                            interestedDateRange.contains($0.gregorianDay)
                        }
                }
                .flatMap {
                    self.post(token: token, diagnosisKeys: $0, isPrivateJourney: isPrivateJourney, testKit: testKitType).mapError { $0 as Error }.eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }
    }

    private func post(
        token: DiagnosisKeySubmissionToken,
        diagnosisKeys: [TemporaryExposureKey],
        isPrivateJourney: Bool,
        testKit: TestKitType
    ) -> AnyPublisher<Void, NetworkRequestError> {
        submissionClient.fetch(
            DiagnosisKeySubmissionEndPoint(token: token, isPrivateJourney: isPrivateJourney, testKit: testKit),
            with: diagnosisKeys
        )
    }

    public func makeDiagnosisKeySharer(
        assumedOnsetDay: GregorianDay,
        currentDateProvider: DateProviding,
        keySharingInfo: DomainProperty<KeySharingInfo?>,
        completionHandler: @escaping (KeySharerResult) -> Void
    ) -> DomainProperty<DiagnosisKeySharer?> {
        keySharingInfo.map {
            $0.map { info in
                DiagnosisKeySharer(
                    hasFinishedInitialKeySharingFlow: info.hasFinishedInitialKeySharingFlow,
                    hasTriggeredReminderNotification: info.hasTriggeredReminderNotification,
                    hasSelfReported: info.privateJourney ?? false,
                    shareKeys: { flowType, keys in
                        self.send(keys: keys,
                                  for: assumedOnsetDay,
                                  token: info.diagnosisKeySubmissionToken,
                                  acknowledgementDay: info.testResultAcknowledgmentTime.day,
                                  isPrivateJourney: info.privateJourney ?? false,
                                  testKitType: info.testKitType ?? .labResult,
                                  flowType: flowType
                        )
                        .map { DiagnosisKeySharer.ShareResult.sent }
                        .replaceEmpty(with: DiagnosisKeySharer.ShareResult.sent)
                        .catch { error -> AnyPublisher<DiagnosisKeySharer.ShareResult, Error> in
                            if (error as NSError).domain == ENErrorDomain {
                                return Result.success(.notSent).publisher.eraseToAnyPublisher()
                            } else {
                                return Fail(error: error).eraseToAnyPublisher()
                            }
                        }
                        .handleEvents(receiveOutput: { result in
                            if case .notSent = result {
                                self.trafficObfuscationClient.sendSingleTraffic(for: TrafficObfuscator.keySubmission)
                            } else if case .sent = result {
                                Metrics.signpost(.successfullySharedExposureKeys)
                            }

                            let keySharerResult = KeySharerResult(
                                result: result,
                                flowType: flowType,
                                acknowledgementTime: info.testResultAcknowledgmentTime.date,
                                currentDateProvider: currentDateProvider
                            )

                            completionHandler(keySharerResult)
                        })
                        .eraseToAnyPublisher()
                    },
                    doNotShareKeys: { flowType in
                        self.trafficObfuscationClient.sendSingleTraffic(for: TrafficObfuscator.keySubmission)

                        let keySharerResult = KeySharerResult(
                            result: .notSent,
                            flowType: flowType,
                            acknowledgementTime: info.testResultAcknowledgmentTime.date,
                            currentDateProvider: currentDateProvider
                        )
                        completionHandler(keySharerResult)
                    }
                )
            }
        }
    }
}

public struct DiagnosisKeySharer {
    public enum ShareResult {
        case sent
        case notSent
    }

    public enum ShareFlowType {
        case initial
        case reminder
    }

    public var hasFinishedInitialKeySharingFlow: Bool
    public var hasTriggeredReminderNotification: Bool
    public var hasSelfReported: Bool
    public var shareKeys: (ShareFlowType, Result<[ENTemporaryExposureKey], Error>?) -> AnyPublisher<ShareResult, Error>
    public var doNotShareKeys: (ShareFlowType) -> Void
}
