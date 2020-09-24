//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class ShareKeysConfirmationScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Share Keys Confirmation"
    
    public static let iUnderstandTapped = "I understand tapped"
    public static let backTapped = "Back tapped"
    
    static var appController: AppController {
        NavigationAppController { parent in
            let interactor = Interactor(viewController: parent)
            return ShareKeysConfirmationViewController(interactor: interactor)
            
        }
    }
}

private class Interactor: ShareKeysConfirmationViewController.Interacting {
    var didTapBack: () -> Void
    var didTapIUnderstand: () -> Void
    
    init(viewController: UIViewController) {
        didTapIUnderstand = { [weak viewController] in
            viewController?.showAlert(title: ShareKeysConfirmationScreenScenario.iUnderstandTapped)
        }
        
        didTapBack = { [weak viewController] in
            viewController?.showAlert(title: ShareKeysConfirmationScreenScenario.backTapped)
        }
    }
}
