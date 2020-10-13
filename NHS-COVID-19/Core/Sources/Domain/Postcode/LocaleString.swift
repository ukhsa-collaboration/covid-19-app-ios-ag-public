//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

public struct LocaleString: Equatable, ExpressibleByDictionaryLiteral {
    private var values: [Locale: String]
    
    public init(dictionaryLiteral elements: (Locale, String)...) {
        values = Dictionary(elements, uniquingKeysWith: { $1 })
    }
    
    subscript(_ locale: Locale) -> String? {
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

extension LocaleString {
    public var localizedString: String {
        let identifier = Bundle.preferredLocalizations(from: Array(values.keys.map { $0.identifier })).first ?? "en-GB"
        return self[Locale(identifier: identifier)] ?? ""
    }
}
