//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Localization
import SwiftUI

public enum IsolationState: Equatable {
    case notIsolating
    case isolating(days: Int, endDate: Date)
}

public struct RiskLevelIndicator: View {
    
    public class ViewModel: ObservableObject {
        
        var anyCancellable: AnyCancellable?
        
        @InterfaceProperty var isolationState: IsolationState
        @InterfaceProperty var paused: Bool
        
        public init(isolationState: InterfaceProperty<IsolationState>, paused: InterfaceProperty<Bool>) {
            _isolationState = isolationState
            _paused = paused
            
            anyCancellable = Publishers.CombineLatest(isolationState.$wrappedValue, paused.$wrappedValue).sink(receiveValue: { [weak self] _ in
                self?.objectWillChange.send()
            })
        }
    }
    
    @ObservedObject private var viewModel: ViewModel
    
    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        containedView()
    }
    
    private func containedView() -> AnyView {
        switch (viewModel.isolationState, viewModel.paused) {
        case (let .isolating(days, endDate), _):
            return Self.makeIsolatingIndicator(days: days, date: endDate, isDetectionPaused: viewModel.paused)
        case (.notIsolating, false):
            return Self.makeNotIsolatingIndicator()
        case (.notIsolating, true):
            return Self.makePausedIndicator()
        }
    }
}
