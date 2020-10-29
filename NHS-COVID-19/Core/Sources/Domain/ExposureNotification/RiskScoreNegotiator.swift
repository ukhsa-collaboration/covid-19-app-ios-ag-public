//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Logging

struct RiskScoreNegotiator {
    
    private static let logger = Logger(label: "ExposureNotification")
    
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
    
    func saveIfNeeded(exposureRiskInfo: ExposureRiskInfo) -> Bool {
        Self.logger.info("calculated risk info", metadata: .describing(exposureRiskInfo))
        if getIsolationState() == .noNeedToIsolate, exposureRiskInfo.isConsideredRisky {
            Self.logger.info("risk score is significant. Saving it.")
            let riskInfo = RiskInfo(
                riskScore: exposureRiskInfo.riskScore,
                riskScoreVersion: exposureRiskInfo.riskScoreVersion,
                day: exposureRiskInfo.day
            )
            saveRiskScore(riskInfo)
            return true
        }
        return false
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
