//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import UIKit

public protocol StickyFooterScrollingContent {
    var scrollingContent: StackContent { get }
    var footerContent: StackContent { get }
    var spacing: CGFloat { get }
}

class BasicStickyFooterScrollingContent: StickyFooterScrollingContent {
    var scrollingContent: StackContent
    var footerContent: StackContent
    var spacing: CGFloat
    
    init(scrollingViews: [UIView], footerTopView: UIView, footerBottomView: UIView? = nil) {
        scrollingContent = BasicContent(
            views: scrollingViews,
            spacing: .standardSpacing,
            margins: mutating(.largeInset) { $0.bottom = 0 }
        )
        
        footerContent = FooterContent(
            topView: footerTopView,
            bottomView: footerBottomView,
            spacing: .standardSpacing,
            margins: mutating(.largeInset) { $0.top = 0 }
        )
        
        spacing = .doubleSpacing
    }
}

class PrimaryButtonStickyFooterScrollingContent: BasicStickyFooterScrollingContent {
    init(scrollingViews: [UIView], primaryButton: (title: String, action: () -> Void)) {
        super.init(
            scrollingViews: scrollingViews,
            footerTopView: PrimaryButton(title: primaryButton.title, action: primaryButton.action)
        )
    }
}

public class StickyFooterScrollingContentView: UIView {
    
    private let scrollView: UIScrollView
    private let footerStack: UIStackView
    
    init(content: StickyFooterScrollingContent) {
        scrollView = UIScrollView(content: content.scrollingContent)
        footerStack = UIStackView(content: content.footerContent)
        
        super.init(frame: .zero)
        
        addAutolayoutSubview(scrollView)
        addAutolayoutSubview(footerStack)
        styleAsScreenBackground(with: traitCollection)
        
        setupKeyboardAppearance(pushedView: footerStack)
        scrollView.keyboardDismissMode = .onDrag
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            
            footerStack.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: content.spacing),
            
            footerStack.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor),
            footerStack.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor),
            footerStack.bottomAnchor.constraint(equalTo: readableContentGuide.bottomAnchor).withPriority(.defaultHigh),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if traitCollection.horizontalSizeClass == .compact {
            footerStack.axis = .vertical
            footerStack.distribution = .fill
        } else {
            footerStack.axis = .horizontal
            footerStack.distribution = .fillEqually
        }
    }
}

public class StickyFooterScrollingContentViewController: UIViewController {
    init(content: StickyFooterScrollingContent) {
        super.init(nibName: nil, bundle: nil)
        view = StickyFooterScrollingContentView(content: content)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
