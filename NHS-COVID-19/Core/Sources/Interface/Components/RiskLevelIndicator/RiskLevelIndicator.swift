//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Localization
import SwiftUI

public enum IsolationState: Equatable {
    case notIsolating
    case isolating(days: Int, percentRemaining: Double, endDate: Date, hasPositiveTest: Bool)
}

public struct RiskLevelIndicator: View {
    
    public class ViewModel: ObservableObject {
        
        var anyCancellable: AnyCancellable?
        
        @InterfaceProperty var isolationState: IsolationState
        @InterfaceProperty var paused: Bool
        @InterfaceProperty var animationDisabled: Bool
        
        public init(
            isolationState: InterfaceProperty<IsolationState>,
            paused: InterfaceProperty<Bool>,
            animationDisabled: InterfaceProperty<Bool>
        ) {
            _isolationState = isolationState
            _paused = paused
            _animationDisabled = animationDisabled
            
            anyCancellable = _animationDisabled.$wrappedValue.combineLatest(
                isolationState.$wrappedValue,
                paused.$wrappedValue
            )
            .sink(receiveValue: { [weak self] _ in
                self?.objectWillChange.send()
            })
        }
    }
    
    @ObservedObject private var viewModel: ViewModel
    private let turnContactTracingOnTapAction: () -> Void
    
    public init(viewModel: ViewModel, turnContactTracingOnTapAction: @escaping () -> Void) {
        self.viewModel = viewModel
        self.turnContactTracingOnTapAction = turnContactTracingOnTapAction
    }
    
    public var body: some View {
        containedView()
    }
    
    private func containedView() -> AnyView {
        switch (viewModel.isolationState, viewModel.paused) {
        case (let .isolating(days, percentRemaining, endDate, _), _):
            return Self.makeIsolatingIndicator(
                days: days,
                percentRemaining: percentRemaining,
                date: endDate,
                isDetectionPaused: viewModel.paused,
                animationDisabled: viewModel.animationDisabled
            )
        case (.notIsolating, false):
            return Self.makeNotIsolatingIndicator(animationDisabled: viewModel.animationDisabled)
        case (.notIsolating, true):
            return Self.makePausedIndicator(turnBackOnTapAction: turnContactTracingOnTapAction)
        }
    }
}
