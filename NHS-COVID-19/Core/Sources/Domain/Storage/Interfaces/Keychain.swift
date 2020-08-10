//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import Logging

public struct OSStatusError: Error, Equatable {
    public var status: OSStatus
    
    public init(_ status: OSStatus) {
        self.status = status
    }
}

/// Low level API to keychain.
///
/// `Keychain` sets the `kSecAttrService` attribute on all queries. Otherwise, the queries are passed to the system API unchanged.
public struct Keychain {
    
    private static let logger = Logger(label: "Keychain")
    
    private struct UnexpectedResultError: Error {}
    
    private var service: String
    
    public init(service: String) {
        self.service = service
    }
    
    public func add(_ query: [String: Any]) throws {
        try catchError {
            SecItemAdd(prepare(query), nil)
        }
    }
    
    public func update(_ query: [String: Any], with updatedAttributes: [String: Any]) throws {
        try catchError {
            SecItemUpdate(prepare(query), updatedAttributes as CFDictionary)
        }
    }
    
    public func delete(_ query: [String: Any]) throws {
        try catchError {
            SecItemDelete(prepare(query))
        }
    }
    
    public func get<Result>(_ query: [String: Any], as type: Result.Type) throws -> Result {
        var result: CFTypeRef?
        try catchError {
            SecItemCopyMatching(prepare(query), &result)
        }
        guard let expectedResult = result as? Result else {
            throw UnexpectedResultError()
        }
        return expectedResult
    }
    
    private func prepare(_ query: [String: Any]) -> CFDictionary {
        var preparedQuery = query
        preparedQuery[kSecAttrService as String] = service
        return preparedQuery as CFDictionary
    }
    
    private func catchError(from work: () -> OSStatus) throws {
        let status = work()
        switch status {
        case errSecSuccess:
            return
        case errSecInteractionNotAllowed:
            // Given our usage, there are two scenarios where this error is returned:
            // * There is a programmer error when calling keychain.
            // * We’re using keychain before we should (e.g. the app is launched before the device is unlocked for the first time)
            //
            // Either scenario results in undefined behaviour in the app, and could result in data loss.
            // Let’s crash instead.
            Self.logger.critical("Tried to access keychain when interaction not allowed.")
            fatalError("Keychain interaction is not allowed")
        default:
            throw OSStatusError(status)
        }
    }
    
}
