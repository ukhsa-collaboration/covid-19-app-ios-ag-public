//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Integration
import Interface
import SwiftUI
import UIKit

public class RiskLevelBannerComponentScenario: Scenario {
    
    public static let name = "Risk Level Banner"
    public static let kind = ScenarioKind.component
    
    enum Showcases: CaseIterable {
        case neutral
        case green
        case yellow
        case amber
        case red
        
        func content() -> RiskLevelBanner.ViewModel {
            switch self {
            case .neutral:
                return RiskLevelBanner.ViewModel(
                    postcode: .init("SW12"),
                    colorScheme: .neutral,
                    title: "SW12 area risk level is Neutral",
                    infoTitle: "SW12 area risk level is Neutral",
                    heading: [],
                    body: [],
                    linkTitle: "",
                    linkURL: nil,
                    footer: [],
                    policies: []
                )
            case .green:
                return RiskLevelBanner.ViewModel(
                    postcode: .init("SW12"),
                    colorScheme: .green,
                    title: "SW12 area risk level is Green",
                    infoTitle: "SW12 area risk level is Green",
                    heading: [],
                    body: [],
                    linkTitle: "",
                    linkURL: nil,
                    footer: [],
                    policies: []
                )
            case .yellow:
                return RiskLevelBanner.ViewModel(
                    postcode: .init("SW12"),
                    colorScheme: .yellow,
                    title: "SW12 area risk level is Yellow",
                    infoTitle: "SW12 area risk level is Yellow",
                    heading: [],
                    body: [],
                    linkTitle: "",
                    linkURL: nil,
                    footer: [],
                    policies: []
                )
            case .amber:
                return RiskLevelBanner.ViewModel(
                    postcode: .init("SW12"),
                    colorScheme: .amber,
                    title: "SW12 area risk level is Amber",
                    infoTitle: "SW12 area risk level is Amber",
                    heading: [],
                    body: [],
                    linkTitle: "",
                    linkURL: nil,
                    footer: [],
                    policies: []
                )
            case .red:
                return RiskLevelBanner.ViewModel(
                    postcode: .init("SW12"),
                    colorScheme: .red,
                    title: "SW12 area risk level is Red",
                    infoTitle: "SW12 area risk level is Red",
                    heading: [],
                    body: [],
                    linkTitle: "",
                    linkURL: nil,
                    footer: [],
                    policies: []
                )
            }
        }
    }
    
    static var appController: AppController {
        BasicAppController(rootViewController: UIHostingController(rootView: RiskLevelBannerView()))
    }
}

private struct RiskLevelBannerView: View {
    
    @State var preferredColourScheme: ColorScheme? = nil
    
    @SwiftUI.Environment(\.colorScheme) var colorScheme
    
    fileprivate init() {}
    
    var body: some View {
        NavigationView {
            List(RiskLevelBannerComponentScenario.Showcases.allCases, id: \.index) {
                RiskLevelBanner(viewModel: $0.content(), tapAction: { _ in })
                
            }
            .navigationBarItems(trailing: toggleColorSchemeButton)
            .navigationBarTitle("RiskLevelBanner")
            
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
