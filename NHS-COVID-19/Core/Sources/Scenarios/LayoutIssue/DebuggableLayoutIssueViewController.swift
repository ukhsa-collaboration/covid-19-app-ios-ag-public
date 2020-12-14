//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import UIKit

class DebuggableLayoutIssueViewController: UIViewController {
    
    override func viewDidLoad() {
        let view = self.view!
        
        let height: CGFloat = UIScreen.main.bounds.height
        let inset: CGFloat = 32
        
        // 1. Create the content
        //
        // Note, the exact value of the `Box`’s height matters.
        // * A larger box height no longer causes the issue.
        // * A smaller box height makes the constraints in this barebone scenario invalid; although that is not
        //   necessarily the case in a more complext layout where the Box height isn't fully fixed.
        let content = CustomStackView(arrangedSubviews: [
            Box(height: height - inset * 2, fill: .systemBlue),
        ])
        content.isLayoutMarginsRelativeArrangement = true
        content.layoutMargins = UIEdgeInsets(
            top: inset,
            left: 0,
            bottom: inset,
            right: 0
        )
        
        // 2. Create a scroll view
        let scrollView = CustomScrollView()
        
        // 3. Connect subviews
        [scrollView, content].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        scrollView.addSubview(content)
        view.addSubview(scrollView)
        
        // 4. Manage constraints
        
        // 4.1 Add horizontal constraints (these _should_ be unrelated to the bug)
        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            content.widthAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.widthAnchor),
        ])
        
        // 4.2 Add vertical constraints
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            content.heightAnchor.constraint(greaterThanOrEqualToConstant: height),
        ])
        
        // 5. Disabling `contentInsetAdjustmentBehavior` addresses the issue.
//        scrollView.contentInsetAdjustmentBehavior = .never
        
    }
    
}

// Note: Subclassing `UIStackView` is not necessary to reproduce the bug. It's purely used for debugging
private class CustomStackView: UIStackView {}

// Note: Subclassing `UIScrollView` is not necessary to reproduce the bug. It's purely used for debugging
private class CustomScrollView: UIScrollView {
    
    var counter = 0
    
    override func layoutSubviews() {
        if isScrolling { counter = 0 }
        guard counter < 100 else { exit(0) }
        counter += 1
        super.layoutSubviews()
    }
    
    var isScrolling: Bool {
        isDragging || isDecelerating
    }
    
}

private class Box: UIView {
    
    init(height: CGFloat, fill: UIColor) {
        super.init(frame: .zero)
        
        backgroundColor = fill
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
