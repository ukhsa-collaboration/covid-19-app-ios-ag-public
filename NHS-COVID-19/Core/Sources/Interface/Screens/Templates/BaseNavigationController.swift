//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public class BaseNavigationController: UINavigationController {
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        
        view.applySemanticContentAttribute()
    }
    
    override public init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        view.applySemanticContentAttribute()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
