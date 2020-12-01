//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common

protocol VirologyTestingStateCoordinating {
    var virologyTestTokens: [VirologyTestTokens] { get }
    
    func saveOrderTestKitResponse(_ orderTestKitResponse: OrderTestkitResponse)
    func handlePollingTestResult(_ testResult: VirologyTestResponse, virologyTestTokens: VirologyTestTokens)
    func handleManualTestResult(_ testResult: LinkVirologyTestResultResponse)
}

class VirologyTestingStateCoordinator: VirologyTestingStateCoordinating {
    var virologyTestTokens: [VirologyTestTokens] {
        virologyTestingStateStore.virologyTestTokens ?? []
    }
    
    private let virologyTestingStateStore: VirologyTestingStateStore
    private let userNotificationsManager: UserNotificationManaging
    
    init(virologyTestingStateStore: VirologyTestingStateStore, userNotificationsManager: UserNotificationManaging) {
        self.virologyTestingStateStore = virologyTestingStateStore
        self.userNotificationsManager = userNotificationsManager
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
        case .receivedResult(let result):
            virologyTestingStateStore.removeTestTokens(virologyTestTokens)
            Metrics.signpostReceivedViaPolling(testResult: result.testResult)
            handleWithNotification(result, diagnosisKeySubmissionToken: virologyTestTokens.diagnosisKeySubmissionToken)
        case .noResultYet:
            return
        }
    }
    
    func handleManualTestResult(_ response: LinkVirologyTestResultResponse) {
        Metrics.signpostReceivedFromManual(testResult: response.virologyTestResult.testResult)
        handle(response.virologyTestResult, diagnosisKeySubmissionToken: response.diagnosisKeySubmissionToken)
    }
    
    private func handleWithNotification(_ result: VirologyTestResult, diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken) {
        sendNotification()
        handle(result, diagnosisKeySubmissionToken: diagnosisKeySubmissionToken)
    }
    
    private func handle(_ result: VirologyTestResult, diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken) {
        virologyTestingStateStore.saveResult(
            virologyTestResult: result,
            diagnosisKeySubmissionToken: result.testResult == .positive ? diagnosisKeySubmissionToken : nil
        )
    }
    
    private func sendNotification() {
        userNotificationsManager.add(type: .testResultReceived, at: nil, withCompletionHandler: nil)
    }
    
}
