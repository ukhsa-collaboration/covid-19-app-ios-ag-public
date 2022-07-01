//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

class ActionsInvocationRecord: Codable {
    var actions: [ActionRecord] // Interested in first one

    private enum CodingKeys: String, CodingKey {
        case actions
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        actions = try container.decode(XCResultArrayValue<ActionRecord>.self, forKey: .actions).values
    }
}

class ActionRecord: Codable {
    var actionResult: ActionResult
}

class ActionResult: Codable {
    var testsRef: Reference
}

class Reference: Codable {
    var id: String

    private enum CodingKeys: String, CodingKey {
        case id
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(XCResultValueType.self, forKey: .id).value
    }
}

class XCResultType: Codable {
    let name: String

    private enum CodingKeys: String, CodingKey {
        case name = "_name"
    }
}

class XCResultObjectType: Codable {
    let name: String
    let supertype: XCResultObjectType?

    private enum CodingKeys: String, CodingKey {
        case name = "_name"
        case supertype = "_supertype"
    }

    func getType() -> AnyObject.Type {
        if let type = XCResultTypeFamily(rawValue: name) {
            return type.getType()
        } else if let parentType = supertype {
            return parentType.getType()
        } else {
            return XCResultObjectType.self
        }
    }
}

class XCResultObject: Codable {
    let type: XCResultObjectType

    private enum CodingKeys: String, CodingKey {
        case type = "_type"
    }
}

class XCResultArrayValue<T: Codable>: Codable {
    let values: [T]

    private enum CodingKeys: String, CodingKey {
        case values = "_values"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        values = try container.decode(family: XCResultTypeFamily.self, forKey: .values)
    }
}

class XCResultValueType: Codable {
    let type: XCResultType
    let value: String

    private enum CodingKeys: String, CodingKey {
        case type = "_type"
        case value = "_value"
    }
}

class ActionTestPlanRunSummaries: Codable {
    let summaries: [ActionTestPlanRunSummary]

    private enum CodingKeys: String, CodingKey {
        case summaries
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        summaries = try container.decode(XCResultArrayValue<ActionTestPlanRunSummary>.self, forKey: .summaries).values
    }
}

class ActionTestPlanRunSummary: Codable {
    let testableSummaries: [ActionTestableSummary]

    private enum CodingKeys: String, CodingKey {
        case testableSummaries
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        testableSummaries = try container.decode(XCResultArrayValue<ActionTestableSummary>.self, forKey: .testableSummaries).values
    }
}

class ActionAbstractTestSummary: Codable {
    let name: String

    private enum CodingKeys: String, CodingKey {
        case name
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(XCResultValueType.self, forKey: .name).value
    }
}

// AppTests, DomainTests, IntegrationTests, InterfaceTests, CommonTests
class ActionTestableSummary: ActionAbstractTestSummary {
    let tests: [ActionTestSummaryIdentifiableObject]

    private enum CodingKeys: String, CodingKey {
        case tests
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tests = try container.decode(XCResultArrayValue<ActionTestSummaryIdentifiableObject>.self, forKey: .tests).values

        try super.init(from: decoder)
    }
}

class ActionTestSummaryIdentifiableObject: ActionAbstractTestSummary {
    let identifier: String

    private enum CodingKeys: String, CodingKey {
        case identifier
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try container.decode(XCResultValueType.self, forKey: .identifier).value

        try super.init(from: decoder)
    }

}

class ActionTestSummaryGroup: ActionTestSummaryIdentifiableObject {
    var duration: String
    var subtests: [ActionTestSummaryIdentifiableObject]

    private enum CodingKeys: String, CodingKey {
        case duration
        case subtests
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        subtests = try container.decode(XCResultArrayValue<ActionTestSummaryIdentifiableObject>.self, forKey: .subtests).values
        duration = try container.decode(XCResultValueType.self, forKey: .duration).value

        try super.init(from: decoder)
    }
}

class ActionTestMetadata: ActionTestSummaryIdentifiableObject {
    var duration: String
    var testStatus: String

    private enum CodingKeys: String, CodingKey {
        case duration
        case testStatus
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        testStatus = try container.decode(XCResultValueType.self, forKey: .testStatus).value
        duration = try container.decode(XCResultValueType.self, forKey: .duration).value

        try super.init(from: decoder)
    }
}

// MARK: -

// MARK: Heterogenous Decoding

// Note: This part copies the Kewin Remeczki's article on Swift 4 Decodable
//       and heterogenous collections
// See: https://medium.com/@kewindannerfjordremeczki/swift-4-0-decodable-heterogeneous-collections-ecc0e6b468cf

/// To support a new class family, create an enum that conforms to this protocol and contains the different types.
protocol ClassFamily: Decodable {
    /// The discriminator key.
    static var discriminator: Discriminator { get }

    /// Returns the class type of the object coresponding to the value.
    func getType() -> AnyObject.Type
}

/// Discriminator key enum used to retrieve discriminator fields in JSON payloads.
enum Discriminator: String, CodingKey {
    case type = "_type"
}

enum XCResultTypeFamily: String, ClassFamily {
    case actionAbstractTestSummary = "ActionAbstractTestSummary"
    case actionResult = "ActionResult"
    case actionTestMetadata = "ActionTestMetadata"
    case actionTestPlanRunSummaries = "ActionTestPlanRunSummaries"
    case actionTestPlanRunSummary = "ActionTestPlanRunSummary"
    case actionTestSummaryGroup = "ActionTestSummaryGroup"
    case actionTestSummaryIdentifiableObject = "ActionTestSummaryIdentifiableObject"
    case actionTestableSummary = "ActionTestableSummary"
    case actionsInvocationRecord = "ActionsInvocationRecord"
    case actionRecord = "ActionRecord"

    static var discriminator: Discriminator = .type

    func getType() -> AnyObject.Type {
        switch self {
        case .actionAbstractTestSummary:
            return ActionAbstractTestSummary.self
        case .actionTestSummaryGroup:
            return ActionTestSummaryGroup.self
        case .actionTestableSummary:
            return ActionTestableSummary.self
        case .actionTestPlanRunSummary:
            return ActionTestPlanRunSummary.self
        case .actionTestMetadata:
            return ActionTestMetadata.self
        case .actionResult:
            return ActionResult.self
        case .actionTestPlanRunSummaries:
            return ActionTestPlanRunSummaries.self
        case .actionTestSummaryIdentifiableObject:
            return ActionTestSummaryIdentifiableObject.self
        case .actionsInvocationRecord:
            return ActionsInvocationRecord.self
        case .actionRecord:
            return ActionRecord.self
        }
    }
}

extension KeyedDecodingContainer {

    /// Decode a heterogeneous list of objects for a given family.
    /// - Parameters:
    ///     - family: The ClassFamily enum for the type family.
    ///     - key: The CodingKey to look up the list in the current container.
    /// - Returns: The resulting list of heterogeneousType elements.
    func decode<T: Codable, U: ClassFamily>(family: U.Type, forKey key: K) throws -> [T] {
        var container = try nestedUnkeyedContainer(forKey: key)
        var list = [T]()
        var tmpContainer = container
        while !container.isAtEnd {
            let resultObj = try container.decode(XCResultObject.self)
            if let type = resultObj.type.getType() as? T.Type {
                list.append(try tmpContainer.decode(type))
            }
        }
        return list
    }

}
