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
    
    init(scrollingViews: [StackViewContentProvider], footerTopView: UIView, footerBottomView: UIView? = nil) {
        scrollingContent = BasicContent(
            views: scrollingViews,
            spacing: .standardSpacing,
            margins: mutating(.zero) { $0.bottom = 0 }
        )
        
        footerContent = FooterContent(
            topView: footerTopView,
            bottomView: footerBottomView,
            spacing: .standardSpacing,
            margins: mutating(.zero) { $0.top = 0 }
        )
        
        spacing = .doubleSpacing
    }
}

class PrimaryButtonStickyFooterScrollingContent: BasicStickyFooterScrollingContent {
    init(scrollingViews: [StackViewContentProvider], primaryButton: (title: String, action: () -> Void)) {
        super.init(
            scrollingViews: scrollingViews,
            footerTopView: PrimaryButton(title: primaryButton.title, action: primaryButton.action)
        )
    }
}

public class StickyFooterScrollingContentView: UIView {
    
    private let scrollView: UIScrollView
    private let footerStack: UIStackView
    private let scrollingStack: UIStackView
    
    init(content: StickyFooterScrollingContent) {
        scrollingStack = UIStackView(content: content.scrollingContent)
        scrollView = UIScrollView(stackView: scrollingStack)
        footerStack = UIStackView(content: content.footerContent)
        
        super.init(frame: .zero)
        
        addAutolayoutSubview(scrollView)
        addAutolayoutSubview(footerStack)
        styleAsScreenBackground(with: traitCollection)
        
        setupKeyboardAppearance(pushedView: footerStack)
        scrollView.keyboardDismissMode = .onDrag
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            
            scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            
            footerStack.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: content.spacing),
            
            footerStack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            footerStack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            footerStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).withPriority(.defaultHigh),
            
            scrollingStack.widthAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.widthAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let margins: UIEdgeInsets
        if traitCollection.horizontalSizeClass == .compact {
            footerStack.axis = .vertical
            footerStack.distribution = .fill
            
            margins = .largeInset
        } else {
            footerStack.axis = .horizontal
            footerStack.distribution = .fillEqually
            
            margins = UIEdgeInsets(
                top: .doubleSpacing,
                left: readableContentGuide.layoutFrame.minX - safeAreaLayoutGuide.layoutFrame.minX,
                bottom: .doubleSpacing,
                right: safeAreaLayoutGuide.layoutFrame.maxX - readableContentGuide.layoutFrame.maxX
            )
        }
        
        scrollingStack.layoutMargins = mutating(margins) { $0.bottom = 0 }
        footerStack.layoutMargins = mutating(margins) { $0.top = 0 }
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
