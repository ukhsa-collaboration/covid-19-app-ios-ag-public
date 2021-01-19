//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import XCTest

public enum TS {
    
    /// Asserts that `actual` and `expected` are equal.
    ///
    /// Functionally, this is equivalent to `XCTAssertEqual`. However, if the values are not equal, this method provides better diagnostics by generating a diff
    /// between the `actual` and `expected` values.
    public static func assert<T>(
        _ actual: @autoclosure () throws -> T,
        equals expected: @autoclosure () throws -> T,
        _ additionalMessage: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) where T: Equatable {
        do {
            let actualValue = try actual()
            let expectedValue = try expected()
            guard actualValue != expectedValue else { return }
            
            let message = [
                additionalMessage(),
                differenceMessage(expected: expectedValue, actual: actualValue),
            ]
            .filter { $0 != "" }
            .joined(separator: "\n")
            
            XCTFail(message, file: file, line: line)
        } catch {
            XCTFail("Threw error “\(error)”", file: file, line: line)
        }
    }
    
    @available(iOS 13, *)
    private static func differenceMessage<T>(expected: T, actual: T) -> String {
        let actualDescription = description(for: actual)
        let expectedDescription = description(for: expected)
        let lines = actualDescription.split(separator: "\n")
            .combinedDifference(from: expectedDescription.split(separator: "\n"))
        
        let diff = lines
            .map { "\($0.change.description) \($0.element)" }
            .joined(separator: "\n")
        
        return """
        Difference from expectation:
        \(diff)
        """
    }
    
    private static func differenceMessageCompatibility<T>(expected: T, actual: T) -> String {
        let actualDescription = description(for: actual)
        let expectedDescription = description(for: expected)
        return """
        Difference from expectation:
        actual:
        \(actualDescription)
        expected:
        \(expectedDescription)
        """
    }
    
    public static func description(for subject: Any) -> String {
        let object = descriptionObject(for: subject)
        switch descriptionObject(for: subject) {
        case .dictionary, .array, .jsonObject:
            let json = try! JSONSerialization.data(withJSONObject: object.jsonObject, options: [.prettyPrinted, .sortedKeys])
            return String(data: json, encoding: .utf8)!
        case .string(let string):
            return string
        case .null:
            return "<Null>"
        }
    }
}

@available(iOS 13, *)
private extension CombinedDifference.Change {
    
    var description: String {
        switch self {
        case .added: return "+++"
        case .removed: return "---"
        case .none: return "   "
        }
    }
    
}

public protocol CustomDescriptionConvertible {
    var descriptionObject: Description { get }
}

public enum Description {
    case string(String)
    case dictionary([String: Description])
    case array([Description])
    case jsonObject(Any)
    case null
    
    var jsonObject: Any {
        switch self {
        case .string(let value):
            return value
        case .dictionary(let value):
            return value.mapValues { $0.jsonObject }
        case .array(let value):
            return value.map { $0.jsonObject }
        case .jsonObject(let object):
            return object
        case .null:
            return NSNull()
        }
    }
    
    public static func encodable<T: Encodable>(_ object: T) -> Description {
        let data = try! JSONEncoder().encode(object)
        let object = try! JSONSerialization.jsonObject(with: data)
        return .jsonObject(object)
    }
}

private func descriptionObject(for subject: Any) -> Description {
    if let convertible = subject as? CustomDescriptionConvertible {
        return convertible.descriptionObject
    }
    let mirror = Mirror(reflecting: subject)
    switch mirror.displayStyle ?? .struct {
    case .struct, .class:
        guard !mirror.children.isEmpty else {
            return .string("\(subject)")
        }
        var dictionary = [String: Description]()
        var instanceMirror: Mirror? = mirror
        while instanceMirror != nil {
            instanceMirror?.children.forEach { key, value in
                if let key = key {
                    dictionary[key] = descriptionObject(for: value)
                }
            }
            instanceMirror = instanceMirror?.superclassMirror
        }
        
        return .dictionary(dictionary)
        
    case .optional:
        var value: Any?
        mirror.children.forEach { _, child in
            value = child
        }
        if let value = value {
            return descriptionObject(for: value)
        } else {
            return .null
        }
        
    case .collection:
        let array = mirror.children.map { _, child in
            descriptionObject(for: child)
        }
        return .array(array)
        
    case .set:
        let array = mirror.children
            .sorted { "\($0.1)" < "\($1.1)" } // doesn’t matter as long as it’s predictable
            .map { _, child in
                descriptionObject(for: child)
            }
        return .array(array)
        
    case .dictionary:
        var dictionary = [String: Description]()
        mirror.children.forEach { _, child in
            var key: String?
            var value: Any?
            Mirror(reflecting: child).children.forEach { label, subchild in
                switch label {
                case "key":
                    key = subchild as? String
                case "value":
                    value = subchild
                default:
                    break
                }
            }
            if let key = key, let value = value {
                dictionary[key] = descriptionObject(for: value)
            }
        }
        return .dictionary(dictionary)
        
    case .enum, .tuple:
        // Not worth the effort at the moment. Refine if the need comes up.
        return .string("\(subject)")
        
    @unknown default:
        return .string("\(subject)")
    }
}
