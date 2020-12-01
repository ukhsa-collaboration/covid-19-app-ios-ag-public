//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol PolicyUpdateViewControllerInteracting {
    func didTapContinue()
    func didTapTermsOfUse()
}

public class PolicyUpdateViewController: OnboardingStepViewController {
    public typealias Interacting = PolicyUpdateViewControllerInteracting
    
    public init(interactor: Interacting) {
        super.init(step: PolicyUpdateStep(interactor: interactor))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private class PolicyUpdateStep: NSObject, OnboardingStep {
    var footerContent = [UIView]()
    var strapLineStyle: LogoStrapline.Style? { .onboarding }
    
    public typealias Interacting = PolicyUpdateViewControllerInteracting
    private let interactor: Interacting
    
    private lazy var title: UILabel = {
        let label = UILabel()
        label.text = localize(.policy_update_title)
        label.styleAsPageHeader()
        return label
    }()
    
    let actionTitle = localize(.policy_update_button)
    let image: UIImage? = UIImage(.policy)
    
    init(interactor: Interacting) {
        self.interactor = interactor
    }
    
    func label(for localizationKey: StringLocalizationKey) -> UILabel {
        let label = UILabel()
        label.text = localize(localizationKey)
        return label
    }
    
    func stack(for labels: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: labels)
        stackView.axis = .vertical
        stackView.spacing = .halfSpacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .inner
        return stackView
    }
    
    var content: [UIView] {
        [
            stack(for: [title]),
            stack(for: localizeAndSplit(.policy_update_description).map { UILabel().styleAsBody().set(text: String($0)) }),
            stack(for: [LinkButton(
                title: localize(.terms_of_use_label),
                action: interactor.didTapTermsOfUse
            )]),
        ]
    }
    
    func act() {
        interactor.didTapContinue()
    }
}
