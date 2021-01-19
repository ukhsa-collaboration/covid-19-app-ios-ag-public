//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

public protocol OnboardingFlowViewControllerInteracting {
    func didTapPrivacyNotice()
    func didTapTermsOfUse()
    func didTapAgree()
}

public class OnboardingFlowViewController: BaseNavigationController {
    
    public typealias Interacting = OnboardingFlowViewControllerInteracting
    
    private enum State {
        case start
        case deniedAge
        case privacy
    }
    
    private let interactor: Interacting
    
    private var state = State.start {
        didSet {
            update(for: state)
        }
    }
    
    public init(interactor: Interacting) {
        self.interactor = interactor
        super.init()
        
        update(for: state)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func update(for state: State) {
        viewControllers = [
            rootViewController(for: state),
        ]
    }
    
    private func rootViewController(for state: State) -> UIViewController {
        switch state {
        case .start:
            return StartOnboardingViewController(
                complete: { [weak self] in self?.state = .privacy },
                reject: { [weak self] in self?.state = .deniedAge }
            )
        case .privacy:
            return PrivacyViewController(interactor: self)
        case .deniedAge:
            return BelowRequiredAgeErrorViewController()
        }
    }
}

extension OnboardingFlowViewController: PrivacyViewController.Interacting {
    public func didTapPrivacyNotice() {
        interactor.didTapPrivacyNotice()
    }
    
    public func didTapTermsOfUse() {
        interactor.didTapTermsOfUse()
    }
    
    public func didTapAgree() {
        interactor.didTapAgree()
    }
    
    public func didTapNoThanks() {
        state = .start
    }
}
