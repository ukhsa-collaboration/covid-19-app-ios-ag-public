//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String, message: String? = nil, preferredStyle: UIAlertController.Style = .alert) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
