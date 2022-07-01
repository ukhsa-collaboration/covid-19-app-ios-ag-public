//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

public struct HTTPHeaders: ExpressibleByDictionaryLiteral, Equatable {

    public var fields: [HTTPHeaderFieldName: String]

    public init(fields: [HTTPHeaderFieldName: String] = [:]) {
        self.fields = fields
    }

    public init(dictionaryLiteral elements: (HTTPHeaderFieldName, String)...) {
        self.init(fields: Dictionary(uniqueKeysWithValues: elements))
    }

    public func hasValue(for name: HTTPHeaderFieldName) -> Bool {
        fields.keys.contains(name)
    }

}

extension HTTPHeaders {

    public init(fields: [String: String]) {
        let fields = Dictionary(fields.map { (HTTPHeaderFieldName($0), $1) }) { _, _ -> String in
            Thread.fatalError("Duplicate header fields: \(fields).")
        }
        self.init(fields: fields)
    }

    var stringFields: [String: String] {
        Dictionary(uniqueKeysWithValues: fields.lazy.map { ($0.lowercaseName, $1) })
    }

}
