//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol AuthorizationDeniedViewControllerInteracting {
    func didTapSettings()
}

public class AuthorizationDeniedViewController: RecoverableErrorViewController {
    
    public typealias Interacting = AuthorizationDeniedViewControllerInteracting
    
    private var interacting: Interacting
    
    public init(interacting: Interacting, country: Country) {
        self.interacting = interacting
        super.init(error: AuthorizationErrorDetail(country: country, openSettings: interacting.didTapSettings))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private class AuthorizationErrorDetail: ErrorDetail {
    private let country: Country
    
    var action: (title: String, act: () -> Void)? {
        (localize(.authorization_denied_action), openSettings)
    }
    
    var logoStrapLineStyle: LogoStrapline.Style { .home(country) }
    
    private let openSettings: () -> Void
    
    let title = localize(.authorization_denied_title)
    
    public init(country: Country, openSettings: @escaping () -> Void) {
        self.country = country
        self.openSettings = openSettings
    }
    
    var content: [UIView] {
        localizeAndSplit(.authorization_denied_description).map { UILabel().set(text: $0).styleAsBody() }
    }
}
