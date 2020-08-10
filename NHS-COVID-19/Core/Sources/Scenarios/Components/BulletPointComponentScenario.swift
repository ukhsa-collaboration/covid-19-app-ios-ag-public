//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class BulletPointComponentScenario: Scenario {
    public static let name = "BulletPoint"
    public static let kind = ScenarioKind.component
    public static let shortLabel = "Single short label"
    public static let longLabel = "This is a single label with a longer text. It should provoke a linebreak and everything should work fine."
    public static let veryLongLabel = "This is a single label with a longer text. It should provoke a linebreak and everything should work fine. This is a single label with a longer text. It should provoke a linebreak and everything should work fine"
    
    static var appController: AppController {
        let navigation = UINavigationController()
        navigation.pushViewController(InformationBoxViewController(), animated: false)
        return BasicAppController(rootViewController: navigation)
    }
}

private class InformationBoxViewController: UIViewController {
    
    private lazy var stackViewInformationBox: UIView = {
        let titles = [
            BulletPointComponentScenario.shortLabel,
            BulletPointComponentScenario.longLabel,
            BulletPointComponentScenario.veryLongLabel,
        ]
        return OnboardingBulletPointView(titles: titles)
    }()
    
    override func viewDidLoad() {
        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)
        
        let contentStackView = UIStackView(
            arrangedSubviews: [
                stackViewInformationBox,
            ]
        )
        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.distribution = .equalSpacing
        contentStackView.spacing = .bigSpacing
        view.addAutolayoutSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentStackView.widthAnchor.constraint(equalTo: view.widthAnchor),
            contentStackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
        ])
    }
}
