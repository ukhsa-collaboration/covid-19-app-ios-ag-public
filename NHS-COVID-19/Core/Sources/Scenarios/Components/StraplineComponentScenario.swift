//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Integration
import Interface
import Localization
import SwiftUI
import UIKit

public class StraplineComponentScenario: Scenario {
    
    public static let name = "Strapline (SwiftUI)"
    public static let kind = ScenarioKind.component
    
    enum Showcases: CaseIterable {
        case england
        case wales
        
        func content() -> Strapline {
            switch self {
            case .england:
                return Strapline(country: .constant(.england))
            case .wales:
                return Strapline(country: .constant(.wales))
            }
        }
    }
    
    static var appController: AppController {
        BasicAppController(rootViewController: UIHostingController(rootView: StraplineView()))
    }
}

private struct StraplineView: View {
    
    @State var preferredColourScheme: ColorScheme? = nil
    
    @SwiftUI.Environment(\.colorScheme) var colorScheme
    
    fileprivate init() {}
    
    var body: some View {
        NavigationView {
            List(StraplineComponentScenario.Showcases.allCases, id: \.index) {
                $0.content()
                
            }
            .navigationBarItems(trailing: toggleColorSchemeButton)
            .navigationBarTitle("NavigationButton")
            
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
