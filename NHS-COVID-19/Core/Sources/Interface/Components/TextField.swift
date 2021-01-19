//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

class TextField: BaseTextField {
    private let process: (String) -> String
    
    init(process: @escaping (String) -> String) {
        self.process = process
        super.init()
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        borderStyle = .roundedRect
        layer.borderWidth = 2
        layer.borderColor = UIColor(.secondaryText).cgColor
        font = UIFont.preferredFont(forTextStyle: .body)
        adjustsFontForContentSizeCategory = true
        autocorrectionType = .no
        enablesReturnKeyAutomatically = true
        NSLayoutConstraint.activate([heightAnchor.constraint(greaterThanOrEqualToConstant: .hitAreaMinHeight)])
        
        addTarget(self, action: #selector(valueChanged), for: .editingChanged)
    }
    
    @objc private func valueChanged() {
        let originalLength = text?.count
        text = text.map(process)
        
        if originalLength != text?.count {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.selectedTextRange = self.textRange(from: self.endOfDocument, to: self.endOfDocument)
            }
        }
    }
}
