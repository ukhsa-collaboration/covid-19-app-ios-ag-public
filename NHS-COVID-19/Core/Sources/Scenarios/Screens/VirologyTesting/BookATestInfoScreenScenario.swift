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
    
    public static let appPrivacyNoticeTaped: String = "App Privacy Notice link taped"
    public static let testingPrivacyNoticeTaped: String = "Testing Privacy Notice link taped"
    public static let bookTestForSomeoneElseTaped: String = "Book test for someone else link taped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return BookATestInfoViewController(interactor: interactor, shouldHaveCancelButton: true)
        }
    }
}

private class Interactor: BookATestInfoViewController.Interacting {
    func didTapTestingPrivacyNotice() {
        viewController?.showAlert(title: BookATestInfoScreenScenario.testingPrivacyNoticeTaped)
    }
    
    func didTapAppPrivacyNotice() {
        viewController?.showAlert(title: BookATestInfoScreenScenario.appPrivacyNoticeTaped)
    }
    
    func didTapBookATestForSomeoneElse() {
        viewController?.showAlert(title: BookATestInfoScreenScenario.bookTestForSomeoneElseTaped)
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
