//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public class UnrecoverableErrorViewController: RecoverableErrorViewController {
    
    public init() {
        super.init(error: NonRecoverableErrorDetail())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private struct NonRecoverableErrorDetail: ErrorDetail {
    let action: (title: String, act: () -> Void)? = nil
    let actionTitle: String? = nil
    var logoStrapLineStyle: LogoStrapline.Style = .onboarding
    
    let title = localize(.unrecoverable_error_page_title)
    
    var content: [UIView] {
        let titleLabel = BaseLabel()
        titleLabel.styleAsHeading()
        titleLabel.text = localize(.unrecoverable_error_title)
        
        let descriptionLabel = BaseLabel()
        descriptionLabel.styleAsBody()
        descriptionLabel.text = localize(.unrecoverable_error_description)
        
        return [titleLabel, descriptionLabel]
    }
}
