//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation

struct IsolationPaymentApplicationClient {
    var submissionClient: HTTPClient
    var isolationStateStore: IsolationStateStore
    var isolationState: DomainProperty<IsolationLogicalState>
    
    func applicationGatewayURL(for token: String) -> AnyPublisher<URL, NetworkRequestError> {
        
        guard let isolationStateInfo = isolationStateStore.isolationStateInfo else {
            return Empty().eraseToAnyPublisher()
        }
        
        guard let contactCaseInfo = isolationStateInfo.isolationInfo.contactCaseInfo else {
            return Empty().eraseToAnyPublisher()
        }
        
        guard let activeIsolation = isolationState.currentValue.activeIsolation else {
            return Empty().eraseToAnyPublisher()
        }
        
        let contactCaseIsolation = _Isolation(contactCaseInfo: contactCaseInfo, configuration: isolationStateInfo.configuration)
        
        let riskyEncounterDay = contactCaseInfo.exposureDay
        
        let isolationPeriodEndsAtStartOfDay = min(activeIsolation.untilStartOfDay.gregorianDay, contactCaseIsolation.untilStartOfDay)
        
        let payload = IsolationPaymentTokenUpdate(
            ipcToken: token,
            riskyEncounterDay: riskyEncounterDay,
            isolationPeriodEndsAtStartOfDay: isolationPeriodEndsAtStartOfDay
        )
        return submissionClient.fetch(IsolationPaymentTokenUpdateEndpoint(), with: payload)
    }
}
