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
    public static let actionTitle = "Act now"
    public static let didPerformActionTitle = "You acted!"
    public static let customViewContent = "This is some custom content we show for this step."
    public static let closeButtonTitle = "Close"
    
    static var appController: AppController {
        let navigation = UINavigationController()
        navigation.isNavigationBarHidden = true
        let content = viewController { [weak navigation] in
            navigation?.showAlert(title: didPerformActionTitle)
        }
        navigation.pushViewController(content, animated: false)
        return BasicAppController(rootViewController: navigation)
    }
    
    public static var viewControllerForInspecting: UIViewController {
        viewController(act: {})
    }
    
    private static func viewController(act: @escaping () -> Void) -> UIViewController {
        let status = Status(
            icon: image,
            title: statusTitle,
            explanation: explanationTitle,
            actionButtonTitle: actionTitle,
            _act: act
        )
        return CheckInStatusViewController(status: status)
    }
    
    private struct Status: StatusDetail {
        var icon: UIImage
        var title: String
        var explanation: String?
        var explanationAligment: NSTextAlignment = .center
        var actionButtonTitle: String
        var _act: () -> Void
        var closeButtonTitle: String?
        
        func act() {
            _act()
        }
    }
    
}
