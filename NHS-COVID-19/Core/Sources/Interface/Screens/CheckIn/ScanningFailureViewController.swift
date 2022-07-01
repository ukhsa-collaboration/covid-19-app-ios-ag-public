//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public protocol ScanningFailureViewControllerInteracting {
    func goHome()
    func showHelp()
}

public class ScanningFailureViewController: CheckInStatusViewController {

    public typealias Interacting = ScanningFailureViewControllerInteracting

    private var interactor: Interacting

    public init(interactor: Interacting) {
        self.interactor = interactor
        super.init(status: ScanningFailureDetail(goHome: interactor.goHome, _showHelp: interactor.showHelp))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

private struct ScanningFailureDetail: StatusDetail {
    let icon = UIImage(.error)
    let title = localize(.checkin_scanning_failure_title)
    let explanation: String? = localize(.checkin_scanning_failure_description)
    let helpLink: String? = localize(.checkin_scanning_failure_help_link_text)
    let moreExplanation: String? = localize(.checkin_scanning_failure_more_description)
    let actionButtonTitle = localize(.checkin_scanning_failure_button_title)
    let goHome: () -> Void
    let _showHelp: () -> Void

    func act() {
        goHome()
    }

    func showHelp() {
        _showHelp()
    }
}
