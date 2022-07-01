//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

public protocol StackViewContentProvider {
    var content: [UIView] { get }
}

extension UIView: StackViewContentProvider {
    public var content: [UIView] {
        return [self]
    }
}

extension Array: StackViewContentProvider where Element == UIView {
    public var content: [UIView] {
        return self
    }
}

public protocol StackContent {
    var views: [StackViewContentProvider] { get }
    var spacing: CGFloat { get }
    var margins: UIEdgeInsets { get }
}

struct BasicContent: StackContent {
    var views: [StackViewContentProvider]
    var spacing: CGFloat
    var margins: UIEdgeInsets
}

struct FooterContent: StackContent {
    var topView: UIView
    var bottomView: UIView?
    var views: [StackViewContentProvider] {
        [topView, bottomView].compactMap { $0 }
    }

    var spacing: CGFloat
    var margins: UIEdgeInsets
}

extension UIStackView {
    convenience init(content: StackContent) {
        self.init(arrangedSubviews: content.views.flatMap { $0.content })
        axis = .vertical
        alignment = .fill
        distribution = .fill
        spacing = content.spacing
        layoutMargins = content.margins
        isLayoutMarginsRelativeArrangement = true
    }
}

extension UIScrollView {
    convenience init(stackView: UIStackView) {
        self.init(frame: .zero)

        addAutolayoutSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
        ])
    }
}

extension UIScrollView {
    convenience init(content: StackContent) {
        self.init(stackView: UIStackView(content: content))
    }
}
