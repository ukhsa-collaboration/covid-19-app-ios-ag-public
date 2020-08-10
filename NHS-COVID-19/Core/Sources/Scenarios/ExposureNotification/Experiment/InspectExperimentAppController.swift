//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import SwiftUI
import UIKit

class InspectExperimentAppController: AppController {
    
    let experimentManager = ExperimentManager()
    let rootViewController: UIViewController
    
    init() {
        let rootView = SelectExperimentView(experimentManager: experimentManager)
        rootViewController = UIHostingController(rootView: rootView)
    }
    
}
