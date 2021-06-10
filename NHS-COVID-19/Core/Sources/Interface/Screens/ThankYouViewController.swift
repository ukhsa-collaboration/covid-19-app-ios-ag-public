//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol ThankYouViewControllerInteracting {
    func action()
}

public class ThankYouViewController: UIViewController {
    public enum ViewType {
        case completed
        case stillNeedToBookATest
    }
    
    public static func viewController(for type: ViewType, interactor: Interacting) -> ThankYouViewController {
        switch type {
        case .completed:
            return ThankYouViewController(
                headingText: localize(.link_test_result_thank_you_title),
                buttonText: localize(.link_test_result_thank_you_back_home_button),
                interactor: interactor
            )
        case .stillNeedToBookATest:
            return ThankYouViewController(
                headingText: localize(.link_test_result_thank_you_title),
                buttonText: localize(.link_test_result_thank_you_continue_to_book_a_test_button),
                interactor: interactor
            )
        }
    }
    
    public typealias Interacting = ThankYouViewControllerInteracting
    
    let headingText: String
    let buttonText: String
    private var interactor: Interacting
    
    private init(
        headingText: String,
        buttonText: String,
        interactor: Interacting
    ) {
        self.headingText = headingText
        self.buttonText = buttonText
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    
    private let scrollView: UIView = UIScrollView()
    
    private let contentView: UIView = UIView()
    
    private lazy var titleLabel: UIView = {
        let titleLabel = BaseLabel().styleAsPageHeader().centralized()
        titleLabel.text = headingText
        return titleLabel
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(.tick)
        imageView.contentMode = .center
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 300),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
        ])
        return imageView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var actionButton: UIButton = {
        var button = UIButton()
        button.styleAsPrimary()
        button.setTitle(buttonText, for: .normal)
        button.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
        return button
    }()
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.styleAsScreenBackground(with: traitCollection)
        
        view.addAutolayoutSubview(scrollView)
        view.addAutolayoutSubview(actionButton)
        scrollView.addAutolayoutSubview(contentView)
        contentView.addAutolayoutSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: .standardSpacing),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            actionButton.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: .standardSpacing),
            actionButton.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor, constant: .standardSpacing),
            actionButton.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor, constant: -.standardSpacing),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.standardSpacing),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: .standardSpacing),
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
    
    @objc private func didTapActionButton() {
        interactor.action()
    }
}
