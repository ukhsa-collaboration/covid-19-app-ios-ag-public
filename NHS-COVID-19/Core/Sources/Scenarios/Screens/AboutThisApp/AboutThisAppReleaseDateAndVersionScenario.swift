//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Integration
import Interface
import UIKit

public class AboutThisAppReleaseDateAndVersionScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "About this app"
    
    public static let appName = "NHS-COVID-19"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!
            let buildNumber = Bundle.main.infoDictionary!["CFBundleVersion"]!
            let version = "\(appVersion) (\(buildNumber))"
            return AboutThisAppViewController(interactor: interactor, appName: appName, version: version)
        }
    }
}

// This Scenario only exists to generate a screenshot with the release date and version number visible so no alerts are required
private class Interactor: AboutThisAppViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapCommonQuestions() {}
    
    func didTapTermsOfUse() {}
    
    func didTapPrivacyNotice() {}
    
    func didTapAccessibilityStatement() {}
    
    func didTapSeeData() {}
    
    func didTapHowThisAppWorks() {}
    
    func didTapProvideFeedback() {}
    
    func didTapDownloadNHSApp() {}
}
