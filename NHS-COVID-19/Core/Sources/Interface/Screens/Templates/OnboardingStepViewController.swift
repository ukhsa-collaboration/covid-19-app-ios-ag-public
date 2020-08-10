//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public protocol OnboardingStep {
    var image: UIImage? { get }
    var actionTitle: String { get }
    var content: [UIView] { get }
    var footerContent: [UIView] { get }
    func act()
}

open class OnboardingStepViewController: UIViewController {
    
    private let step: OnboardingStep
    
    public init(step: OnboardingStep) {
        self.step = step
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)
        
        let imageView = UIImageView(image: step.image)
        imageView.styleAsDecoration()
        imageView.isHidden = (step.image == nil)
        
        let logoStrapline = LogoStrapline(.nhsBlue, style: .onboarding)
        
        var content = step.content
        content.insert(imageView, at: 0)
        content.insert(logoStrapline, at: 0)
        
        let stackView = UIStackView(arrangedSubviews: content)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = .standardSpacing
        stackView.layoutMargins = .standard
        stackView.isLayoutMarginsRelativeArrangement = true
        
        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .onDrag
        scrollView.addFillingSubview(stackView)
        
        view.addAutolayoutSubview(scrollView)
        
        let keyboardIndicatingView = UIView()
        keyboardIndicatingView.isHidden = true
        view.addAutolayoutSubview(keyboardIndicatingView)
        
        let button = UIButton(type: .system)
        button.styleAsPrimary()
        button.setTitle(step.actionTitle, for: .normal)
        button.addTarget(self, action: #selector(didSelectAction), for: .touchUpInside)
        let footerStack = UIStackView(arrangedSubviews: [button] + step.footerContent)
        footerStack.axis = .vertical
        footerStack.spacing = .standardSpacing
        view.addAutolayoutSubview(footerStack)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: .standardSpacing),
            footerStack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -.standardSpacing),
            keyboardIndicatingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardIndicatingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            scrollView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            footerStack.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: .standardSpacing),
            footerStack.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).withPriority(.defaultHigh),
            footerStack.bottomAnchor.constraint(lessThanOrEqualTo: keyboardIndicatingView.topAnchor, constant: -.standardSpacing),
            keyboardIndicatingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        // This height will represent the portion of the view covered by a keyboard.
        // We can honour this constraint _almost_ always. However, this _could_ break temporarily before we get a chance
        // to respond, for example when device rotates. For this reason, reduce the priorty slightly.
        let keyboardHeightConstraint = keyboardIndicatingView.heightAnchor.constraint(equalToConstant: 0)
            .withPriority(.almostRequest)
        keyboardHeightConstraint.isActive = true
        
        for name in [UIApplication.keyboardWillHideNotification, UIApplication.keyboardWillShowNotification] {
            NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { notification in
                guard
                    let endFrame = notification.userInfo?[UIApplication.keyboardFrameEndUserInfoKey] as? CGRect
                else {
                    return
                }
                
                let curve = UIView.AnimationCurve(
                    rawValue: notification.userInfo?[UIApplication.keyboardAnimationCurveUserInfoKey] as? Int ?? 0
                )
                let duration = notification.userInfo?[UIApplication.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0
                
                UIView.animate(
                    withDuration: duration, delay: 0,
                    options: [.curve(from: curve ?? .easeInOut), .beginFromCurrentState],
                    animations: {
                        let frameInView = view.convert(endFrame, from: UIScreen.main.coordinateSpace)
                        keyboardHeightConstraint.constant = max(0, view.bounds.maxY - frameInView.minY)
                        view.layoutIfNeeded()
                    }, completion: nil
                )
            }
        }
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @objc private func didSelectAction() {
        step.act()
    }
}

private extension UIView.AnimationOptions {
    
    static func curve(from curve: UIView.AnimationCurve) -> UIView.AnimationOptions {
        switch curve {
        case .easeInOut:
            return .curveEaseInOut
        case .easeIn:
            return .curveEaseIn
        case .easeOut:
            return .curveEaseOut
        case .linear:
            return .curveLinear
        @unknown default:
            return .curveEaseInOut
        }
    }
    
}
