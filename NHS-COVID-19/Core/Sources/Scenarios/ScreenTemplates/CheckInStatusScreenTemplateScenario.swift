//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class CheckInStatusScreenTemplateScenario: Scenario, UITestInspectable {
    public static let name = "Check-in Status"
    public static let kind = ScenarioKind.screenTemplate
    
    public static let image = UIImage(.error)
    public static let statusTitle = "We are showing you this screen if you can resolve an error"
    public static let explanationTitle = "This is an explanation for the error "
    public static let helpLinkTitle = "This is a help link"
    public static let moreExplanationTitle = "There is more explanation after the link"
    public static let actionTitle = "Act now"
    public static let didPerformActionTitle = "You acted!"
    public static let didPerformShowHelpActionTitle = "Show help!"
    public static let customViewContent = "This is some custom content we show for this step."
    public static let closeButtonTitle = "Close"
    
    static var appController: AppController {
        let navigation = UINavigationController()
        navigation.isNavigationBarHidden = true
        let content = viewController(
            act: { [weak navigation] in
                navigation?.showAlert(title: didPerformActionTitle)
            },
            showHelp: { [weak navigation] in
                navigation?.showAlert(title: didPerformShowHelpActionTitle)
            }
        )
        navigation.pushViewController(content, animated: false)
        return BasicAppController(rootViewController: navigation)
    }
    
    public static var viewControllerForInspecting: UIViewController {
        viewController(act: {}, showHelp: {})
    }
    
    private static func viewController(act: @escaping () -> Void, showHelp: @escaping () -> Void) -> UIViewController {
        let status = Status(
            icon: image,
            title: statusTitle,
            explanation: explanationTitle,
            helpLink: helpLinkTitle,
            moreExplanation: moreExplanationTitle,
            actionButtonTitle: actionTitle,
            _act: act,
            _showHelp: showHelp
        )
        return CheckInStatusViewController(status: status)
    }
    
    private struct Status: StatusDetail {
        var icon: UIImage
        var title: String
        var explanation: String?
        var helpLink: String?
        var moreExplanation: String?
        var explanationAligment: NSTextAlignment = .center
        var actionButtonTitle: String
        var _act: () -> Void
        var closeButtonTitle: String?
        var _showHelp: () -> Void
        
        func act() {
            _act()
        }
        
        func showHelp() {
            _showHelp()
        }
    }
    
}
