//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class SelectLocalAuthorityScreenScenario: Scenario {
    
    public static let name = "Onboarding - Local authority"
    public static let kind = ScenarioKind.screen
    public static let linkAlertTitle = "Visit cov.uk is tapped"
    public static let confirmAlertTitle = "Confirm button tapped"
    public static let postcode = "S1"
    
    public static let localAuthorities: [LocalAuthority] = [
        LocalAuthority(id: UUID(), name: "Authority 1"),
        LocalAuthority(id: UUID(), name: "Authority 2"),
        LocalAuthority(id: UUID(), name: "Authority 3"),
    ]
    
    public static let supportedLocalAuthority = localAuthorities[0]
    public static let unsupportedLocalAuthority = localAuthorities[2]
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            let localAuthorititesViewModel = LocalAuthorityViewModel(postcode: postcode, localAuthorities: localAuthorities)
            return SelectLocalAuthorityViewController(interactor: interactor, localAuthorityViewModel: localAuthorititesViewModel, hideBackButton: true)
        }
    }
}

private class Interactor: SelectLocalAuthorityViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapLink() {
        viewController?.showAlert(title: SelectLocalAuthorityScreenScenario.linkAlertTitle)
    }
    
    func dismiss() {}
    
    func didTapSubmitButton(localAuthority: LocalAuthority?) -> Result<Void, LocalAuthoritySelectionError> {
        if localAuthority == nil {
            return Result.failure(.emptySelection)
        } else if localAuthority == SelectLocalAuthorityScreenScenario.unsupportedLocalAuthority {
            return Result.failure(.unsupportedCountry)
        } else {
            viewController?.showAlert(title: SelectLocalAuthorityScreenScenario.confirmAlertTitle)
            return Result.success(())
        }
    }
}
