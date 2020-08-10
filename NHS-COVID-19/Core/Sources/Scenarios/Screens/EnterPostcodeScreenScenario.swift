//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class EnterPostcodeScreenScenario: Scenario {
    public static let name = "On-boarding - Postcode district"
    public static let kind = ScenarioKind.screen
    
    public enum Postcodes: String {
        case invalid = "INV"
        case valid = "A1"
    }
    
    public static let continueConfirmationAlertTitle = "Entered Postcode"
    
    static var appController: AppController {
        let parent = UINavigationController()
        parent.isNavigationBarHidden = true
        let postcodeViewController = EnterPostcodeViewController { [weak parent] postcode in
            switch postcode.uppercased() {
            case Self.Postcodes.invalid.rawValue:
                return .failure(TestError())
            default:
                parent?.showAlert(title: Self.continueConfirmationAlertTitle, message: postcode)
                return .success(())
            }
        }
        parent.pushViewController(postcodeViewController, animated: false)
        return BasicAppController(rootViewController: parent)
    }
}

private struct TestError: Error {}
