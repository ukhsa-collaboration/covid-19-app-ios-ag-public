//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Integration
import Interface
import SwiftUI
import UIKit

public class SymptomCardComponentScenario: Scenario {
    public static let name = "SymptomCard"
    public static let kind = ScenarioKind.component
    
    enum Showcases: CaseIterable {
        case shortShort
        case normalNormal
        case normalLong
        case longLong
        
        func content() -> SymptomInfo {
            switch self {
            case .shortShort:
                return SymptomInfo(
                    isConfirmed: true,
                    heading: ExampleText.short.rawValue,
                    content: ExampleText.short.rawValue
                )
            case .normalNormal:
                return SymptomInfo(
                    isConfirmed: true,
                    heading: ExampleText.normal.rawValue,
                    content: ExampleText.normal.rawValue
                )
            case .normalLong:
                return SymptomInfo(
                    isConfirmed: true,
                    heading: ExampleText.normal.rawValue,
                    content: ExampleText.long.rawValue
                )
            case .longLong:
                return SymptomInfo(
                    isConfirmed: true,
                    heading: ExampleText.long.rawValue,
                    content: ExampleText.long.rawValue
                )
            }
        }
    }
    
    static var appController: AppController {
        BasicAppController(rootViewController: UIHostingController(rootView: SymptomCardView()))
    }
}

private struct SymptomCardView: View {
    
    @State var preferredColourScheme: ColorScheme? = nil
    
    @SwiftUI.Environment(\.colorScheme) var colorScheme
    
    fileprivate init() {}
    
    var body: some View {
        NavigationView {
            List(SymptomCardComponentScenario.Showcases.allCases, id: \.index) {
                SymptomCard(viewModel: $0.content())
                
            }
            .navigationBarItems(trailing: toggleColorSchemeButton)
            .navigationBarTitle("SymptomCard")
            
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
