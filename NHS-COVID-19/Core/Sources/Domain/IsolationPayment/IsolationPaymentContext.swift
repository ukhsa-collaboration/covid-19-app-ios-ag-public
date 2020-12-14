//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation

struct IsolationPaymentContext {
    
    private let store: IsolationPaymentStore
    private let manager: IsolationPaymentManager
    private let isolationState: DomainProperty<IsolationLogicalState>
    private let applicationClient: IsolationPaymentApplicationClient
    
    init(
        services: ApplicationServices,
        country: DomainProperty<Country>,
        isolationState: DomainProperty<IsolationLogicalState>,
        isolationStateStore: IsolationStateStore
    ) {
        self.isolationState = isolationState
        
        store = IsolationPaymentStore(store: services.encryptedStore)
        
        applicationClient = IsolationPaymentApplicationClient(
            submissionClient: services.apiClient,
            isolationStateStore: isolationStateStore,
            isolationState: isolationState
        )
        
        manager = IsolationPaymentManager(
            httpClient: services.apiClient,
            isolationPaymentInfoProvider: store,
            country: { country.currentValue },
            isInCorrectIsolationStateToApplyForFinancialSupport: { isolationState.currentValue.isInCorrectIsolationStateToApplyForFinancialSupport }
        )
    }
    
    var isolationPaymentState: DomainProperty<IsolationPaymentState> {
        isolationState
            .combineLatest(store.$isolationPaymentState)
            .map { isolationState, isolationPaymentState in
                guard
                    isolationState.isInCorrectIsolationStateToApplyForFinancialSupport,
                    case .ipcToken(let token) = isolationPaymentState else {
                    return .disabled
                }
                return .enabled(apply: { self.applicationClient.applicationGatewayURL(for: token) })
            }
            .domainProperty()
    }
    
    func processCanApplyForFinancialSupport() -> AnyPublisher<Void, Never> {
        manager.processCanApplyForFinancialSupport()
    }
    
}
