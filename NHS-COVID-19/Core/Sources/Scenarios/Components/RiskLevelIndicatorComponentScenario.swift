//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Integration
import Interface
import SwiftUI
import UIKit

public class RiskLevelIndicatorComponentScenario: Scenario {
    
    public static let name = "Risk Level Indicator"
    public static let kind = ScenarioKind.component
    
    enum Showcases: CaseIterable {
        case isolatingThreeDays
        case isolatingFourteenDays
        case notIsolating
        case paused
        
        func content() -> RiskLevelIndicator.ViewModel {
            switch self {
            case .isolatingThreeDays:
                return RiskLevelIndicator.ViewModel(isolationState: .constant(.isolating(days: 3, endDate: Date())), paused: .constant(false))
            case .isolatingFourteenDays:
                return RiskLevelIndicator.ViewModel(isolationState: .constant(.isolating(days: 14, endDate: Date())), paused: .constant(false))
            case .notIsolating:
                return RiskLevelIndicator.ViewModel(isolationState: .constant(.notIsolating), paused: .constant(false))
            case .paused:
                return RiskLevelIndicator.ViewModel(isolationState: .constant(.notIsolating), paused: .constant(true))
            }
        }
    }
    
    static var appController: AppController {
        BasicAppController(rootViewController: UIHostingController(rootView: RiskLevelIndicatorView()))
    }
}

private struct RiskLevelIndicatorView: View {
    
    @State var preferredColourScheme: ColorScheme? = nil
    
    @SwiftUI.Environment(\.colorScheme) var colorScheme
    
    fileprivate init() {}
    
    var body: some View {
        NavigationView {
            List(RiskLevelIndicatorComponentScenario.Showcases.allCases, id: \.index) {
                RiskLevelIndicator(viewModel: $0.content())
                
            }
            .navigationBarItems(trailing: toggleColorSchemeButton)
            .navigationBarTitle("RiskLevelIndicator")
            
        }
        .preferredColorScheme(preferredColourScheme)
        
    }
    
    private var toggleColorSchemeButton: some View {
        Button(action: self.toggleColorScheme) {
            Image(systemName: colorScheme == .dark ? "moon.circle.fill" : "moon.circle")
                .frame(width: 44, height: 44)
        }
    }
    
    private func toggleColorScheme() {
        switch colorScheme {
        case .dark:
            preferredColourScheme = .light
        default:
            preferredColourScheme = .dark
        }
    }
}
