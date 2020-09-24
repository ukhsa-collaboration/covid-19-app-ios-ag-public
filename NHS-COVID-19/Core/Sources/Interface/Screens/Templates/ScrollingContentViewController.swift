//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

public class ScrollingContentViewController: UIViewController {
    init(content: StackContent) {
        super.init(nibName: nil, bundle: nil)
        view = ScrollingContentView(content: content)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
