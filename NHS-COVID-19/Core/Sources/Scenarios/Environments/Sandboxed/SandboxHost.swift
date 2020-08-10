//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

class SandboxHost {
    private(set) weak var container: UIViewController?
    let initialState: Sandbox.InitialState
    
    init(container: UIViewController, initialState: Sandbox.InitialState) {
        self.container = container
        self.initialState = initialState
    }
}
