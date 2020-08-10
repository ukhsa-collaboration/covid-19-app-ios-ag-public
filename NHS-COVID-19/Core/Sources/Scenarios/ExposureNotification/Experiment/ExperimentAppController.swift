//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import SwiftUI
import UIKit

class ExperimentAppController: AppController {
    
    let experimentManager = ExperimentManager()
    let rootViewController: UIViewController
    
    init() {
        let rootView = ExperimentView(experimentManager: experimentManager)
        rootViewController = UIHostingController(rootView: rootView)
    }
    
}

private struct ExperimentView: View {
    
    @ObservedObject
    var experimentManager: ExperimentManager
    
    var body: some View {
        if experimentManager.role == .lead {
            return AnyView(LeadHomeView(experimentManager: experimentManager))
        } else if experimentManager.role == .participant {
            return AnyView(ParticipantHomeView(experimentManager: experimentManager))
        } else {
            return AnyView(SelectRoleView(experimentManager: experimentManager))
        }
    }
    
}
