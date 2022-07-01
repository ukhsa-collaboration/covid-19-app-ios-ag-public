//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

public struct LocaleString: Equatable, ExpressibleByDictionaryLiteral {
    public var values: [Locale: String]

    public init(dictionaryLiteral elements: (Locale, String)...) {
        values = Dictionary(elements, uniquingKeysWith: { $1 })
    }

    public subscript(_ locale: Locale) -> String? {
        values[locale]
    }

    var isEmpty: Bool {
        values.isEmpty
    }
}

extension LocaleString: Decodable {
    // Synthesised Decodable conformance does not work with custom keys in dictionaries
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValues = try container.decode([String: String].self)
        values = Dictionary(uniqueKeysWithValues: stringValues.map { key, value in
            (Locale(identifier: key), value)
        })
    }
}
