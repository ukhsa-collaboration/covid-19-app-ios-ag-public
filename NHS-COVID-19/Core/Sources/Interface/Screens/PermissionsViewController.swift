//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import UIKit

public class PermissionsViewController: OnboardingStepViewController {
    
    public init(country: InterfaceProperty<Country>, submit: @escaping () -> Void) {
        super.init(step: PermissionsStep(country: country, submit: submit))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private class PermissionsStep: NSObject, OnboardingStep {
    var footerContent = [UIView]()
    var strapLineStyle: LogoStrapline.Style? { .home(country.wrappedValue) }
    
    private let country: InterfaceProperty<Country>
    private let submit: () -> Void
    
    private lazy var title: UILabel = {
        let label = BaseLabel()
        label.text = localize(.permissions_onboarding_step_title)
        label.styleAsPageHeader()
        return label
    }()
    
    let actionTitle = localize(.permissions_continue_button_title)
    let image: UIImage? = UIImage(.onboardingPermissions)
    
    init(country: InterfaceProperty<Country>, submit: @escaping () -> Void) {
        self.country = country
        self.submit = submit
    }
    
    func label(for localizationKey: StringLocalizableKey) -> UILabel {
        let label = BaseLabel()
        label.text = localize(localizationKey)
        return label
    }
    
    func stack(for labels: [UILabel]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: labels)
        stackView.axis = .vertical
        stackView.spacing = .halfSpacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .inner
        return stackView
    }
    
    private var exposureNotificationHeading: UILabel { label(for: .exposure_notification_permissions_onboarding_step_heading).styleAsTertiaryTitle() }
    private var exposureNotificationBody: UILabel { label(for: .exposure_notification_permissions_onboarding_step_body).styleAsBody() }
    private var detail: UILabel { label(for: .permissions_onboarding_step_detail).styleAsBody() }
    
    var content: [UIView] {
        [
            stack(for: [title]),
            stack(for: [exposureNotificationHeading, exposureNotificationBody]),
            stack(for: [detail]),
        ]
    }
    
    func act() {
        submit()
    }
}
