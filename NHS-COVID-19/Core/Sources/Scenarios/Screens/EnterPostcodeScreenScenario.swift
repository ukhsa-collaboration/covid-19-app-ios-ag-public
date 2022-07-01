//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class EnterPostcodeScreenScenario: Scenario {
    public static let name = "Onboarding - Postcode district"
    public static let kind = ScenarioKind.screen

    public enum Postcodes: String {
        case invalid = "INV"
        case valid = "A1"
    }

    public static let continueConfirmationAlertTitle = "Entered Postcode"
    public static let errorDescription = "[Mock] The postcode you entered is not valid for this app."

    static var appController: AppController {

        return NavigationAppController { parent in
            EnterPostcodeViewController { postcode in
                switch postcode.uppercased() {
                case Self.Postcodes.invalid.rawValue:
                    return .failure(DisplayableError(testValue: Self.errorDescription))
                default:
                    parent.showAlert(title: Self.continueConfirmationAlertTitle, message: postcode)
                    return .success(())
                }
            }
        }
    }
}

private struct TestError: Error {}
