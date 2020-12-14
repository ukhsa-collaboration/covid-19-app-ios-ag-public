//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation

protocol IsolationPaymentInfoProvider {
    func load() -> IsolationPaymentRawState?
    func save(_ state: IsolationPaymentRawState)
    func delete()
}

extension IsolationPaymentStore: IsolationPaymentInfoProvider {}

class IsolationPaymentManager {
    
    let httpClient: HTTPClient
    let isolationPaymentInfoProvider: IsolationPaymentInfoProvider
    let country: () -> Country
    let isInCorrectIsolationStateToApplyForFinancialSupport: () -> Bool
    
    init(
        httpClient: HTTPClient,
        isolationPaymentInfoProvider: IsolationPaymentInfoProvider,
        country: @escaping () -> Country,
        isInCorrectIsolationStateToApplyForFinancialSupport: @escaping () -> Bool
    ) {
        self.httpClient = httpClient
        self.isolationPaymentInfoProvider = isolationPaymentInfoProvider
        self.country = country
        self.isInCorrectIsolationStateToApplyForFinancialSupport = isInCorrectIsolationStateToApplyForFinancialSupport
    }
    
    func processCanApplyForFinancialSupport() -> AnyPublisher<Void, Never> {
        guard isInCorrectIsolationStateToApplyForFinancialSupport() else {
            isolationPaymentInfoProvider.delete()
            return Empty().eraseToAnyPublisher()
        }
        
        guard isolationPaymentInfoProvider.load() == nil else {
            return Empty().eraseToAnyPublisher()
        }
        
        return httpClient.fetch(IsolationPaymentTokenCreateEndpoint(), with: country())
            .catch { _ in Empty() }
            .handleEvents(receiveOutput: isolationPaymentInfoProvider.save)
            .map { _ in }
            .eraseToAnyPublisher()
        
    }
}
