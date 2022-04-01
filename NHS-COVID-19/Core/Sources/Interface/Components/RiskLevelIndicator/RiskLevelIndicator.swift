//
// Copyright © 2022 DHSC. All rights reserved.
//

import Combine
import Common
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
        @InterfaceProperty var bluetoothOff: Bool
        @InterfaceProperty var country: Country
        
        public init(
            isolationState: InterfaceProperty<IsolationState>,
            paused: InterfaceProperty<Bool>,
            animationDisabled: InterfaceProperty<Bool>,
            bluetoothOff: InterfaceProperty<Bool>,
            country: InterfaceProperty<Country>
        ) {
            _isolationState = isolationState
            _paused = paused
            _animationDisabled = animationDisabled
            _bluetoothOff = bluetoothOff
            _country = country
            
            anyCancellable = _animationDisabled.$wrappedValue.combineLatest(
                isolationState.$wrappedValue,
                paused.$wrappedValue,
                bluetoothOff.$wrappedValue
            )
            .sink(receiveValue: { [weak self] _ in
                self?.objectWillChange.send()
            })
        }
    }
    
    @ObservedObject private var viewModel: ViewModel
    private let turnContactTracingOnTapAction: () -> Void
    private let openSettings: () -> Void
    
    public init(viewModel: ViewModel, turnContactTracingOnTapAction: @escaping () -> Void, openSettings: @escaping () -> Void) {
        self.viewModel = viewModel
        self.turnContactTracingOnTapAction = turnContactTracingOnTapAction
        self.openSettings = openSettings
    }
    
    public var body: some View {
        containedView()
    }
    
    private func containedView() -> AnyView {
        switch (viewModel.isolationState, viewModel.bluetoothOff, viewModel.paused) {
        case (let .isolating(days, percentRemaining, endDate, _), _, _):
            return Self.makeIsolatingIndicator(
                days: days,
                percentRemaining: percentRemaining,
                date: endDate,
                isDetectionPaused: viewModel.paused,
                animationDisabled: viewModel.animationDisabled,
                style: viewModel.country.preferredIndicatorStyle
            )
        case (.notIsolating, true, _):
            return Self.makePausedIndicator(
                action: openSettings,
                message: localize(.bluetooth_not_active),
                buttonTitle: localize(.bluetooth_activate)
            )
        case (.notIsolating, false, false):
            return Self.makeNotIsolatingIndicator(animationDisabled: viewModel.animationDisabled)
        case (.notIsolating, false, true):
            return Self.makePausedIndicator(
                action: turnContactTracingOnTapAction,
                message: localize(.risk_level_indicator_contact_tracing_not_active),
                buttonTitle: localize(.risk_level_indicator_contact_tracing_turn_back_on_button)
            )
        }
    }
}

private extension Country {
    var preferredIndicatorStyle: IsolatingIndicator.Style {
        switch self {
        case .england:
            return .informational
        case .wales:
            return .warning
        }
    }
}
