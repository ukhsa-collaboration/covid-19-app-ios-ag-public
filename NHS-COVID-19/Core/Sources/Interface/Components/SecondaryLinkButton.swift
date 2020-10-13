//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

class SecondaryButton: UIButton {
    private let action: (() -> Void)?
    
    init(title: String, action: (() -> Void)?) {
        self.action = action
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        styleAsSecondary()
        addTarget(self, action: #selector(act))
    }
    
    @objc private func act() {
        action?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
