//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Integration
import Interface
import SwiftUI
import UIKit

public class SettingsScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Settings"
    
    public static let language: String = "English"
    public static let didTapLanguage = "Tapped language"
    
    static var appController: AppController {
        NavigationAppController { parent in
            SettingsViewController(
                viewModel: SettingsViewController.ViewModel(),
                interacting: Interactor(_didTapLanguage: {
                    parent.showAlert(title: didTapLanguage)
                })
            )
        }
    }
}

private struct Interactor: SettingsViewController.Interacting {
    var _didTapLanguage: () -> Void
    
    func didTapLanguage() {
        _didTapLanguage()
    }
}
