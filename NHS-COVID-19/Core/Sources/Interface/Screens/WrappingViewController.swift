//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import UIKit

public class WrappingViewController: UIViewController {
    
    private var cancellable: AnyCancellable?
    
    private var content: UIViewController? {
        didSet {
            if let presentedViewController = oldValue?.presentedViewController, presentedViewController.modalPresentationStyle != .overFullScreen {
                oldValue?.dismiss(animated: true, completion: nil)
            }
            oldValue?.remove()
            if let content = content {
                addFilling(content)
                UIAccessibility.post(notification: .screenChanged, argument: nil)
            }
        }
    }
    
    public init<P: Publisher>(content: () -> P) where P.Output == UIViewController, P.Failure == Never {
        super.init(nibName: nil, bundle: nil)
        cancellable = content().sink { [weak self] content in
            self?.content = content
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
