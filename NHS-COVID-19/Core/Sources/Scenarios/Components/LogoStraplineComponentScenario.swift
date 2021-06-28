//
// Copyright © 2021 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

public class LogoStraplineComponentScenario: Scenario {
    public static let name = "LogoStrapline"
    public static let kind = ScenarioKind.component
    
    static var appController: AppController {
        let navigation = UINavigationController()
        navigation.pushViewController(LogoStraplineViewController(), animated: false)
        return BasicAppController(rootViewController: navigation)
    }
}

private class LogoStraplineViewController: UIViewController {
    
    override func viewDidLoad() {
        let logoStrapline = LogoStrapline(.nhsBlue, style: .onboarding)
        logoStrapline.isAccessibilityElement = true
        logoStrapline.accessibilityElementsHidden = false
        
        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)
        view.addAutolayoutSubview(logoStrapline)
        
        NSLayoutConstraint.activate([
            logoStrapline.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            logoStrapline.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
        ])
    }
}
