//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public protocol StatusDetail {
    var title: String { get }
    var icon: UIImage { get }
    var explanation: String? { get }
    var actionButtonTitle: String { get }
    var explanationAligment: NSTextAlignment { get }
    var closeButtonTitle: String? { get }
    func act()
}

extension StatusDetail {
    var explanationAligment: NSTextAlignment {
        .center
    }
    
    var closeButtonTitle: String? {
        nil
    }
}

open class CheckInStatusViewController: UIViewController {
    
    private let status: StatusDetail
    
    private lazy var imageView: UIView = {
        let imageView = UIImageView(image: status.icon)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel: UIView = {
        let titleLabel = UILabel()
        titleLabel.styleAsPageHeader()
        titleLabel.text = status.title
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    private lazy var explanationLabel: UIView? = {
        guard let explanation = status.explanation else {
            return nil
        }
        let explanationLabel = UILabel()
        explanationLabel.styleAsBody()
        explanationLabel.text = explanation
        explanationLabel.textAlignment = status.explanationAligment
        return explanationLabel
    }()
    
    private lazy var actionButton: UIView = {
        let actionButton = UIButton(type: .system)
        actionButton.styleAsPrimary()
        actionButton.setTitle(status.actionButtonTitle, for: .normal)
        actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
        return actionButton
    }()
    
    private func setupCloseButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: status.closeButtonTitle, style: .done, target: self, action: #selector(closeButtonTapped))
    }
    
    public init(status: StatusDetail) {
        self.status = status
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)
        
        status.closeButtonTitle.map { _ in
            self.setupCloseButton()
        }
        
        var content: [UIView] = [imageView, titleLabel]
        if let explanationLabel = explanationLabel {
            content.append(explanationLabel)
        }
        
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        
        let stackViewContainerView = UIView()
        
        view.addSubview(scrollView)
        scrollView.addFillingSubview(stackViewContainerView)
        
        view.addAutolayoutSubview(scrollView)
        
        let stackView = UIStackView(arrangedSubviews: content)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.layoutMargins = .standard
        stackView.spacing = .standardSpacing
        
        let stackViewContainerViewHeightConstraint = stackViewContainerView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, constant: 0.0)
        stackViewContainerViewHeightConstraint.priority = .defaultLow
        
        stackViewContainerView.addAutolayoutSubview(stackView)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        view.addAutolayoutSubview(stackView)
        NSLayoutConstraint.activate([
            stackViewContainerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: 0.0),
            
            stackView.centerYAnchor.constraint(equalTo: stackViewContainerView.centerYAnchor, constant: 0.0),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: stackViewContainerView.topAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: stackViewContainerView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: stackViewContainerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: stackViewContainerView.trailingAnchor),
            
            stackViewContainerViewHeightConstraint,
        ])
        
        view.addAutolayoutSubview(actionButton)
        NSLayoutConstraint.activate([
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .standardSpacing),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.standardSpacing),
            actionButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -.standardSpacing),
        ])
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: actionButton.topAnchor),
        ])
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = (status.closeButtonTitle == nil)
    }
    
    override public func accessibilityPerformEscape() -> Bool {
        dismiss(animated: true, completion: nil)
        return true
    }
    
    @objc private func didTapActionButton() {
        status.act()
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
