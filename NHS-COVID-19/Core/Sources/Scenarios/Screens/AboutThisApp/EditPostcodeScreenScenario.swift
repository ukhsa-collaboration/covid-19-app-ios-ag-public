//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class EditPostcodeScreenScenario: Scenario {
    public static let name = "Edit postcode district"
    public static let kind = ScenarioKind.screen

    public enum Postcodes: String {
        case invalid = "INV"
        case valid = "A1"
    }

    public static let continueConfirmationAlertTitle = "Entered Postcode"
    public static let cancelTappedAlert = "Tapped Cancel"
    public static let errorDescription = "[Mock] The postcode you entered is not valid for this app."
    public static let primaryBtnTitle = "Save"

    static var appController: AppController {
        let parent = UINavigationController()
        parent.isNavigationBarHidden = true

        let interactor = EditPostcodeInteractor(
            savePostcode: { [weak parent] postcode in
                switch postcode.uppercased() {
                case Self.Postcodes.invalid.rawValue:
                    return .failure(DisplayableError(testValue: Self.errorDescription))
                default:
                    parent?.showAlert(title: Self.continueConfirmationAlertTitle, message: postcode)
                    return .success(())
                }
            },
            didTapCancel: {
                parent.showAlert(title: cancelTappedAlert)
            }
        )

        let postcodeViewController = EditPostcodeViewController(interactor: interactor, isLocalAuthorityEnabled: false)
        parent.pushViewController(postcodeViewController, animated: false)
        return BasicAppController(rootViewController: parent)
    }
}

private struct TestError: Error {}

private struct EditPostcodeInteractor: EditPostcodeViewController.Interacting {
    var savePostcode: (String) -> Result<Void, DisplayableError>
    var didTapCancel: () -> Void
}
