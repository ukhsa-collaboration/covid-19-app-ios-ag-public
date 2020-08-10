//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import Integration

public class SandboxedScenario: Scenario {
    public static let name = "Sandboxed"
    public static let nameForSorting = "0.1"
    public static let kind = ScenarioKind.environment
    
    static var description: String? {
        """
        An ephemeral, in-app mock environment.
        You can use “Configure Mocks” home screen shortcut to modify server responses.
        """
    }
    
    static var appController: AppController {
        SandboxedAppController()
    }
}
