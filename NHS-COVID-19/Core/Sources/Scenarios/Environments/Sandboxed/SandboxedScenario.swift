//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import Integration

@available(iOSApplicationExtension, unavailable)
public class SandboxedScenario: Scenario {
    public static let initialStateEnvironmentKey = "initialState"
    public static let name = "Sandboxed"
    public static let nameForSorting = "0.1"
    public static let kind = ScenarioKind.environment

    static var description: String? {
        """
        An ephemeral, in-app mock environment.
        You can use “Configure Mocks” home screen shortcut to modify server responses.
        """
    }

    public static var defaultInputs: Sandbox.InitialState {
        .init()
    }

    static var appController: AppController {
        let initialState = ProcessInfo.processInfo.environment[initialStateEnvironmentKey]
            .flatMap { Data(base64Encoded: $0) }
            .flatMap { try? JSONDecoder().decode(Sandbox.InitialState.self, from: $0) }
        return SandboxedAppController(initialState: initialState ?? Sandbox.InitialState())
    }
}
