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
    private let ctaTokenValidator: CTATokenValidating
    
    init(
        httpClient: HTTPClient,
        virologyTestingStateCoordinator: VirologyTestingStateCoordinator,
        ctaTokenValidator: CTATokenValidating
    ) {
        self.httpClient = httpClient
        self.virologyTestingStateCoordinator = virologyTestingStateCoordinator
        self.ctaTokenValidator = ctaTokenValidator
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
                        self.virologyTestingStateCoordinator.handlePollingTestResult(
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
        if ctaTokenValidator.validate(token) {
            return httpClient.fetch(LinkVirologyTestResultEndpoint(), with: CTAToken(value: token))
                .handleEvents(receiveOutput: virologyTestingStateCoordinator.handleManualTestResult)
                .mapError(LinkTestResultError.init)
                .map { _ in
                    ()
                }
                .eraseToAnyPublisher()
        } else {
            return Result.failure(LinkTestResultError.invalidCode).publisher.eraseToAnyPublisher()
        }
        
    }
}

public struct TestOrderInfo {
    public var testOrderWebsiteURL: URL
    public var referenceCode: ReferenceCode
}
