//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public class BulletPointView: UIView {
    
    private var index: Int
    private var title: String
    
    private let bullet = UIView()
    
    public required init(index: Int, title: String) {
        self.index = index
        self.title = title
        super.init(frame: .zero)
        
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        backgroundColor = .clear
        isAccessibilityElement = true
        accessibilityTraits = .staticText
        accessibilityLabel = localize(.numbered_list_item(index: index, text: title))
        let indexLabel = UILabel()
        indexLabel.styleAsBody()
        indexLabel.text = String(index)
        indexLabel.textColor = .white
        indexLabel.textAlignment = .center
        NSLayoutConstraint.activate([
            indexLabel.heightAnchor.constraint(equalTo: indexLabel.widthAnchor, multiplier: 1),
            indexLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: .bulletPointSize),
        ])
        
        bullet.backgroundColor = UIColor(.nhsBlue)
        bullet.addFillingSubview(indexLabel)
        
        let titleLabel = UILabel()
        titleLabel.styleAsBody()
        titleLabel.text = title
        titleLabel.numberOfLines = 0
        
        let uiStackView = UIStackView(arrangedSubviews: [
            bullet,
            titleLabel,
        ])
        uiStackView.alignment = .top
        uiStackView.axis = .horizontal
        uiStackView.distribution = .fillProportionally
        uiStackView.spacing = .standardSpacing
        
        addFillingSubview(uiStackView)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        bullet.layoutIfNeeded()
        bullet.layer.cornerRadius = bullet.frame.width / 2.0
    }
    
}
