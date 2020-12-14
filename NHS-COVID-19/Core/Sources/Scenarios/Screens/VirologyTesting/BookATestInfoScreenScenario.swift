//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Integration
import Interface
import UIKit

public class BookATestInfoScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Book A Test Info"
    
    public static let bookATestTapped: String = "Book a test now tapped"
    public static let cancelTapped: String = "Cancel tapped"
    
    public static let appPrivacyNoticeTapped: String = "App Privacy Notice link tapped"
    public static let testingPrivacyNoticeTapped: String = "Testing Privacy Notice link tapped"
    public static let bookTestForSomeoneElseTapped: String = "Book test for someone else link tapped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return BookATestInfoViewController(interactor: interactor, shouldHaveCancelButton: true)
        }
    }
}

private class Interactor: BookATestInfoViewController.Interacting {
    func didTapTestingPrivacyNotice() {
        viewController?.showAlert(title: BookATestInfoScreenScenario.testingPrivacyNoticeTapped)
    }
    
    func didTapAppPrivacyNotice() {
        viewController?.showAlert(title: BookATestInfoScreenScenario.appPrivacyNoticeTapped)
    }
    
    func didTapBookATestForSomeoneElse() {
        viewController?.showAlert(title: BookATestInfoScreenScenario.bookTestForSomeoneElseTapped)
    }
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapBookATest() {
        viewController?.showAlert(title: BookATestInfoScreenScenario.bookATestTapped)
    }
    
    func didTapCancel() {
        viewController?.showAlert(title: BookATestInfoScreenScenario.cancelTapped)
    }
}
