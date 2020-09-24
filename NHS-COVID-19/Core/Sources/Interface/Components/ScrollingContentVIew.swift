//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import UIKit

public class ScrollingContentView: UIView {
    init(content: StackContent) {
        super.init(frame: .zero)
        
        styleAsScreenBackground(with: traitCollection)
        let scrollView = UIScrollView()
        let stackView = UIStackView(content: content)
        scrollView.addAutolayoutSubview(stackView)
        addAutolayoutSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: scrollView.readableContentGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.readableContentGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
