//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation

public protocol SymptomsOnsetDateAndExposureDetailsProviding {
    func provideSymptomsOnsetDate() -> Date?
    func provideExposureDetails() -> (encounterDate: Date,
                                      notificationDate: Date)?
}

struct IsolationStateInfo: Codable, Equatable, DataConvertible {
    var isolationInfo: IsolationInfo
    var configuration: IsolationConfiguration
}

class IsolationStateStore: SymptomsOnsetDateAndExposureDetailsProviding {
    enum Operation: Equatable {
        case nothing
        case ignore
        case update
        case overwrite
        case confirm
        case updateAndConfirm
        case overwriteAndConfirm
    }
    
    @Encrypted private var isolationStateInfoStorage: IsolationStateInfo?
    
    private let latestConfiguration: () -> IsolationConfiguration
    private let currentDateProvider: DateProviding
    
    @Published var isolationStateInfo: IsolationStateInfo? {
        didSet {
            isolationStateInfoStorage = isolationStateInfo
        }
    }
    
    var isolationInfo: IsolationInfo {
        isolationStateInfo?.isolationInfo ?? .empty
    }
    
    var configuration: IsolationConfiguration {
        isolationStateInfo?.configuration ?? latestConfiguration()
    }
    
    init(store: EncryptedStoring, latestConfiguration: @escaping () -> IsolationConfiguration, currentDateProvider: DateProviding) {
        self.latestConfiguration = latestConfiguration
        self.currentDateProvider = currentDateProvider
        _isolationStateInfoStorage = store.encrypted("isolation_state_info")
        isolationStateInfo = _isolationStateInfoStorage.wrappedValue
    }
    
    @discardableResult
    func set(_ indexCaseInfo: IndexCaseInfo) -> IsolationLogicalState {
        let isolationInfo = mutating(self.isolationInfo) {
            $0.indexCaseInfo = indexCaseInfo
            $0.hasAcknowledgedEndOfIsolation = false
            $0.hasAcknowledgedStartOfIsolation = true
        }
        
        let logicalState = IsolationLogicalState(today: currentDateProvider.currentLocalDay, info: isolationInfo, configuration: configuration)
        if logicalState.isolation?.isIndexCase == true {
            return save(isolationInfo)
        } else {
            return logicalState
        }
        
    }
    
    @discardableResult
    func set(_ contactCaseInfo: ContactCaseInfo) -> IsolationLogicalState {
        let isolationInfo = mutating(self.isolationInfo) {
            $0.contactCaseInfo = contactCaseInfo
            $0.hasAcknowledgedEndOfIsolation = false
        }
        return save(isolationInfo)
    }
    
    func newIsolationStateInfo(from currentIsolationInfo: IsolationInfo?, for testResult: TestResult, testKitType: TestKitType?, requiresConfirmatoryTest: Bool, receivedOn: GregorianDay, npexDay: GregorianDay, operation: IsolationStateStore.Operation) -> IsolationStateInfo {
        
        let isolationInfo = mutating(currentIsolationInfo ?? .empty) {
            if requiresConfirmatoryTest == false, testResult == .positive, operation != .ignore {
                $0.contactCaseInfo = nil
            }
            
            switch operation {
            case .nothing, .ignore:
                return
            case .update:
                if var indexCaseInfo = $0.indexCaseInfo {
                    indexCaseInfo.set(testResult: testResult, testKitType: testKitType, requiresConfirmatoryTest: requiresConfirmatoryTest, receivedOn: receivedOn)
                    $0.indexCaseInfo = indexCaseInfo
                } else {
                    $0.indexCaseInfo = IndexCaseInfo(
                        isolationTrigger: .manualTestEntry(npexDay: npexDay),
                        onsetDay: nil,
                        testInfo: IndexCaseInfo.TestInfo(result: testResult, testKitType: testKitType, requiresConfirmatoryTest: requiresConfirmatoryTest, receivedOnDay: receivedOn)
                    )
                }
            case .confirm:
                if var indexCaseInfo = $0.indexCaseInfo {
                    indexCaseInfo.confirmTest(confirmationDay: npexDay)
                    $0.indexCaseInfo = indexCaseInfo
                }
            case .overwrite:
                $0.indexCaseInfo = IndexCaseInfo(
                    isolationTrigger: .manualTestEntry(npexDay: npexDay),
                    onsetDay: nil,
                    testInfo: IndexCaseInfo.TestInfo(result: testResult, testKitType: testKitType, requiresConfirmatoryTest: requiresConfirmatoryTest, receivedOnDay: receivedOn)
                )
            case .updateAndConfirm:
                if let storedIndexCaseInfo = $0.indexCaseInfo {
                    var indexCaseInfo = storedIndexCaseInfo
                    indexCaseInfo.set(testResult: testResult, testKitType: testKitType, requiresConfirmatoryTest: requiresConfirmatoryTest, receivedOn: receivedOn)
                    if let confirmedDay = storedIndexCaseInfo.testInfo?.confirmedOnDay ?? $0.indexCaseInfo?.assumedTestEndDay {
                        indexCaseInfo.confirmTest(confirmationDay: confirmedDay)
                    }
                    $0.indexCaseInfo = indexCaseInfo
                } else {
                    var indexCaseInfo = IndexCaseInfo(
                        isolationTrigger: .manualTestEntry(npexDay: npexDay),
                        onsetDay: nil,
                        testInfo: IndexCaseInfo.TestInfo(result: testResult, testKitType: testKitType, requiresConfirmatoryTest: requiresConfirmatoryTest, receivedOnDay: receivedOn)
                    )
                    if let confirmedDay = $0.indexCaseInfo?.testInfo?.confirmedOnDay ?? $0.indexCaseInfo?.assumedTestEndDay {
                        indexCaseInfo.confirmTest(confirmationDay: confirmedDay)
                    }
                    $0.indexCaseInfo = indexCaseInfo
                }
            case .overwriteAndConfirm:
                var indexCaseInfo = IndexCaseInfo(
                    isolationTrigger: .manualTestEntry(npexDay: npexDay),
                    onsetDay: nil,
                    testInfo: IndexCaseInfo.TestInfo(result: testResult, testKitType: testKitType, requiresConfirmatoryTest: requiresConfirmatoryTest, receivedOnDay: receivedOn)
                )
                if let confirmedDay = $0.indexCaseInfo?.testInfo?.confirmedOnDay ?? $0.indexCaseInfo?.assumedTestEndDay {
                    indexCaseInfo.confirmTest(confirmationDay: confirmedDay)
                }
                $0.indexCaseInfo = indexCaseInfo
            }
        }
        return IsolationStateInfo(isolationInfo: isolationInfo, configuration: configuration)
    }
    
    func acknowldegeEndOfIsolation() {
        let isolationInfo = mutating(self.isolationInfo) {
            $0.hasAcknowledgedEndOfIsolation = true
        }
        _ = save(isolationInfo)
    }
    
    func acknowldegeStartOfIsolation() {
        let isolationInfo = mutating(self.isolationInfo) {
            $0.hasAcknowledgedStartOfIsolation = true
        }
        _ = save(isolationInfo)
    }
    
    func restartIsolationAcknowledgement() {
        let isolationInfo = mutating(self.isolationInfo) {
            $0.hasAcknowledgedStartOfIsolation = true
            $0.hasAcknowledgedEndOfIsolation = false
        }
        _ = save(isolationInfo)
    }
    
    private func save(_ isolationInfo: IsolationInfo) -> IsolationLogicalState {
        let configuration = self.configuration
        isolationStateInfo = IsolationStateInfo(
            isolationInfo: isolationInfo,
            configuration: configuration
        )
        
        return IsolationLogicalState(today: currentDateProvider.currentLocalDay, info: isolationInfo, configuration: configuration)
    }
    
    func provideExposureDetails() -> (encounterDate: Date,
                                      notificationDate: Date)? {
        guard let encounterDay = isolationInfo.contactCaseInfo?.exposureDay,
            let notificationDay = isolationInfo.contactCaseInfo?.isolationFromStartOfDay else {
            return nil
        }
        return (
            encounterDate: LocalDay(gregorianDay: encounterDay, timeZone: .current).startOfDay,
            notificationDate: LocalDay(gregorianDay: notificationDay, timeZone: .current).startOfDay
        )
    }
    
    func provideSymptomsOnsetDate() -> Date? {
        if let onsetDay = isolationInfo.indexCaseInfo?.onsetDay {
            return LocalDay(gregorianDay: onsetDay, timeZone: .current).startOfDay
        }
        
        if case .selfDiagnosis(let selfDiagnosisDay) = isolationInfo.indexCaseInfo?.isolationTrigger {
            // onsetDay = selfDiagnosisDay - 2
            let selfDiagnosisDate = LocalDay(gregorianDay: selfDiagnosisDay, timeZone: .current).startOfDay
            return Calendar.current.date(byAdding: DateComponents(day: -2), to: selfDiagnosisDate)!
        }
        
        return nil
    }
    
    func recordMetrics() -> AnyPublisher<Void, Never> {
        if isolationStateInfo?.isolationInfo.contactCaseInfo != nil {
            Metrics.signpost(.contactCaseBackgroundTick)
        }
        if let indexCaseInfo = isolationStateInfo?.isolationInfo.indexCaseInfo {
            Metrics.signpost(.indexCaseBackgroundTick)
            if indexCaseInfo.testInfo?.result == .positive {
                if let testKit = indexCaseInfo.testInfo?.testKitType {
                    switch testKit {
                    case .labResult:
                        Metrics.signpost(.testedPositiveBackgroundTick)
                    case .rapidResult:
                        Metrics.signpost(.hasTestedLFDPositiveBackgroundTick)
                    case .rapidSelfReported:
                        Metrics.signpost(.hasTestedSelfRapidPositiveBackgroundTick)
                    }
                } else {
                    Metrics.signpost(.testedPositiveBackgroundTick)
                }
            }
            if case .selfDiagnosis = indexCaseInfo.isolationTrigger {
                Metrics.signpost(.selfDiagnosedBackgroundTick)
            }
        }
        
        return Empty().eraseToAnyPublisher()
    }
}
