//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public protocol AuthorizationDeniedViewControllerInteracting {
    func didTapSettings()
}

public class AuthorizationDeniedViewController: RecoverableErrorViewController {
    
    public typealias Interacting = AuthorizationDeniedViewControllerInteracting
    
    private var interacting: Interacting
    
    public init(interacting: Interacting) {
        self.interacting = interacting
        super.init(error: AuthorizationErrorDetail(openSettings: interacting.didTapSettings))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private class AuthorizationErrorDetail: ErrorDetail {
    var action: (title: String, act: () -> Void)? {
        (localize(.authorization_denied_action), openSettings)
    }
    
    private let openSettings: () -> Void
    
    let title = localize(.authorization_denied_title)
    
    private lazy var descriptionLabel1: UIView = {
        let label = UILabel()
        label.styleAsBody()
        label.text = localize(.authorization_denied_description_1)
        return label
    }()
    
    private lazy var descriptionLabel2: UIView = {
        let label = UILabel()
        label.styleAsBody()
        label.text = localize(.authorization_denied_description_2)
        return label
    }()
    
    private lazy var descriptionLabel3: UIView = {
        let label = UILabel()
        label.styleAsBody()
        label.text = localize(.authorization_denied_description_3)
        return label
    }()
    
    public init(openSettings: @escaping () -> Void) {
        self.openSettings = openSettings
    }
    
    var content: [UIView] {
        [descriptionLabel1, descriptionLabel2, descriptionLabel3]
    }
}
