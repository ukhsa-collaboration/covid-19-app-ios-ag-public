//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public protocol LoadingErrorViewControllerInteracting {
    func didTapRetry()
    func didTapCancel()
}

public class LoadingErrorViewController: UIViewController {
    
    public typealias Interacting = LoadingErrorViewControllerInteracting
    
    private var interacting: Interacting
    
    public init(interacting: Interacting, title: String) {
        self.interacting = interacting
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func accessibilityPerformEscape() -> Bool {
        dismiss(animated: true, completion: nil)
        return true
    }
    
    private lazy var imageView: UIImageView = {
        UIImageView(.noCloud)
    }()
    
    private lazy var descriptionHeading: UIView = {
        let label = BaseLabel()
        label.styleAsHeading()
        label.text = localize(.loading_failed_heading)
        return label
    }()
    
    private lazy var descriptionLabel: UIView = {
        let label = BaseLabel()
        label.styleAsBody()
        label.text = localize(.loading_failed_body)
        return label
    }()
    
    private lazy var retryButton: UIButton = {
        let button = UIButton()
        button.styleAsPrimary()
        button.setTitle(localize(.loading_failed_action), for: .normal)
        button.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)
        return button
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: localize(.cancel), style: .done, target: self, action: #selector(didTapCancel))
        
        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)
        
        let stackView = UIStackView(arrangedSubviews: [imageView, descriptionHeading, descriptionLabel, retryButton])
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.layoutMargins = .standard
        stackView.spacing = .standardSpacing
        
        view.addAutolayoutSubview(stackView)
        
        NSLayoutConstraint.activate([
            retryButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            retryButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        UIAccessibility.post(notification: .screenChanged, argument: descriptionHeading)
    }
    
    @objc func didTapRetry() {
        interacting.didTapRetry()
    }
    
    @objc func didTapCancel() {
        interacting.didTapCancel()
    }
}
