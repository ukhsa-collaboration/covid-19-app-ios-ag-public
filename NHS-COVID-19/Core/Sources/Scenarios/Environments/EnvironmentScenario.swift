//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import Integration
import ProductionConfiguration

protocol EnvironmentScenario: Scenario {
    static var configuration: EnvironmentConfiguration { get }
}

extension EnvironmentScenario {
    static var kind: ScenarioKind { .environment }
    
    static var description: String? {
        """
        Distribution domain: \(configuration.distributionRemote.host)
        Submission domain: \(configuration.submissionRemote.host)
        """
    }
    
    static var appController: AppController {
        CoordinatedAppController(developmentWith: .standard(with: configuration))
    }
}
