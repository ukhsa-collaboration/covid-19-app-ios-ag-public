//
// Copyright © 2022 DHSC. All rights reserved.
//

import Combine
import Integration
import Interface
import SwiftUI
import UIKit

public class RiskLevelIndicatorComponentScenario: Scenario {
    
    public static let name = "Risk Level Indicator"
    public static let kind = ScenarioKind.component
    public static let turnContactTracingOnTappedTitle = "Turn Contact Tracing On tapped"
    public static let openPhoneSettingTappedTitle = "Open phone settings Button tapped"
    
    enum Showcases: CaseIterable {
        case isolatingThreeDays
        case isolatingFourteenDays
        case notIsolating
        case paused
        
        func content() -> RiskLevelIndicator.ViewModel {
            switch self {
            case .isolatingThreeDays:
                return RiskLevelIndicator.ViewModel(
                    isolationState: .constant(
                        .isolating(days: 3, percentRemaining: 0.2, endDate: Date(), hasPositiveTest: false)
                    ),
                    paused: .constant(false),
                    animationDisabled: .constant(false),
                    bluetoothOff: .constant(true),
                    country: .constant(.england)
                )
            case .isolatingFourteenDays:
                return RiskLevelIndicator.ViewModel(
                    isolationState: .constant(
                        .isolating(days: 14, percentRemaining: 0.2, endDate: Date(), hasPositiveTest: false)),
                    paused: .constant(false),
                    animationDisabled: .constant(false),
                    bluetoothOff: .constant(true),
                    country: .constant(.england)
                )
            case .notIsolating:
                return RiskLevelIndicator.ViewModel(
                    isolationState: .constant(
                        .notIsolating), paused: .constant(false), animationDisabled: .constant(false), bluetoothOff: .constant(true), country: .constant(.england)
                )
            case .paused:
                return RiskLevelIndicator.ViewModel(isolationState: .constant(.notIsolating), paused: .constant(true), animationDisabled: .constant(false), bluetoothOff: .constant(false), country: .constant(.england))
            }
        }
    }
    
    static var appController: AppController {
        BasicAppController(rootViewController: UIHostingController(rootView: RiskLevelIndicatorView()))
    }
}

private struct RiskLevelIndicatorView: View {
    
    @State var preferredColourScheme: ColorScheme? = nil
    @State private var turnContactTracingOnAlertIsPresented = false
    @State private var openPhoneSettingsAlertIsPresented = false
    
    @SwiftUI.Environment(\.colorScheme) var colorScheme
    
    fileprivate init() {}
    
    var body: some View {
        NavigationView {
            List(RiskLevelIndicatorComponentScenario.Showcases.allCases, id: \.index) {
                RiskLevelIndicator(
                    viewModel: $0.content(),
                    turnContactTracingOnTapAction: { turnContactTracingOnAlertIsPresented = true },
                    openSettings: { openPhoneSettingsAlertIsPresented = true }
                )
            }
            .navigationBarItems(trailing: toggleColorSchemeButton)
            .navigationBarTitle("RiskLevelIndicator")
            .alert(isPresented: $turnContactTracingOnAlertIsPresented, content: {
                Alert(title: Text(RiskLevelIndicatorComponentScenario.turnContactTracingOnTappedTitle))
            })
            .alert(isPresented: $openPhoneSettingsAlertIsPresented) {
                Alert(title: Text(RiskLevelIndicatorComponentScenario.openPhoneSettingTappedTitle))
            }
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
