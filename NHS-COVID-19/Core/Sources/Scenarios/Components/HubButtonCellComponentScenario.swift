//
// Copyright © 2021 DHSC. All rights reserved.
//

import Integration
import Interface
import SwiftUI

public class HubButtonCellComponentScenario: Scenario {
    public static let name = "Hub button cell"
    public static let kind = ScenarioKind.component
    public static let firstHubButtonCellTitle = "First hub cell button title"
    public static let firstHubButtonCellDescription = "Description of the first hub cell button"
    public static let secondHubButtonCellTitle = "Second hub cell button title"
    public static let secondHubButtonCellDescription = "Description of the second hub cell button"
    
    public enum Alerts: String {
        case firstHubButtoCellAlert = "First hub cell button tapped"
        case secondHubButtonCellAlert = "Second hub cell button tapped"
    }
    
    static var appController: AppController {
        BasicAppController(rootViewController: UIHostingController(rootView: HubButtonCellScenarioView()))
    }
    
    private struct HubButtonCellScenarioView: View {
        @State private var currentAlert: Alerts = .firstHubButtoCellAlert
        @State private var showAlert = false
        
        var body: some View {
            NavigationView {
                ScrollView {
                    VStack(spacing: 2) {
                        HubButtonCell(
                            viewModel:
                            .init(
                                title: firstHubButtonCellTitle,
                                description: firstHubButtonCellDescription,
                                action: {
                                    showAlert = true
                                    currentAlert = .firstHubButtoCellAlert
                                }
                            )
                        )
                        HubButtonCell(viewModel:
                            .init(
                                title: secondHubButtonCellTitle,
                                description: secondHubButtonCellDescription,
                                iconName: .externalLink,
                                action: {
                                    showAlert = true
                                    currentAlert = .secondHubButtonCellAlert
                                }
                            )
                        )
                        
                    }
                }
                .background(Color(.background))
                .navigationBarTitle("Hub button cell")
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(currentAlert.rawValue),
                    message: nil
                )
            }
        }
        
    }
}
