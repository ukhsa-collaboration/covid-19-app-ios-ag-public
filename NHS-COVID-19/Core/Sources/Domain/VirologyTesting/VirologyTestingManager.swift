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
    private let country: () -> Country
    
    init(
        httpClient: HTTPClient,
        virologyTestingStateCoordinator: VirologyTestingStateCoordinator,
        ctaTokenValidator: CTATokenValidating,
        country: @escaping () -> Country
    ) {
        self.httpClient = httpClient
        self.virologyTestingStateCoordinator = virologyTestingStateCoordinator
        self.ctaTokenValidator = ctaTokenValidator
        self.country = country
    }
    
    func provideTestOrderInfo() -> AnyPublisher<TestOrderInfo, NetworkRequestError> {
        httpClient.fetch(OrderTestKitEndpoint())
            .handleEvents(receiveOutput: virologyTestingStateCoordinator.saveOrderTestKitResponse)
            .map { response in
                TestOrderInfo(testOrderWebsiteURL: response.testOrderWebsite, referenceCode: response.referenceCode)
            }.eraseToAnyPublisher()
    }
    
    func evaulateTestResults() -> AnyPublisher<Void, Never> {
        return Publishers.Sequence<[AnyPublisher<VirologyTestResponse, NetworkRequestError>], NetworkRequestError>(
            sequence: virologyTestingStateCoordinator.virologyTestTokens.map { tokens in
                httpClient.fetch(VirologyTestResultEndpoint(), with: VirologyTestResultRequest(pollingToken: tokens.pollingToken, country: country()))
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
            return httpClient.fetch(LinkVirologyTestResultEndpoint(), with: CTAToken(value: token, country: country()))
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
