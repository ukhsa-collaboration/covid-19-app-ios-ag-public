//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Integration
import Interface
import UIKit

public class PilotActivationScreenScenario: Scenario {
    public static let name = "On-boarding - Unique code"
    public static let kind = ScenarioKind.screen
    
    public static let continueConfirmationAlertTitle = "Continue button tapped"
    public static let validCode = "5apv-enka"
    public static let invalidCode = "1234"
    
    static var appController: AppController {
        let parent = UINavigationController()
        parent.isNavigationBarHidden = true
        let authenticationCodeViewController = PilotActivationViewController { authcode in
            if authcode == validCode {
                return Result.success(()).publisher.eraseToAnyPublisher()
            } else {
                struct TestError: Error {}
                return Result.failure(TestError()).publisher.eraseToAnyPublisher()
            }
        }
        parent.pushViewController(authenticationCodeViewController, animated: false)
        return BasicAppController(rootViewController: parent)
    }
}

private struct TestError: Error {}
