//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation

public protocol VirologyTestingManaging {
    func provideTestOrderInfo() -> AnyPublisher<TestOrderInfo, NetworkRequestError>
    func linkExternalTestResult(with token: String) -> AnyPublisher<Void, LinkTestResultError>
}

class VirologyTestingManager: VirologyTestingManaging {
    private let httpClient: HTTPClient
    private let virologyTestingStateCoordinator: VirologyTestingStateCoordinating
    
    init(
        httpClient: HTTPClient,
        virologyTestingStateCoordinator: VirologyTestingStateCoordinator
    ) {
        self.httpClient = httpClient
        self.virologyTestingStateCoordinator = virologyTestingStateCoordinator
    }
    
    func provideTestOrderInfo() -> AnyPublisher<TestOrderInfo, NetworkRequestError> {
        httpClient.fetch(OrderTestkitEndpoint())
            .handleEvents(receiveOutput: virologyTestingStateCoordinator.saveOrderTestKitResponse)
            .map { response in
                TestOrderInfo(testOrderWebsiteURL: response.testOrderWebsite, referenceCode: response.referenceCode)
            }.eraseToAnyPublisher()
    }
    
    func evaulateTestResults() -> AnyPublisher<Void, Never> {
        return Publishers.Sequence<[AnyPublisher<VirologyTestResponse, NetworkRequestError>], NetworkRequestError>(
            sequence: virologyTestingStateCoordinator.virologyTestTokens.map { tokens in
                httpClient.fetch(VirologyTestResultEndpoint(), with: tokens.pollingToken)
                    .handleEvents(receiveOutput: { response in
                        self.virologyTestingStateCoordinator.handleTestResult(
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
            .ensureFinishes(placeholder: ())
            .eraseToAnyPublisher()
    }
    
    func linkExternalTestResult(with token: String) -> AnyPublisher<Void, LinkTestResultError> {
        httpClient.fetch(LinkVirologyTestResultEndpoint(), with: CTAToken(value: token))
            .handleEvents(receiveOutput: virologyTestingStateCoordinator.handleLinkTestResult)
            .mapError(LinkTestResultError.init)
            .map { _ in
                ()
            }
            .eraseToAnyPublisher()
    }
}

public struct TestOrderInfo {
    public var testOrderWebsiteURL: URL
    public var referenceCode: ReferenceCode
}
