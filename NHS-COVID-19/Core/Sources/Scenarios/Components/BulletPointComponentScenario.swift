//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class BulletPointComponentScenario: Scenario {
    
    public static let name = "Bulleted List "
    public static let kind = ScenarioKind.component
    public static let longLabel = "This is a single label with a longer text. With a bullet point that should be vertically centered with the first letter."
    public static let shortLabel = "Single short label"
    
    static var appController: AppController {
        let navigation = UINavigationController()
        navigation.pushViewController(BulletedListViewController(), animated: false)
        return BasicAppController(rootViewController: navigation)
    }
}

private class BulletedListViewController: UIViewController {
    private typealias Scenario = BulletPointComponentScenario
    
    override func viewDidLoad() {
        
        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)
        
        let bulletedList = BulletedList(rows: [Scenario.longLabel])
        bulletedList.addRow(with: BulletPointComponentScenario.shortLabel)
        
        view.addAutolayoutSubview(bulletedList)
        
        NSLayoutConstraint.activate([
            bulletedList.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .halfSpacing),
            bulletedList.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bulletedList.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
        ])
    }
}
