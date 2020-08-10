//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class LinkButtonComponentScenario: Scenario, UITestInspectable {
    public static var viewControllerForInspecting: UIViewController = LinkButtonViewController()
    
    public static let name = "LinkButton"
    public static let kind = ScenarioKind.component
    public static let linkTitle = "This is a link"
    public static let linkTappedTitle = "Link tapped"
    
    static var appController: AppController {
        let navigation = UINavigationController()
        navigation.pushViewController(viewControllerForInspecting, animated: false)
        return BasicAppController(rootViewController: navigation)
    }
}

private class LinkButtonViewController: UIViewController {
    
    override func viewDidLoad() {
        let linkButton = LinkButton(
            title: LinkButtonComponentScenario.linkTitle
        )
        linkButton.addTarget(self, action: #selector(linkTapped), for: .touchUpInside)
        // linkButton.url = URL(string: LinkButtonComponentScenario.url)
        
        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)
        view.addAutolayoutSubview(linkButton)
        
        NSLayoutConstraint.activate([
            linkButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            linkButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
        ])
    }
    
    @objc private func linkTapped() {
        showAlert(title: LinkButtonComponentScenario.linkTappedTitle)
    }
}
