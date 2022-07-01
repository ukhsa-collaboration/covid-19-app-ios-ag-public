//
// Copyright © 2021 DHSC. All rights reserved.
//

import Integration
import ObjectiveC
import UIKit

public enum ScenarioKind: CaseIterable, Identifiable {
    case environment
    case screen
    case screenTemplate
    case component
    case palette
    case prototype

    public var id: ScenarioKind { self }

    var name: String {
        switch self {
        case .environment: return "Environments"
        case .screen: return "Screens"
        case .screenTemplate: return "Screen Templates"
        case .component: return "Components"
        case .palette: return "UI Palette"
        case .prototype: return "Prototypes"
        }
    }
}

/// A marker protocol.
/// This protocol doesn’t have any requirement, apart from the conform type being an Objective-C type.
///
/// This is used as part of the mechanism to automatically detect all conforming types. See ``ScenarioId.allCases``.
@objc public protocol IdentifiableType: AnyObject {}

public extension IdentifiableType {
    /// ID of the `IdentifiableType`. This is not part of the protocol requirements as there’s only one correct implementation possible.
    /// (We would not be able to represent a static requirement in an ObjC protocol anyway.)
    static var id: String {
        NSStringFromClass(Self.self)
    }
}

/// A base protocol for a scenario.
///
/// This protocol define common requirements on scenarios – regardless of whether it’s called from tests or internally within scenarios.
public protocol BaseScenario: IdentifiableType {

    /// User-visible name for this scenario
    static var name: String { get }

    /// The kind of the test.
    ///
    /// This is used as a conceptual grouping of the scenarios, used e.g. when displaying the list of scenarios.
    static var kind: ScenarioKind { get }
}

public struct EmptyCodable: Codable, Equatable {}

/// Protocol to define a scenario type usable from tests.
///
/// This protocol doesn’t provide any information necessary to actual run the scenario – that’s implementation detail of the `Scenarios` module.
/// Rather, it has the information needed by the UI tests to be able to correctly configure and start the test.
public protocol TestScenario: BaseScenario {
    associatedtype Inputs: Encodable & Equatable = EmptyCodable

    /// Default inputs for the test.
    static var defaultInputs: Inputs { get }
}

/// Protocol to define a scenario type that can load an app controller, and provide additional info for the scenario listing.
///
/// The protocol also defined
protocol AppControllingScenario: BaseScenario {

    /// Alternative name for this scenario, used for sorting purposes. Default conformance returns ``name``.
    static var nameForSorting: String { get }

    /// A user-visible description for the scenario. Default conformance returns ``nil``.
    static var description: String? { get }

    /// The ``AppController`` for the scenario.
    static var appController: AppController { get }
}

/// Protocol used internally to define a scenario.
///
/// `Scenario` protocol is a composed refinement of multiple protocols. In practice, no type should be conforming to those individual protocols and always to
/// `Scenario` itself. This breakup of protocols is mostly an implementation detail, and is structured so we can achieve the properties we want, within current
/// boundaries of `Swift`.
/// * `IdentifiableType` is there to ensure we can use Objective-C runtime features when discovering scenarios.
/// * `TestScenario` is there to provide the public requirements that should be accessible from tests.
/// * `AppControllingScenario` is there to provide the internal requirements that should _not_ be accessible from tests.
/// * `AppControllingScenario` can not be a refinement on `TestScenario`, since `TestScenario` has an associated type, and therefore can’t be used
/// as an existential type (though [this Swift Evolution Proposal](https://github.com/apple/swift-evolution/blob/main/proposals/0309-unlock-existential-types-for-all-protocols.md)
/// would resolve this limiration). Therefore, common requirements between the two are extracted into `BaseScenario`.
protocol Scenario: AppControllingScenario, TestScenario {}

struct ScenarioInfo {
    var name: String
    var description: String
}

public extension TestScenario where Inputs == EmptyCodable {
    static var defaultInputs: Inputs {
        .init()
    }
}

extension Scenario {
    static var description: String? {
        nil
    }

    static var nameForSorting: String {
        name
    }
}

extension AppControllingScenario {
    static var info: ScenarioInfo? {
        description.map {
            ScenarioInfo(name: name, description: $0)
        }
    }
}
