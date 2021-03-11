//
// Copyright © 2021 DHSC. All rights reserved.
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
    public static let didTapManageMyData = "Tapped manage my data"
    
    static var appController: AppController {
        NavigationAppController { parent in
            SettingsViewController(
                viewModel: SettingsViewController.ViewModel(),
                interacting: Interactor(_didTapLanguage: {
                    parent.showAlert(title: didTapLanguage)
                }, _didTapManageMyData: {
                    parent.showAlert(title: didTapManageMyData)
                })
            )
        }
    }
}

private struct Interactor: SettingsViewController.Interacting {
    var _didTapLanguage: () -> Void
    var _didTapManageMyData: () -> Void
    
    func didTapLanguage() {
        _didTapLanguage()
    }
    
    func didTapManageMyData() {
        _didTapManageMyData()
    }
}
