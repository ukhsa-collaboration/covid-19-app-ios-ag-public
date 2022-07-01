//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Integration
import Interface
import UIKit

public class CheckInConfirmationScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "CheckIn - Confirmation"

    public static let didTapVenueCheckinMoreInfo = "Venue checkin more info tapped!"
    public static let didTapGoHome = "Back to home tapped!"
    public static let didTapWrongCheckIn = "Cancel this check-in tapped!"

    public static let venueName = "The Drapers Arms"
    public static let checkinDate = UTCHour(year: 2020, month: 7, day: 9, hour: 19, minutes: 30).date

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            parent.navigationBar.isHidden = true
            let interactor = Interactor(viewController: parent)
            return CheckInConfirmationViewController(
                interactor: interactor,
                checkInDetail: CheckInDetail(
                    venueName: Self.venueName,
                    removeCurrentCheckIn: {}
                ),
                date: Self.checkinDate
            )
        }
    }
}

private class Interactor: CheckInConfirmationViewController.Interacting {
    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func goHomeAfterCheckIn() {
        viewController?.showAlert(title: CheckInConfirmationScreenScenario.didTapGoHome)
    }

    func wrongCheckIn() {
        viewController?.showAlert(title: CheckInConfirmationScreenScenario.didTapWrongCheckIn)
    }

    func didTapVenueCheckinMoreInfoButton() {
        viewController?.showAlert(title: CheckInConfirmationScreenScenario.didTapVenueCheckinMoreInfo)
    }
}
