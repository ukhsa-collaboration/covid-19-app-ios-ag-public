//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public class OnboardingBulletPointView: UIView {
    
    public var titles: [String]?
    
    public required init(titles: [String]) {
        self.titles = titles
        super.init(frame: .zero)
        
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        
        backgroundColor = .clear
        
        titles.map { titles in
            var views = [UIView]()
            for (index, title) in titles.enumerated() {
                let bullet = BulletPointView(index: index + 1, title: title)
                views.append(bullet)
            }
            
            let verticalStack = UIStackView(arrangedSubviews: views)
            verticalStack.axis = .vertical
            verticalStack.spacing = .bigSpacing
            
            addFillingSubview(verticalStack)
        }
    }
}
