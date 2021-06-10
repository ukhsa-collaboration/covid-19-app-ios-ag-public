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
    public static let didTapMyData = "Tapped My data"
    public static let didTapDeleteAppData = "Tapped delete app data"
    public static let didTapVenueHistory = "Tapped venue history"
    public static let didTapMyArea = "Tapped My area"
    public static let didTapMyAnimations = "Tapped Animations"
    
    static var appController: AppController {
        NavigationAppController { parent in
            SettingsViewController(
                viewModel: SettingsViewController.ViewModel(),
                interacting: Interactor(_didTapLanguage: {
                    parent.showAlert(title: didTapLanguage)
                }, _didTapManageMyData: {
                    parent.showAlert(title: didTapMyData)
                }, _didTapMyArea: {
                    parent.showAlert(title: didTapMyArea)
                }, _didTapDeleteAppData: {
                    parent.showAlert(title: didTapDeleteAppData)
                }, _didTapVenueHistory: {
                    parent.showAlert(title: didTapVenueHistory)
                }, _didTapAnimations: {
                    parent.showAlert(title: didTapMyAnimations)
                })
            )
        }
    }
}

private struct Interactor: SettingsViewController.Interacting {
    
    var _didTapLanguage: () -> Void
    var _didTapManageMyData: () -> Void
    var _didTapMyArea: () -> Void
    var _didTapDeleteAppData: () -> Void
    var _didTapVenueHistory: () -> Void
    var _didTapAnimations: () -> Void
    
    func didTapAnimations() {
        _didTapAnimations()
    }
    
    func didTapLanguage() {
        _didTapLanguage()
    }
    
    func didTapManageMyData() {
        _didTapManageMyData()
    }
    
    func didTapMyArea() {
        _didTapMyArea()
    }
    
    func didTapDeleteAppData() {
        _didTapDeleteAppData()
    }
    
    func didTapVenueHistory() {
        _didTapVenueHistory()
    }
    
}
