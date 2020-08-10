//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine

struct RiskScoreNegotiator {
    private var saveRiskScore: (RiskInfo) -> Void
    private var getIsolationState: () -> IsolationState
    private var isolationState: AnyPublisher<IsolationState, Never>
    private var deleteRiskScore: () -> Void
    
    init(
        saveRiskScore: @escaping (RiskInfo) -> Void,
        getIsolationState: @escaping () -> IsolationState,
        isolationState: AnyPublisher<IsolationState, Never>,
        deleteRiskScore: @escaping () -> Void
    ) {
        self.saveRiskScore = saveRiskScore
        self.getIsolationState = getIsolationState
        self.isolationState = isolationState
        self.deleteRiskScore = deleteRiskScore
    }
    
    func receive(riskInfo: RiskInfo) {
        if getIsolationState() == .noNeedToIsolate {
            saveRiskScore(riskInfo)
        }
    }
    
    func deleteRiskIfIsolating() -> AnyCancellable {
        isolationState.sink { isolationState in
            if case .isolate = isolationState {
                self.deleteRiskScore()
            }
        }
    }
}

extension RiskScoreNegotiator {
    init(isolationStateManager: IsolationStateManager, exposureDetectionStore: ExposureDetectionStore) {
        self.init(
            saveRiskScore: exposureDetectionStore.save(riskInfo:),
            getIsolationState: { IsolationState(logicalState: isolationStateManager.state) },
            isolationState: isolationStateManager.$state.map(IsolationState.init(logicalState:)).eraseToAnyPublisher(),
            deleteRiskScore: { exposureDetectionStore.exposureInfo = nil }
        )
    }
}
