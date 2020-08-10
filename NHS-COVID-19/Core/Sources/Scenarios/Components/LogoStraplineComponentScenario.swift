//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class LogoStraplineComponentScenario: Scenario, UITestInspectable {
    public static var viewControllerForInspecting: UIViewController = LogoStraplineViewController()
    
    public static let name = "LogoStrapline"
    public static let kind = ScenarioKind.component
    
    static var appController: AppController {
        let navigation = UINavigationController()
        navigation.pushViewController(viewControllerForInspecting, animated: false)
        return BasicAppController(rootViewController: navigation)
    }
}

private class LogoStraplineViewController: UIViewController {
    
    override func viewDidLoad() {
        let logoStrapline = LogoStrapline(.nhsBlue, style: .onboarding)
        
        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)
        view.addAutolayoutSubview(logoStrapline)
        
        NSLayoutConstraint.activate([
            logoStrapline.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            logoStrapline.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
        ])
    }
}
