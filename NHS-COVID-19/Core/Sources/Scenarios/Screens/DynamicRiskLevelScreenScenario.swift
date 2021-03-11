//
// Copyright © 2021 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

public class DynamicRiskLevelScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Dynamic Risk Level"
    
    public static let title: String = "[Placeholder] SW12 is in local COVID alert level: very high "
    public static let heading: [String] = ["[Placeholder] Coronavirus cases are very high in your area"]
    public static let body: [String] = ["[Placeholder] The restrictions placed on areas with a very high level of infections can vary and are based on discussions between central and local government. You should check the specific rules in your area."]
    public static let linkTitle: String = "[Placeholder] Restrictions in your area"
    public static let footer: [String] = ["[Placeholder] Find out what rules apply in your area to help reduce the spread of coronavirus. "]
    
    public static let policyIcons: [ImageName] = [
        .riskLevelDefaultIcon,
        .riskLevelMeetingPeopleIcon,
        .riskLevelBarsAndPubsIcon,
        .riskLevelWorshipIcon,
        .riskLevelOvernightStaysIcon,
        .riskLevelEducationIcon,
        .riskLevelTravellingIcon,
        .riskLevelExerciseIcon,
        .riskLevelWeddingsAndFuneralsIcon,
    ]
    
    public static let policyHeadings: [String] = [
        "[Placeholder] Default Icon",
        "[Placeholder] Meeting People",
        "[Placeholder] Bars and Pubs",
        "[Placeholder] Worship",
        "[Placeholder] Overnight Stays",
        "[Placeholder] Education",
        "[Placeholder] Travelling",
        "[Placeholder] Exercise",
        "[Placeholder] Weddings and Funerals",
    ]
    
    public static let policyContents: [String] = [
        "[Placeholder] Policy Content 1",
        "[Placeholder] Policy Content 2",
        "[Placeholder] Policy Content 3",
        "[Placeholder] Policy Content 4",
        "[Placeholder] Policy Content 5",
        "[Placeholder] Policy Content 6",
        "[Placeholder] Policy Content 7",
        "[Placeholder] Policy Content 8",
        "[Placeholder] Policy Content 9",
    ]
    
    public static let linkButtonTapped = "Link to website tapped"
    public static let cancelTapped = "Cancel tapped"
    public static let linkFindTestCenterTapped = "Find a test centre link tapped"
    public static let findTestCenterLinkTitle = "Find a test site"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            let viewModel = RiskLevelBanner.ViewModel(
                postcode: "SW12",
                colorScheme: .red,
                title: Self.title,
                infoTitle: Self.title,
                heading: Self.heading,
                body: Self.body,
                linkTitle: Self.linkTitle,
                linkURL: URL(string: "http://google.com"),
                footer: Self.footer,
                policies: zip(policyIcons, zip(policyHeadings, policyContents)).map {
                    RiskLevelInfoViewController.Policy(
                        icon: $0.0,
                        heading: $0.1.0,
                        body: $0.1.1
                    )
                },
                shouldShowMassTestingLink: .constant(true)
            )
            return RiskLevelInfoViewController(viewModel: viewModel.riskLevelInfoViewModel, interactor: interactor)
        }
    }
}

private class Interactor: RiskLevelInfoViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapWebsiteLink(url: URL) {
        viewController?.showAlert(title: DynamicRiskLevelScreenScenario.linkButtonTapped)
    }
    
    func didTapFindTestCenterLink(url: URL) {
        viewController?.showAlert(title: DynamicRiskLevelScreenScenario.linkFindTestCenterTapped)
    }
    
    func didTapCancel() {
        viewController?.showAlert(title: DynamicRiskLevelScreenScenario.cancelTapped)
    }
    
}
