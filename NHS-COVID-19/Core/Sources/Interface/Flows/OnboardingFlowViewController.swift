//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

public protocol OnboardingFlowViewControllerInteracting {
    func requestPermissions()
    func didTapPrivacyNotice()
    func didTapTermsOfUse()
}

public class OnboardingFlowViewController: UINavigationController {
    
    public typealias Interacting = OnboardingFlowViewControllerInteracting
    
    private enum State {
        case start
        case privacy
        case permissions
    }
    
    private let interactor: Interacting
    
    private var state = State.start {
        didSet {
            update(for: state)
        }
    }
    
    public init(interactor: Interacting) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
        
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
                complete: { [weak self] in
                    guard let self = self else { return }
                    self.state = .privacy
                }
            )
        case .privacy:
            return PrivacyViewController(interactor: self)
        case .permissions:
            return PermissionsViewController { [weak self] in
                guard let self = self else { return }
                self.interactor.requestPermissions()
            }
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
        state = .permissions
    }
    
    public func didTapNoThanks() {
        state = .start
    }
}
