//
// Copyright © 2021 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

public class BluetoothDisabledWarningScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Onboarding - Bluetooth disabled"
    
    public static let phoneSettingsButtonTapped = "Open phone settings tapped"
    public static let continueButtonTapped = "Continue without Bluetooth tapped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            BluetoothDisabledWarningViewController.viewController(for: .onboarding, interactor: Interactor(viewController: parent), country: .england)
        }
    }
}

private class Interactor: BluetoothDisabledWarningViewController.Interacting {
    private var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapSettings() {
        viewController?.showAlert(title: BluetoothDisabledWarningScreenScenario.phoneSettingsButtonTapped)
    }
    
    func didTapContinue() {
        viewController?.showAlert(title: BluetoothDisabledWarningScreenScenario.continueButtonTapped)
    }
}
