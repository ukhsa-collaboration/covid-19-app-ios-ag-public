//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Integration
import Interface
import Localization
import SwiftUI
import UIKit

public class ToggleButtonComponentScenario: Scenario {
    
    public static let name = "Toggle Button"
    public static let kind = ScenarioKind.component
    
    enum Showcases: CaseIterable {
        case off
        case on
        
        func content() -> ToggleButton {
            switch self {
            case .off:
                return ToggleButton(
                    isToggledOn: Binding(get: { false }, set: { _ in }),
                    imageName: .homeContactTracing,
                    text: localize(.home_toggle_exposure_notification_title)
                )
            case .on:
                return ToggleButton(
                    isToggledOn: Binding(get: { true }, set: { _ in }),
                    imageName: .homeContactTracing,
                    text: localize(.home_toggle_exposure_notification_title)
                )
            }
        }
    }
    
    static var appController: AppController {
        BasicAppController(rootViewController: UIHostingController(rootView: ToggleButtonView()))
    }
}

private struct ToggleButtonView: View {
    
    @State var preferredColourScheme: ColorScheme? = nil
    
    @SwiftUI.Environment(\.colorScheme) var colorScheme
    
    fileprivate init() {}
    
    var body: some View {
        NavigationView {
            List(ToggleButtonComponentScenario.Showcases.allCases, id: \.index) {
                $0.content()
                
            }
            .navigationBarItems(trailing: toggleColorSchemeButton)
            .navigationBarTitle("ToggleButton")
            
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
