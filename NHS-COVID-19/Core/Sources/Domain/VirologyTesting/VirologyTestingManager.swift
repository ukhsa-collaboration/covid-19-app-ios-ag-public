//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation

public protocol VirologyTestingManaging {
    func provideTestOrderInfo() -> AnyPublisher<TestOrderInfo, NetworkRequestError>
    func linkExternalTestResult(with token: String) -> AnyPublisher<Void, LinkTestResultError>
    var didReceiveUnknownTestResult: Bool { get }
    func acknowledgeUnknownTestResult()
    func isFollowUpTestRequired() -> AnyPublisher<Bool, Never>
    func didClearBookFollowUpTest()
}

class VirologyTestingManager: VirologyTestingManaging {
    private let httpClient: HTTPClient
    private let virologyTestingStateCoordinator: VirologyTestingStateCoordinating
    private let ctaTokenValidator: CTATokenValidating
    private let country: () -> Country

    let followUpTestRequired = CurrentValueSubject<Bool, Never>(false)

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

    // handle polling for outstanding test results
    func evaulateTestResults() -> AnyPublisher<Void, Never> {
        return Publishers.Sequence<[AnyPublisher<VirologyTestResponse, NetworkRequestError>], NetworkRequestError>(
            sequence: virologyTestingStateCoordinator.virologyTestTokens.map { tokens in
                httpClient.fetch(VirologyTestResultEndpoint(), with: VirologyTestResultRequest(pollingToken: tokens.pollingToken, country: country()))
                    .handleEvents(receiveOutput: { response in
                        self.virologyTestingStateCoordinator.handlePollingTestResult(
                            response,
                            virologyTestTokens: tokens
                        )
                    }, receiveCompletion: { completion in
                        if case .failure(let error) = completion,
                            LinkTestResultError(error) == .decodeFailed {
                            self.virologyTestingStateCoordinator.handlePollingUnknownTestResult(tokens)
                        }
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

    // handle manual entry of a CTA token
    func linkExternalTestResult(with token: String) -> AnyPublisher<Void, LinkTestResultError> {
        if ctaTokenValidator.validate(token) {
            return httpClient.fetch(LinkVirologyTestResultEndpoint(), with: CTAToken(value: token, country: country()))
                .handleEvents(
                    receiveOutput: virologyTestingStateCoordinator.handleManualTestResult,
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion,
                            LinkTestResultError(error) == .decodeFailed {
                            self.virologyTestingStateCoordinator.handleUnknownTestResult()
                        }
                    }
                )
                .mapError(LinkTestResultError.init)
                .map { _ in
                    ()
                }
                .eraseToAnyPublisher()
        } else {
            return Result.failure(LinkTestResultError.invalidCode).publisher.eraseToAnyPublisher()
        }
    }

    var didReceiveUnknownTestResult: Bool {
        virologyTestingStateCoordinator.didReceiveUnknownTestResult
    }

    func acknowledgeUnknownTestResult() {
        virologyTestingStateCoordinator.acknowledgeUnknownTestResult()
    }

    func isFollowUpTestRequired() -> AnyPublisher<Bool, Never> {
        followUpTestRequired.eraseToAnyPublisher()
    }

    func didClearBookFollowUpTest() {
        followUpTestRequired.send(false)
    }

}

public struct TestOrderInfo {
    public var testOrderWebsiteURL: URL
    public var referenceCode: ReferenceCode
}
