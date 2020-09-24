//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class NoActionRecoverableErrorScreenTemplateScenario: Scenario, UITestInspectable {
    public static let name = "Recoverable Error - No action"
    public static let kind = ScenarioKind.screenTemplate
    
    public static let straplineTitle = "NHS Covid 19"
    public static let errorTitle = "We are showing you this screen if you can resolve an error"
    public static let customViewContent = "This is some custom content we show for this step."
    public static let customViewContent2 = "We can have multiple items that show one after another."
    public static let customViewContent3 = """
    If the content is too long to fit on the screen, you should be able to scroll to see them.
    """
    
    static var appController: AppController {
        let navigation = UINavigationController()
        navigation.isNavigationBarHidden = true
        navigation.pushViewController(viewController(), animated: false)
        return BasicAppController(rootViewController: navigation)
    }
    
    public static var viewControllerForInspecting: UIViewController {
        viewController()
    }
    
    private static func viewController() -> UIViewController {
        let content = [customViewContent, customViewContent2, customViewContent3].map { text -> UIView in
            let label = UILabel()
            label.styleAsBody()
            label.text = text
            return label
        }
        
        let error = Error(title: errorTitle, content: content)
        return RecoverableErrorViewController(error: error)
    }
    
    private struct Error: ErrorDetail {
        var action: (title: String, act: () -> Void)? = nil
        var title: String
        var content: [UIView]
        var logoStrapLineStyle: LogoStrapline.Style = .onboarding
    }
}
