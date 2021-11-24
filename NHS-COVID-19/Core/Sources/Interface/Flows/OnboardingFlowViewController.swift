//
// Copyright © 2021 DHSC. All rights reserved.
//

import UIKit

public protocol OnboardingFlowViewControllerInteracting {
    func didTapPrivacyNotice()
    func didTapTermsOfUse()
    func didTapAgree()
}

public class OnboardingFlowViewController: BaseNavigationController {
    
    public typealias Interacting = OnboardingFlowViewControllerInteracting
    
    fileprivate enum State {
        case start
        case deniedAge
        case howAppWorks
        case privacy
    }
    
    private let interactor: Interacting
    private let useWithoutBluetooth: Bool
    
    fileprivate var state = State.start {
        didSet {
            update(for: state)
        }
    }
    
    public init(interactor: Interacting, useWithoutBluetooth: Bool) {
        self.interactor = interactor
        self.useWithoutBluetooth = useWithoutBluetooth
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
                complete: { [weak self] in
                    if self?.useWithoutBluetooth ?? false {
                        self?.state = .howAppWorks
                    } else {
                        self?.state = .privacy
                    }
                },
                reject: { [weak self] in self?.state = .deniedAge }
            )
        case .howAppWorks:
            return HowAppWorksViewController(interactor: HowAppWorksInteractor(controller: self))
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

struct HowAppWorksInteractor: HowAppWorksViewController.Interacting {
    private weak var viewController: OnboardingFlowViewController?
    
    init(controller: OnboardingFlowViewController?) {
        viewController = controller
    }
    
    func didTapContinueButton() {
        viewController?.state = .privacy
    }
}
