//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public class BelowRequiredAgeErrorViewController: RecoverableErrorViewController {
    public init() {
        super.init(error: AppAvailabilityError(
            title: localize(.below_required_age_title),
            description: localize(.below_required_age_description)
        ))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

private struct AppAvailabilityError: ErrorDetail {
    var action: (title: String, act: () -> Void)? = nil
    let title: String
    let description: String?
    var logoStrapLineStyle: LogoStrapline.Style = .onboarding

    var content: [UIView] {
        [BaseLabel().styleAsBody().set(text: description)]
    }
}
