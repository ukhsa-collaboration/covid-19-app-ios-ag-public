//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import UIKit

public class StartOnboardingViewController: OnboardingStepViewController {
    
    public init(complete: @escaping () -> Void,
                reject: @escaping () -> Void,
                shouldShowVenueCheckIn: Bool) {
        super.init(step: StartOnboardingStep(accept: complete, reject: reject, shouldShowVenueCheckIn: shouldShowVenueCheckIn))
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class StartOnboardingStep: OnboardingStep {
    private let accept: () -> Void
    private let shouldShowVenueCheckIn: Bool
    fileprivate let alert: Alert?
    
    private lazy var title: UILabel = {
        let label = BaseLabel()
        label.text = localize(.start_onboarding_step_title)
        label.styleAsPageHeader()
        return label
    }()
    
    let actionTitle = localize(.start_onboarding_button_title)
    let image: UIImage? = UIImage(.onboardingStart)
    
    init(accept: @escaping () -> Void,
         reject: @escaping () -> Void,
         shouldShowVenueCheckIn: Bool) {
        self.accept = accept
        self.shouldShowVenueCheckIn = shouldShowVenueCheckIn
        alert = Alert(
            title: .age_confirmation_alert_title,
            body: .age_confirmation_alert_body,
            accept: .age_confirmation_alert_accept,
            reject: .age_confirmation_alert_reject,
            rejectAction: reject
        )
    }
    
    private lazy var stepDescription1: UIView = {
        WelcomePoint(image: .welcomeNotification, header: localize(.start_onboarding_step_1_header), body: localize(.start_onboarding_step_1_description))
    }()
    
    private lazy var stepDescription2: UIView = {
        WelcomePoint(image: .qrCode, header: localize(.start_onboarding_step_2_header), body: localize(.start_onboarding_step_2_description))
    }()
    
    private lazy var stepDescription3: UIView = {
        WelcomePoint(image: .thermometer, header: localize(.start_onboarding_step_3_header), body: localize(.start_onboarding_step_3_description))
    }()
    
    private lazy var stepDescription4: UIView = {
        WelcomePoint(image: .welcomeCountdown, header: localize(.start_onboarding_step_4_header), body: localize(.start_onboarding_step_4_description))
    }()
    
    private lazy var subtitle: UILabel = {
        let label = BaseLabel()
        label.text = localize(.start_onboarding_step_subtitle)
        label.styleAsBody()
        return label
    }()
    
    var footerContent = [UIView]()
    
    var content: [UIView] {
        
        let titles = [title, subtitle]
        
        let steps = shouldShowVenueCheckIn
            ? [stepDescription1, stepDescription2, stepDescription3, stepDescription4]
            : [stepDescription1, stepDescription3, stepDescription4]
        
        let stackView = UIStackView(arrangedSubviews: titles + steps)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = .standardSpacing
        stackView.layoutMargins = .inner
        stackView.isLayoutMarginsRelativeArrangement = true
        return [stackView]
    }
    
    func act() {
        accept()
    }
}
