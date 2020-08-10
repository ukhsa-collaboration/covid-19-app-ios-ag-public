//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {
    
    private let message: String
    
    init(title: String, message: String) {
        self.message = message
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.styleAsBody()
        label.textAlignment = .center
        label.text = message
        view.addFillingSubview(label)
    }
    
}
