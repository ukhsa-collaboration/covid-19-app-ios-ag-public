//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation

public protocol VirologyTestingTestOrderInfoProviding {
    func provideTestOrderInfo() -> AnyPublisher<TestOrderInfo, NetworkRequestError>
    func provideTestResult() -> (TestResult, Date)?
}

class VirologyTestingManager: VirologyTestingTestOrderInfoProviding {
    
    private let httpClient: HTTPClient
    private let virologyTestingStateStore: VirologyTestingStateStore
    private let userNotificationsManager: UserNotificationManaging
    private let updateIsolationState: (TestResult, GregorianDay) -> Void
    
    init(
        httpClient: HTTPClient,
        virologyTestingStateStore: VirologyTestingStateStore,
        userNotificationsManager: UserNotificationManaging,
        updateIsolationState: @escaping (TestResult, GregorianDay) -> Void
    ) {
        self.httpClient = httpClient
        self.virologyTestingStateStore = virologyTestingStateStore
        self.userNotificationsManager = userNotificationsManager
        self.updateIsolationState = updateIsolationState
    }
    
    var virologyTestTokens: [VirologyTestTokens]? {
        virologyTestingStateStore.virologyTestTokens
    }
    
    func provideTestOrderInfo() -> AnyPublisher<TestOrderInfo, NetworkRequestError> {
        orderTestkit()
            .map { response in
                TestOrderInfo(testOrderWebsiteURL: response.testOrderWebsite, referenceCode: response.referenceCode)
            }.eraseToAnyPublisher()
    }
    
    func provideTestResult() -> (TestResult, Date)? {
        virologyTestingStateStore.latestUnacknowledgedTestResult.map { ($0.testResult, $0.endDate) }
    }
    
    func orderTestkit() -> AnyPublisher<OrderTestkitResponse, NetworkRequestError> {
        httpClient.fetch(OrderTestkitEndpoint())
            .handleEvents(receiveOutput: saveOrderTestKitResponse)
            .eraseToAnyPublisher()
    }
    
    func saveOrderTestKitResponse(_ orderTestKitResponse: OrderTestkitResponse) {
        virologyTestingStateStore.saveTest(
            pollingToken: orderTestKitResponse.testResultPollingToken,
            diagnosisKeySubmissionToken: orderTestKitResponse.diagnosisKeySubmissionToken
        )
    }
    
    func evaulateTestResults() -> AnyPublisher<Void, Never> {
        if let virologyTestTokens = virologyTestingStateStore.virologyTestTokens {
            return Publishers.Sequence<[AnyPublisher<VirologyTestResponse, NetworkRequestError>], NetworkRequestError>(
                sequence: virologyTestTokens.map { tokens in
                    httpClient.fetch(VirologyTestResultEndpoint(), with: tokens.pollingToken)
                        .handleEvents(receiveOutput: { response in
                            self.handleTestResult(
                                response,
                                virologyTestTokens: tokens
                            )
                        })
                        .eraseToAnyPublisher()
                })
                .flatMap { $0 }
                .map { _ in
                    ()
                }
                .replaceError(with: ())
                .eraseToAnyPublisher()
            
        }
        return Empty().eraseToAnyPublisher()
    }
    
    private func handleTestResult(
        _ testResult: VirologyTestResponse,
        virologyTestTokens: VirologyTestTokens
    ) {
        switch testResult {
        case .receivedResult(let result):
            virologyTestingStateStore.removeTestTokens(virologyTestTokens)
            switch result.testResult {
            case .positive:
                Metrics.signpost(.receivedPositiveTestResult)
                handlePositiveCase(result: result, diagnosisKeySubmissionToken: virologyTestTokens.diagnosisKeySubmissionToken)
            case .negative:
                Metrics.signpost(.receivedNegativeTestResult)
                handleNegativeCase(result: result)
            case .void:
                Metrics.signpost(.receivedVoidTestResult)
                return
            }
        case .noResultYet:
            return
        }
    }
    
    private func handlePositiveCase(result: VirologyTestResult, diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken) {
        sendNotification()
        virologyTestingStateStore.saveResult(
            virologyTestResult: result,
            diagnosisKeySubmissionToken: diagnosisKeySubmissionToken
        )
        updateIsolationState(.positive, .today)
    }
    
    private func handleNegativeCase(result: VirologyTestResult) {
        sendNotification()
        virologyTestingStateStore.saveResult(virologyTestResult: result, diagnosisKeySubmissionToken: nil)
        updateIsolationState(.negative, .today)
    }
    
    private func sendNotification() {
        userNotificationsManager.add(type: .testResultReceived, at: nil, withCompletionHandler: nil)
    }
    
}

public struct TestOrderInfo {
    public var testOrderWebsiteURL: URL
    public var referenceCode: ReferenceCode
}
