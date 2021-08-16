//
// Copyright © 2021 DHSC. All rights reserved.
//

import Integration
import Interface
import SwiftUI
import UIKit

@available(iOSApplicationExtension, unavailable)
class InspectExperimentAppController: AppController {
    
    let experimentManager = ExperimentManager()
    let rootViewController: UIViewController
    
    init() {
        let rootView = SelectExperimentView(experimentManager: experimentManager)
        rootViewController = UIHostingController(rootView: rootView)
    }
    
}
