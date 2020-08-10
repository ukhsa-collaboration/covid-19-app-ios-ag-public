//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

extension UIView {
    
    public func addAutolayoutSubview(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
    }
    
    public func addFillingSubview(_ subview: UIView, inset: CGFloat = 0) {
        addAutolayoutSubview(subview)
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            subview.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset),
        ])
    }
    
}
