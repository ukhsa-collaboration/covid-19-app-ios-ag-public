//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public class PermissionsViewController: OnboardingStepViewController {
    
    public init(submit: @escaping () -> Void) {
        super.init(step: PermissionsStep(submit: submit))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private class PermissionsStep: NSObject, OnboardingStep {
    var footerContent = [UIView]()
    
    private let submit: () -> Void
    
    private lazy var title: UILabel = {
        let label = UILabel()
        label.text = localize(.permissions_onboarding_step_title)
        label.styleAsPageHeader()
        return label
    }()
    
    let actionTitle = localize(.permissions_continue_button_title)
    let image: UIImage? = UIImage(.onboardingPermissions)
    
    init(submit: @escaping () -> Void) {
        self.submit = submit
    }
    
    func label(for localizationKey: StringLocalizationKey) -> UILabel {
        let label = UILabel()
        label.text = localize(localizationKey)
        return label
    }
    
    private var exposureNotificationHeading: UILabel { label(for: .exposure_notification_permissions_onboarding_step_heading).styleAsTertiaryTitle() }
    private var exposureNotificationBody: UILabel { label(for: .exposure_notification_permissions_onboarding_step_body).styleAsBody() }
    private var notificationsHeading: UILabel { label(for: .notification_permissions_onboarding_step_heading).styleAsTertiaryTitle() }
    private var notificationsBody: UILabel { label(for: .notification_permissions_onboarding_step_body).styleAsBody() }
    private var detail: UILabel { label(for: .permissions_onboarding_step_detail).styleAsBody() }
    
    var content: [UIView] {
        [
            title,
            exposureNotificationHeading,
            exposureNotificationBody,
            notificationsHeading,
            notificationsBody,
            detail,
        ]
    }
    
    func act() {
        submit()
    }
}
