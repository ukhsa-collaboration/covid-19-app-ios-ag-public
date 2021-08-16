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

@objc public protocol IdentifiableType: AnyObject {}

public extension IdentifiableType {
    static var id: String {
        NSStringFromClass(Self.self)
    }
}

struct ScenarioInfo {
    var name: String
    var description: String
}

public protocol TestScenario: IdentifiableType {
    static var name: String { get }
    static var nameForSorting: String { get }
    static var kind: ScenarioKind { get }
}

public extension TestScenario {
    static var nameForSorting: String {
        name
    }
}

protocol Scenario: TestScenario {
    static var id: String { get }
    static var appController: AppController { get }
    static var description: String? { get }
}

extension Scenario {
    static var description: String? {
        nil
    }
    
    static var info: ScenarioInfo? {
        description.map {
            ScenarioInfo(name: name, description: $0)
        }
    }
}
