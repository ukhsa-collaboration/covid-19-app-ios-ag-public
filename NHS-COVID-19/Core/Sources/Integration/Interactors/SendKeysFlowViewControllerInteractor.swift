//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Domain
import Foundation
import Interface

struct SendKeysFlowViewControllerInteractor: SendKeysFlowViewController.Interacting {
    private let diagnosisKeySharer: DiagnosisKeySharer
    private let didReceiveResult: (DiagnosisKeySharer.ShareResult) -> Void

    init(
        diagnosisKeySharer: DiagnosisKeySharer,
        didReceiveResult: @escaping (DiagnosisKeySharer.ShareResult) -> Void
    ) {
        self.diagnosisKeySharer = diagnosisKeySharer
        self.didReceiveResult = didReceiveResult
    }

    func shareKeys(flowType: SendKeysFlowViewController.ShareFlowType) -> AnyPublisher<Void, Error> {
        return diagnosisKeySharer.shareKeys(DiagnosisKeySharer.ShareFlowType(flowType: flowType))
            .handleEvents(receiveOutput: didReceiveResult)
            .map { _ in }
            .eraseToAnyPublisher()
    }

    func doNotShareKeys(flowType: SendKeysFlowViewController.ShareFlowType) {
        diagnosisKeySharer.doNotShareKeys(DiagnosisKeySharer.ShareFlowType(flowType: flowType))
    }
}

private extension DiagnosisKeySharer.ShareFlowType {
    init(flowType: SendKeysFlowViewController.ShareFlowType) {
        switch flowType {
        case .initial:
            self = .initial
        case .reminder:
            self = .reminder
        }
    }
}
