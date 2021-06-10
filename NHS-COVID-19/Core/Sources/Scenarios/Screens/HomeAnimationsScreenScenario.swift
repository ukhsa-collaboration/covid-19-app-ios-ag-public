//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Integration
import Interface
import UIKit

public class HomeAnimationsScreenScenario: Scenario {
    public static let name = "Settings - Animations"
    public static let kind = ScenarioKind.screen
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let viewModel = HomeAnimationsViewModel(
                homeAnimationEnabled: InterfaceProperty.constant(true),
                homeAnimationEnabledAction: { _ in
                    // 💡 Maybe create a button, for testing?
                }, reduceMotionPublisher: Just(false).eraseToAnyPublisher()
            )
            return HomeAnimationsViewController(viewModel: viewModel)
        }
    }
}
