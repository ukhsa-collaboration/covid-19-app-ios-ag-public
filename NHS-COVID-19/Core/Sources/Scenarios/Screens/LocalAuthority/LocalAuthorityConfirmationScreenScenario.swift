//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class LocalAuthorityConfirmationScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Local Authority - Confirmation"
    
    public static let confirmTapped = "Continue tapped!"
    public static let postcode = "SW8"
    public static let localAuthority = LocalAuthority(id: UUID(), name: "Lambeth")
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return LocalAuthorityConfirmationViewController(interactor: interactor, postcode: Self.postcode, localAuthority: Self.localAuthority, hideBackButton: true)
        }
    }
}

private class Interactor: LocalAuthorityConfirmationViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func confirm(localAuthority: LocalAuthority?) -> Result<Void, LocalAuthoritySelectionError> {
        viewController?.showAlert(title: LocalAuthorityConfirmationScreenScenario.confirmTapped)
        return .success(())
    }
    
    func dismiss() {}
}
