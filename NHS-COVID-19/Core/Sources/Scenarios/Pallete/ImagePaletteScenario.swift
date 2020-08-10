//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import Integration
import Interface
import SwiftUI

public class ImagePaletteScenario: Scenario {
    public static let name = "Images"
    public static let kind = ScenarioKind.palette
    
    static var appController: AppController {
        BasicAppController(rootViewController: UIHostingController(rootView: ImagePaletteView()))
    }
}

private struct ImagePaletteView: View {
    
    @State var preferredColourScheme: ColorScheme? = nil
    
    @SwiftUI.Environment(\.colorScheme) var colorScheme
    
    fileprivate init() {}
    
    var body: some View {
        NavigationView {
            List(ImageName.allCases) {
                ImagePreviewView(name: $0)
            }
            .navigationBarItems(trailing: toggleColorSchemeButton)
            .navigationBarTitle("Images")
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

private struct ImagePreviewView: View {
    
    var name: ImageName
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(verbatim: name.rawValue)
                .padding(4)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(4)
                .padding(10)
            HStack {
                Spacer()
                Image(name)
                Spacer()
            }
        }
    }
    
}
