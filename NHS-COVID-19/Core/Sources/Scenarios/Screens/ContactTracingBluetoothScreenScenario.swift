//
// Copyright © 2021 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

public class ContactTracingBluetoothScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Contact Tracing Bluetooth"
    
    public static let continueButtonTapped = "Continue Button Tapped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return ContactTracingBluetoothViewController(
                interactor: interactor,
                country: .constant(.england)
            )
        }
    }
}

private class Interactor: ContactTracingBluetoothViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapContinueButton() {
        viewController?.showAlert(title: ContactTracingBluetoothScreenScenario.continueButtonTapped)
    }
    
}
