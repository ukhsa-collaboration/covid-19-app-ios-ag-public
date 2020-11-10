//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Integration
import Interface
import UIKit

public class PositiveSymptomsScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Self-Diagnosis - Positive symptoms"
    
    public static let bookTestTapped: String = "Book test button tapped"
    public static let cancelTapped: String = "Cancel tapped"
    public static let furtherAdviceTapped: String = "Further advice tapped"
    public static let exposureFAQstapped = "Exposure FAQs tapped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return PositiveSymptomsViewController(interactor: interactor, isolationEndDate: Date(timeIntervalSinceNow: 7 * 86400))
        }
    }
}

private class Interactor: PositiveSymptomsViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapBookTest() {
        viewController?.showAlert(title: PositiveSymptomsScreenScenario.bookTestTapped)
    }
    
    func didTapCancel() {
        viewController?.showAlert(title: PositiveSymptomsScreenScenario.cancelTapped)
    }
    
    func furtherAdviceLinkTapped() {
        viewController?.showAlert(title: PositiveSymptomsScreenScenario.furtherAdviceTapped)
    }
    
    func exposureFAQsLinkTapped() {
        viewController?.showAlert(title: PositiveSymptomsScreenScenario.exposureFAQstapped)
    }
}
