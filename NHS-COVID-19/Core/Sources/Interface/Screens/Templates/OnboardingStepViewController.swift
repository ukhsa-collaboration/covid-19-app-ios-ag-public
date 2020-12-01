//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public struct OnboardingStepAlert {
    var title: StringLocalizationKey
    var body: StringLocalizationKey
    var accept: StringLocalizationKey
    var reject: StringLocalizationKey
    var rejectAction: () -> Void
}

public protocol OnboardingStep {
    var strapLineStyle: LogoStrapline.Style? { get }
    typealias Alert = OnboardingStepAlert
    
    var alert: Alert? { get }
    var image: UIImage? { get }
    var actionTitle: String { get }
    var content: [UIView] { get }
    var footerContent: [UIView] { get }
    func act()
}

public extension OnboardingStep {
    var strapLineStyle: LogoStrapline.Style? { .onboarding }
    var alert: Alert? { nil }
    
    func stack(for labels: [UILabel], spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: labels)
        stackView.axis = .vertical
        stackView.spacing = spacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .inner
        return stackView
    }
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
        
        var content = step.content
        content.insert(imageView, at: 0)
        
        if let style = step.strapLineStyle {
            content.insert(LogoStrapline(.nhsBlue, style: style), at: 0)
        }
        
        let stackView = UIStackView(arrangedSubviews: content)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = .standardSpacing
        stackView.layoutMargins = UIEdgeInsets(top: .standardSpacing, left: 0, bottom: .standardSpacing, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        let scrollView = UIScrollView()
        scrollView.addFillingSubview(stackView)
        
        view.addAutolayoutSubview(scrollView)
        
        let button = UIButton(type: .system)
        button.styleAsPrimary()
        button.setTitle(step.actionTitle, for: .normal)
        button.addTarget(self, action: #selector(didSelectAction), for: .touchUpInside)
        let footerStack = UIStackView(arrangedSubviews: [button] + step.footerContent)
        footerStack.axis = .vertical
        footerStack.spacing = .standardSpacing
        view.addAutolayoutSubview(footerStack)
        
        // Setup keyboard
        view.setupKeyboardAppearance(pushedView: footerStack)
        scrollView.keyboardDismissMode = .onDrag
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            footerStack.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor, constant: .standardSpacing),
            footerStack.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor, constant: -.standardSpacing),
            
            stackView.widthAnchor.constraint(equalTo: view.readableContentGuide.widthAnchor),
            
            scrollView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            footerStack.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: .standardSpacing),
            footerStack.bottomAnchor.constraint(equalTo: view.readableContentGuide.bottomAnchor).withPriority(.defaultHigh),
        ])
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @objc private func didSelectAction() {
        guard let alert = step.alert else {
            step.act()
            return
        }
        
        let alertController = UIAlertController(
            title: localize(alert.title),
            message: localize(alert.body),
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(
            title: localize(alert.reject),
            style: .cancel,
            handler: { _ in alert.rejectAction() }
        ))
        
        let acceptAction = UIAlertAction(
            title: localize(alert.accept),
            style: .default,
            handler: { [weak self] _ in self?.step.act() }
        )
        
        alertController.addAction(acceptAction)
        alertController.preferredAction = acceptAction
        
        present(alertController, animated: true)
    }
}
