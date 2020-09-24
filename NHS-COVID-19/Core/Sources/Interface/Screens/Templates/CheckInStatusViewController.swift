//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public protocol StatusDetail {
    var title: String { get }
    var icon: UIImage { get }
    var explanation: String? { get }
    var helpLink: String? { get }
    var moreExplanation: String? { get }
    var actionButtonTitle: String { get }
    var explanationAligment: NSTextAlignment { get }
    var closeButtonTitle: String? { get }
    func act()
    func showHelp()
}

extension StatusDetail {
    var explanationAligment: NSTextAlignment {
        .center
    }
    
    var helpLink: String? { nil }
    var moreExplanation: String? { nil }
    var closeButtonTitle: String? {
        nil
    }
    
    func showHelp() {}
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
    
    private lazy var helpLinkButton: UIView? = {
        guard let helpLink = status.helpLink else {
            return nil
        }
        let button = UIButton()
        button.styleAsLink()
        button.setTitle(helpLink, for: .normal)
        button.addTarget(self, action: #selector(didTapHelpLink))
        button.accessibilityTraits = .link
        return button
    }()
    
    private lazy var moreExplanationLabel: UIView? = {
        guard let explanation = status.moreExplanation else {
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
        actionButton.translatesAutoresizingMaskIntoConstraints = false
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
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
        if let explainationLabel = explanationLabel {
            stackView.addArrangedSubview(explainationLabel)
        }
        if let helpLinkButton = helpLinkButton {
            stackView.addArrangedSubview(helpLinkButton)
        }
        if let moreExplanationLabel = moreExplanationLabel {
            stackView.addArrangedSubview(moreExplanationLabel)
        }
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = .standardSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    private let scrollView: UIView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.styleAsScreenBackground(with: traitCollection)
        
        status.closeButtonTitle.map { _ in
            self.setupCloseButton()
        }
        
        view.addSubview(scrollView)
        view.addSubview(actionButton)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: .standardSpacing),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            actionButton.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: .standardSpacing),
            actionButton.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor, constant: .standardSpacing),
            actionButton.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor, constant: -.standardSpacing),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.standardSpacing),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor, constant: .standardSpacing),
            stackView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor, constant: -.standardSpacing),
            
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).withPriority(.defaultLow),
            
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
    
    @objc private func didTapHelpLink() {
        status.showHelp()
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
