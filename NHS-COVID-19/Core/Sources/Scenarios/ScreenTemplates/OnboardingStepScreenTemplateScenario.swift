//
// Copyright © 2021 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

public class OnboardingStepScreenTemplateScenario: Scenario {
    public static let name = "Onboarding Step"
    public static let kind = ScenarioKind.screenTemplate
    
    public static let straplineTitle = "NHS Covid 19"
    public static let stepTitle = "We are telling you something important"
    public static let actionTitle = "Act now"
    public static let didPerformActionTitle = "You acted!"
    public static let customViewContent = "This is some custom content we show for this step."
    public static let customViewContent2 = "We can have multiple items that show one after another."
    public static let customViewContent3 = """
    If the content is too long to fit on the screen, you should be able to scroll to see them.
    """
    
    static var appController: AppController {
        let navigation = UINavigationController()
        navigation.isNavigationBarHidden = true
        let content = viewController { [weak navigation] in
            navigation?.showAlert(title: didPerformActionTitle)
        }
        navigation.pushViewController(content, animated: false)
        return BasicAppController(rootViewController: navigation)
    }
    
    private static func viewController(act: @escaping () -> Void) -> UIViewController {
        let content = [stepTitle, customViewContent, customViewContent2, customViewContent3].map { text -> UIView in
            let label = UILabel()
            label.styleAsBody()
            label.text = text
            return label
        }
        
        let step = Step(actionTitle: actionTitle, content: content, _act: act)
        return OnboardingStepViewController(step: step)
    }
    
    private struct Step: OnboardingStep {
        var strapLineStyle: LogoStrapline.Style? = .onboarding
        var footerContent = [UIView]()
        var actionTitle: String
        var content: [UIView]
        var _act: () -> Void
        var image: UIImage? {
            UIImage(named: "Onboarding/Protect")
        }
        
        func act() {
            _act()
        }
    }
    
}
