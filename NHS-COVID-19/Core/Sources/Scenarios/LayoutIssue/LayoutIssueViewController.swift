//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation
import Interface
import Localization
import UIKit

class LayoutIssueViewController: UIViewController {
    
    override func viewDidLoad() {
        let view = self.view!
        let scrollViewContent = UIStackView(content: PolicyUpdateContent.contentView)
        let scrollView = UIScrollView(content: scrollViewContent)
        
        view.addAutolayoutSubview(scrollView)
        view.styleAsScreenBackground(with: traitCollection)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollViewContent.widthAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.widthAnchor),
        ])
        
        NSLayoutConstraint.activate([
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollViewContent.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor),
        ])
        
        scrollViewContent.layoutMargins = UIEdgeInsets(
            top: .doubleSpacing,
            left: view.readableContentGuide.layoutFrame.minX - view.safeAreaLayoutGuide.layoutFrame.minX,
            bottom: .doubleSpacing,
            right: view.safeAreaLayoutGuide.layoutFrame.maxX - view.readableContentGuide.layoutFrame.maxX
        )
    }
    
}

private struct PolicyUpdateContent {
    static var contentView: UIView {
        var views = [
            LogoStrapline(.nhsBlue, style: .onboarding),
            UIImageView(.policy).styleAsDecoration(),
            UILabel().styleAsPageHeader().set(text: localize(.policy_update_title)),
        ]
        views.append(contentsOf: localizeAndSplit(.policy_update_description).map { UILabel().styleAsBody().set(text: String($0)) })
        views.append(LinkButton(
            title: localize(.terms_of_use_label),
            action: {}
        ))
        views.append(CustomButton(
            title: localize(.policy_update_button),
            action: {}
        ))
        
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = .standardSpacing
        
        return stackView
    }
}

private class CustomButton: UIButton {
    private let action: (() -> Void)?
    
    init(title: String, action: (() -> Void)?) {
        self.action = action
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        styleAsPrimary()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension UIStackView {
    convenience init(content: UIView) {
        self.init(arrangedSubviews: [content])
        axis = .vertical
        alignment = .fill
        distribution = .fill
        spacing = .standardSpacing
        layoutMargins = .zero
        isLayoutMarginsRelativeArrangement = true
    }
}

private extension UIScrollView {
    convenience init(content: UIView) {
        self.init(frame: .zero)
        
        addAutolayoutSubview(content)
        
        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor),
            content.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
        ])
    }
}
