//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Foundation
import Integration

public class MockScenario: Scenario {
    public static let name = "Mock"
    public static let nameForSorting = "0.2"
    public static let kind = ScenarioKind.environment
    
    static let mockDataProvider = MockDataProvider()
    
    static var description: String? {
        """
        An in-app mock server.
        You can use “Configure Mocks” home screen shortcut to modify server responses.
        """
    }
    
    static var appController: AppController {
        let server = MockServer(dataProvider: mockDataProvider)
        return CoordinatedAppController(developmentWith: .mock(with: server))
    }
}

private extension ApplicationServices {
    
    convenience init(developmentServicesFor environment: Environment) {
        #if targetEnvironment(simulator)
        self.init(standardServicesFor: environment, exposureNotificationManager: SimulatedExposureNotificationManager(), currentDateProvider: { Date() })
        #else
        if MockScenario.mockDataProvider.useFakeENContacts {
            self.init(standardServicesFor: environment, exposureNotificationManager: SimulatedExposureNotificationManager(), currentDateProvider: { Date() })
        } else {
            self.init(standardServicesFor: environment, currentDateProvider: { Date() })
        }
        #endif
    }
    
}

extension CoordinatedAppController {
    
    convenience init(developmentWith environment: Environment) {
        let enabledFeatures = FeatureToggleStorage.getEnabledFeatures()
        let services = ApplicationServices(developmentServicesFor: environment)
        self.init(services: services, enabledFeatures: enabledFeatures)
    }
    
}
