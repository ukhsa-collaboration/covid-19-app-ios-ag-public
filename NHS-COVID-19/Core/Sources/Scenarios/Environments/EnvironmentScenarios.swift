//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import ProductionConfiguration
import ScenariosConfiguration

class DevEnvironmentScenario: EnvironmentScenario {
    static let name = "Dev"
    static let configuration = EnvironmentConfiguration.dev
    static var nameForSorting: String { "1" }
}

class TestEnvironmentScenario: EnvironmentScenario {
    static let name = "Test"
    static let configuration = EnvironmentConfiguration.test
    static var nameForSorting: String { "2" }
}

class QAEnvironmentScenario: EnvironmentScenario {
    static let name = "QA"
    static let configuration = EnvironmentConfiguration.qa
    static var nameForSorting: String { "3" }
}

class AssuranceFunctionalEnvironmentScenario: EnvironmentScenario {
    static let name = "Assurance Functional"
    static let configuration = EnvironmentConfiguration.assuranceFunctional
    static var nameForSorting: String { "4" }
}

class DemoEnvironmentScenario: EnvironmentScenario {
    static let name = "Demo"
    static let configuration = EnvironmentConfiguration.demo
    static var nameForSorting: String { "5" }
}

class ProductionEnvironmentScenario: EnvironmentScenario {
    static let name = "Production"
    static let configuration = EnvironmentConfiguration.production
    static var nameForSorting: String { "6" }
}
