//
// Copyright © 2021 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

// MARK: - Common Scenario

protocol CommonLocalInformationScreenScenario: Scenario {
    static var viewModel: LocalInformationViewController.ViewModel { get }
}

extension CommonLocalInformationScreenScenario {

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return LocalInformationViewController(viewModel: Self.viewModel, interactor: interactor)
        }
    }

}

// MARK: - Alert Titles

public enum LocalInformationScreenAlertTitle {
    public static let cancelButton = "Cancel button tapped"
    public static let primaryButton = "Back to home button tapped"

    public static func externalLink(url: URL) -> String {
        return "External link \"\(url.absoluteString)\" tapped"
    }
}

// MARK: - Specific Scenarios

public class LocalInformationScreenParagraphsOnlyScenario: CommonLocalInformationScreenScenario {

    typealias ViewModel = LocalInformationViewController.ViewModel

    public enum Content {
        public static let header = "A new variant of concern is in your area."

        public enum Body {
            public static let paragraph1 = "Paragraph 1 - There have been reported cases of a new variant in SW12. Here are some key pieces of information to help you stay safe"
            public static let link1 = (url: URL(string: "https://nhs.uk")!, title: "NHS link")

            public static let paragraph2 = "Paragraph 2 - There have been reported cases of a new variant in SW12. Here are some key pieces of information to help you stay safe"
            public static let link2 = (url: URL(string: "https://example.uk")!, title: "Example link")
        }
    }

    public static let name = "Local Information - Paragraphs Only"
    public static let kind = ScenarioKind.screen

    static let viewModel = ViewModel(
        header: Content.header,
        body: [
            ViewModel.Paragraph(
                text: Content.Body.paragraph1,
                link: Content.Body.link1
            ),
            LocalInformationViewController.ViewModel.Paragraph(
                text: Content.Body.paragraph2,
                link: Content.Body.link2
            ),
        ]
    )

}

// MARK: - Interactor

private class Interactor: LocalInformationViewController.Interacting {
    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapExternalLink(url: URL) {
        viewController?.showAlert(title: LocalInformationScreenAlertTitle.externalLink(url: url))
    }

    func didTapPrimaryButton() {
        viewController?.showAlert(title: LocalInformationScreenAlertTitle.primaryButton)
    }

    func didTapCancel() {
        viewController?.showAlert(title: LocalInformationScreenAlertTitle.cancelButton)
    }
}
