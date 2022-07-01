//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import SwiftUI
import UIKit

public class ErrorBoxComponentScenario: Scenario {
    public static let name = "ErrorBox"
    public static let kind = ScenarioKind.component

    enum Showcases: CaseIterable {
        case shortShort
        case normalNormal
        case normalLong
        case longLong

        func content() -> (heading: String, content: String) {
            switch self {
            case .shortShort:
                return (ExampleText.short.rawValue, ExampleText.short.rawValue)
            case .normalNormal:
                return (ExampleText.normal.rawValue, ExampleText.normal.rawValue)
            case .normalLong:
                return (ExampleText.normal.rawValue, ExampleText.long.rawValue)
            case .longLong:
                return (ExampleText.long.rawValue, ExampleText.long.rawValue)
            }
        }
    }

    static var appController: AppController {
        BasicAppController(rootViewController: UIHostingController(rootView: ErrorBoxScenarioView()))
    }
}

private struct ErrorBoxScenarioView: View {

    @State var preferredColourScheme: ColorScheme? = nil

    @SwiftUI.Environment(\.colorScheme) var colorScheme

    fileprivate init() {}

    var body: some View {
        NavigationView {
            List(ErrorBoxComponentScenario.Showcases.allCases, id: \.index) {
                ErrorBox($0.content().heading, description: $0.content().content)
            }
            .navigationBarItems(trailing: toggleColorSchemeButton)
            .navigationBarTitle("ErrorBox")
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
