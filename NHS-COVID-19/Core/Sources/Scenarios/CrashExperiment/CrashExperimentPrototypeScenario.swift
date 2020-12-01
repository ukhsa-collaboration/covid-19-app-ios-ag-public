//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import SwiftUI
import UIKit

public class CrashExperimentPrototypeScenario: Scenario {
    public static let name = "Crash Experiment"
    public static let kind = ScenarioKind.prototype
    
    static var appController: AppController {
        BasicAppController(
            rootViewController: UIHostingController(
                rootView: CrashExperimentView()
            )
        )
    }
}

private struct CrashExperimentView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button("Crash Me") {
                    fatalError("CrashExperimentPrototypeScenario crashed")
                }
                Spacer()
            }
            Spacer()
        }
    }
}
