//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import Integration
import Interface
import SwiftUI

public class ColorPaletteScenario: Scenario {
    public static let name = "Colours"
    public static let kind = ScenarioKind.palette

    static var appController: AppController {
        BasicAppController(rootViewController: UIHostingController(rootView: ColorPaletteView()))
    }
}

private struct ColorPaletteView: View {

    @State var preferredColourScheme: ColorScheme? = nil

    @SwiftUI.Environment(\.colorScheme) var colorScheme

    fileprivate init() {}

    var body: some View {
        NavigationView {
            List(ColorName.allCases) {
                ColorView(name: $0)
            }
            .navigationBarItems(trailing: toggleColorSchemeButton)
            .navigationBarTitle("Colours")
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

private struct ColorView: View {

    var name: ColorName

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(name)
            Text(verbatim: name.rawValue)
                .padding(4)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(4)
                .padding(10)
        }
        .frame(height: 100)
        .frame(idealWidth: .infinity)
        .cornerRadius(6)
    }

}
