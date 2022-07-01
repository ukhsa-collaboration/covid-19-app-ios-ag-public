//
// Copyright © 2021 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

public class RecoverableErrorScreenTemplateScenario: Scenario {
    public static let name = "Recoverable Error"
    public static let kind = ScenarioKind.screenTemplate

    public static let straplineTitle = "NHS Covid 19"
    public static let errorTitle = "We are showing you this screen if you can resolve an error"
    public static let actionTitle = "Act now"
    public static let secondaryActionTitle = "Act now (secondary)"
    public static let didPerformActionTitle = "You acted!"
    public static let didPerformSecondaryActionTitle = "You acted (secondary)!"
    public static let customViewContent = "This is some custom content we show for this step."
    public static let customViewContent2 = "We can have multiple items that show one after another."
    public static let customViewContent3 = """
    If the content is too long to fit on the screen, you should be able to scroll to see them.
    """

    static var appController: AppController {
        let navigation = UINavigationController()
        navigation.isNavigationBarHidden = true
        let content = viewController(act: { [weak navigation] in
            navigation?.showAlert(title: didPerformActionTitle)
        }, secondaryAct: { [weak navigation] in
            navigation?.showAlert(title: didPerformSecondaryActionTitle)
        }, isPrimaryButtonLink: false)
        navigation.pushViewController(content, animated: false)
        return BasicAppController(rootViewController: navigation)
    }

    private static func viewController(act: @escaping () -> Void, secondaryAct: @escaping () -> Void, isPrimaryButtonLink: Bool) -> UIViewController {
        let content = [customViewContent, customViewContent2, customViewContent3].map { text -> UIView in
            let label = UILabel()
            label.styleAsBody()
            label.text = text
            return label
        }

        let error = Error(title: errorTitle, actionTitle: actionTitle, content: content, act: act)
        let secondaryBtnAction = (title: secondaryActionTitle, act: secondaryAct)
        return RecoverableErrorViewController(error: error, isPrimaryLinkBtn: isPrimaryButtonLink, secondaryBtnAction: secondaryBtnAction)
    }

    private struct Error: ErrorDetail {
        var action: (title: String, act: () -> Void)? {
            (actionTitle, act)
        }

        var logoStrapLineStyle: LogoStrapline.Style = .onboarding

        var title: String
        var actionTitle: String
        var content: [UIView]
        var act: () -> Void
    }
}
