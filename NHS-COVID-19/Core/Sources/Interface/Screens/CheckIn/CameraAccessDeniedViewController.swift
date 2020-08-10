//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public protocol CameraAccessDeniedViewControllerInteracting {
    func openSettings()
}

public class CameraAccessDeniedViewController: CheckInStatusViewController {
    
    public typealias Interacting = CameraAccessDeniedViewControllerInteracting
    
    private var interactor: Interacting
    
    public init(interactor: Interacting) {
        self.interactor = interactor
        super.init(status: CameraAccessDeniedDetail(openSettings: interactor.openSettings))
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private struct CameraAccessDeniedDetail: StatusDetail {
    let icon = UIImage(.camera)
    let title = localize(.checkin_camera_permission_denial_title)
    let explanation: String? = localize(.checkin_camera_permission_denial_explanation)
    let actionButtonTitle = localize(.checkin_open_settings_button_title)
    let openSettings: () -> Void
    let closeButtonTitle: String? = localize(.checkin_camera_permission_close_button_title)
    
    func act() {
        openSettings()
    }
}
