//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

public protocol StackContent {
    var views: [UIView] { get }
    var spacing: CGFloat { get }
    var margins: UIEdgeInsets { get }
}

struct BasicContent: StackContent {
    var views: [UIView]
    var spacing: CGFloat
    var margins: UIEdgeInsets
}

struct FooterContent: StackContent {
    var topView: UIView
    var bottomView: UIView?
    var views: [UIView] {
        [topView, bottomView].compactMap { $0 }
    }
    
    var spacing: CGFloat
    var margins: UIEdgeInsets
}

extension UIStackView {
    convenience init(content: StackContent) {
        self.init(arrangedSubviews: content.views)
        axis = .vertical
        alignment = .fill
        distribution = .fill
        spacing = content.spacing
        layoutMargins = content.margins
        isLayoutMarginsRelativeArrangement = true
    }
}

extension UIScrollView {
    convenience init(content: StackContent) {
        self.init(frame: .zero)
        
        let stackView = UIStackView(content: content)
        addFillingSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalTo: widthAnchor),
        ])
    }
}
