//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common

protocol VirologyTestingStateCoordinating {
    var virologyTestTokens: [VirologyTestTokens] { get }
    var didReceiveUnknownTestResult: Bool { get }
    var country: () -> Country { get }

    func saveOrderTestKitResponse(_ orderTestKitResponse: OrderTestkitResponse)
    func handlePollingTestResult(_ testResult: VirologyTestResponse, virologyTestTokens: VirologyTestTokens)
    func handlePollingUnknownTestResult(_ virologyTestTokens: VirologyTestTokens)
    func handleManualTestResult(_ testResult: LinkVirologyTestResultResponse)
    func handleUnknownTestResult()
    func acknowledgeUnknownTestResult()
}

class VirologyTestingStateCoordinator: VirologyTestingStateCoordinating {

    var virologyTestTokens: [VirologyTestTokens] {
        virologyTestingStateStore.virologyTestTokens ?? []
    }
    var didReceiveUnknownTestResult: Bool {
        get {
            virologyTestingStateStore.didReceiveUnknownTestResult
        }
        set {
            virologyTestingStateStore.didReceiveUnknownTestResult = newValue
        }
    }

    var country: () -> Country

    private let virologyTestingStateStore: VirologyTestingStateStore
    private let userNotificationsManager: UserNotificationManaging
    private let isInterestedInAskingForSymptomsOnsetDay: () -> Bool
    private var setRequiresOnsetDay: () -> Void

    init(virologyTestingStateStore: VirologyTestingStateStore, userNotificationsManager: UserNotificationManaging, isInterestedInAskingForSymptomsOnsetDay: @escaping () -> Bool, setRequiresOnsetDay: @escaping () -> Void, country: @escaping () -> Country) {
        self.virologyTestingStateStore = virologyTestingStateStore
        self.userNotificationsManager = userNotificationsManager
        self.isInterestedInAskingForSymptomsOnsetDay = isInterestedInAskingForSymptomsOnsetDay
        self.setRequiresOnsetDay = setRequiresOnsetDay
        self.country = country
    }

    func saveOrderTestKitResponse(_ orderTestKitResponse: OrderTestkitResponse) {
        virologyTestingStateStore.saveTest(
            pollingToken: orderTestKitResponse.testResultPollingToken,
            diagnosisKeySubmissionToken: orderTestKitResponse.diagnosisKeySubmissionToken
        )
    }

    func handlePollingTestResult(
        _ testResult: VirologyTestResponse,
        virologyTestTokens: VirologyTestTokens
    ) {
        switch testResult {
        case .receivedResult(let response):
            virologyTestingStateStore.removeTestTokens(virologyTestTokens)
            Metrics.signpostReceivedViaPolling(
                testResult: response.virologyTestResult.testResult,
                testKitType: response.virologyTestResult.testKitType,
                requiresConfirmatoryTest: response.requiresConfirmatoryTest
            )
            handleWithNotification(
                response.virologyTestResult,
                diagnosisKeySubmissionToken: response.diagnosisKeySubmissionSupport ? virologyTestTokens.diagnosisKeySubmissionToken : nil,
                requiresConfirmatoryTest: response.requiresConfirmatoryTest,
                shouldOfferFollowUpTest: response.shouldOfferFollowUpTest,
                confirmatoryDayLimit: response.confirmatoryDayLimit
            )
        case .noResultYet:
            return
        }
    }

    func handlePollingUnknownTestResult(
        _ virologyTestTokens: VirologyTestTokens
    ) {
        virologyTestingStateStore.removeTestTokens(virologyTestTokens)
        // metrics tbd
        sendNotification()
        handleUnknownTestResult()
    }

    func handleManualTestResult(_ response: LinkVirologyTestResultResponse) {
        Metrics.signpostReceivedFromManual(
            testResult: response.virologyTestResult.testResult,
            testKitType: response.virologyTestResult.testKitType,
            requiresConfirmatoryTest: response.requiresConfirmatoryTest
        )
        switch response.diagnosisKeySubmissionSupport {
        case .supported(let token):
            handle(
                response.virologyTestResult,
                diagnosisKeySubmissionToken: token,
                requiresConfirmatoryTest: response.requiresConfirmatoryTest,
                shouldOfferFollowUpTest: response.shouldOfferFollowUpTest,
                confirmatoryDayLimit: response.confirmatoryDayLimit,
                askForOnsetDay: true
            )
        case .notSupported:
            handle(
                response.virologyTestResult,
                diagnosisKeySubmissionToken: nil,
                requiresConfirmatoryTest: response.requiresConfirmatoryTest,
                shouldOfferFollowUpTest: response.shouldOfferFollowUpTest,
                confirmatoryDayLimit: response.confirmatoryDayLimit,
                askForOnsetDay: true
            )
        }
    }

    func handleUnknownTestResult() {
        virologyTestingStateStore.didReceiveUnknownTestResult = true
    }

    func acknowledgeUnknownTestResult() {
        virologyTestingStateStore.didReceiveUnknownTestResult = false
    }

    func requiresOnsetDay(_ result: VirologyTestResult, requiresConfirmatoryTest: Bool) -> Bool {
        guard requiresConfirmatoryTest == false else {
            return false
        }
        guard result.testKitType == .labResult || ((result.testKitType == .rapidSelfReported || result.testKitType == .rapidResult) && country() == .wales) else {
            return false
        }
        guard result.testResult == .positive else {
            return false
        }

        return isInterestedInAskingForSymptomsOnsetDay()
    }

    private func handleWithNotification(
        _ result: VirologyTestResult,
        diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken?,
        requiresConfirmatoryTest: Bool,
        shouldOfferFollowUpTest: Bool,
        confirmatoryDayLimit: Int?
    ) {
        sendNotification()
        handle(
            result,
            diagnosisKeySubmissionToken: diagnosisKeySubmissionToken,
            requiresConfirmatoryTest: requiresConfirmatoryTest,
            shouldOfferFollowUpTest: shouldOfferFollowUpTest,
            confirmatoryDayLimit: confirmatoryDayLimit,
            askForOnsetDay: false
        )
    }

    private func handle(
        _ result: VirologyTestResult,
        diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken?,
        requiresConfirmatoryTest: Bool,
        shouldOfferFollowUpTest: Bool,
        confirmatoryDayLimit: Int?,
        askForOnsetDay: Bool
    ) {
        virologyTestingStateStore.saveResult(
            virologyTestResult: result,
            diagnosisKeySubmissionToken: result.testResult == .positive ? diagnosisKeySubmissionToken : nil,
            requiresConfirmatoryTest: requiresConfirmatoryTest,
            shouldOfferFollowUpTest: shouldOfferFollowUpTest,
            confirmatoryDayLimit: confirmatoryDayLimit
        )
        if askForOnsetDay, requiresOnsetDay(result, requiresConfirmatoryTest: requiresConfirmatoryTest) {
            setRequiresOnsetDay()
        }
    }

    private func sendNotification() {
        userNotificationsManager.add(type: .testResultReceived, at: nil, withCompletionHandler: nil)
    }

}
