//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import Integration
import Interface
import UIKit

public class GuidanceHubEnglandScreenScenario: Scenario {

    public static let name = "COVID-19 Guidance Hub - England Only"
    public static let kind = ScenarioKind.screen
    public static let covid19GuidanceForEnglandTitle = "Covid-19 guidance for England link tapped"
    public static let checkSymptomsForCovid19EnglandTitle = "Check your symptoms for England link tapped"
    public static let latestCovid19TestingGuidanceEnglandTitle = "Latest Covid-19 testing guidance link tapped"
    public static let ifPositiveCovid19GuidanceEnglandTitle = "What to do if you have a positive COVID-19 test result link tapped"
    public static let travellingAbroadGuidanceEnglandTitle = "What to do if you are travelling abroad link tapped"
    public static let claimSSPGuidanceEnglandTitle = "Check if you can claim SSP link tapped"
    public static let getHelpWithCovid19EnquiriesEnglandTitle = "Get help with COVID-19 enquiries link tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            GuidanceHubEnglandViewController(interactor: Interactor(viewController: parent))
        }
    }
}

private struct Interactor: GuidanceHubEnglandViewController.Interacting {
    private let viewController: UIViewController

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapGuidanceForCovid19EnglandLink() {
        viewController.showAlert(title: GuidanceHubEnglandScreenScenario.covid19GuidanceForEnglandTitle)
    }

    func didTapGuidanceForCheckSymptomsEnglandLink() {
        viewController.showAlert(title: GuidanceHubEnglandScreenScenario.checkSymptomsForCovid19EnglandTitle)
    }

    func didTapLatestGuidanceCovid19EnglandLink() {
        viewController.showAlert(title: GuidanceHubEnglandScreenScenario.latestCovid19TestingGuidanceEnglandTitle)
    }

    func didTapGuidancePositiveCovid19TestResultEnglandLink() {
        viewController.showAlert(title: GuidanceHubEnglandScreenScenario.ifPositiveCovid19GuidanceEnglandTitle)
    }

    func didTapGuidanceTravillingAbroadEnglandLink() {
        viewController.showAlert(title: GuidanceHubEnglandScreenScenario.travellingAbroadGuidanceEnglandTitle)
    }

    func didTapGuidanceClaimSSPEnglandLink() {
        viewController.showAlert(title: GuidanceHubEnglandScreenScenario.claimSSPGuidanceEnglandTitle)
    }

    func didTapGuidanceGetHelpCovid19EnquiriesEnglandLink() {
        viewController.showAlert(title: GuidanceHubEnglandScreenScenario.getHelpWithCovid19EnquiriesEnglandTitle)
    }

}
