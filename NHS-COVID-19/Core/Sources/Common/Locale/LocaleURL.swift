//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

public struct LocaleURL: Equatable, ExpressibleByDictionaryLiteral {
    public var values: [Locale: URL]
    
    public init(dictionaryLiteral elements: (Locale, URL)...) {
        values = Dictionary(elements, uniquingKeysWith: { $1 })
    }
    
    public subscript(_ locale: Locale) -> URL? {
        values[locale]
    }
    
    var isEmpty: Bool {
        values.isEmpty
    }
}

extension LocaleURL: Decodable {
    public init(from decoder: Decoder) throws {
        let localeString = try LocaleString(from: decoder)
        let urls = try localeString.values.mapValues { urlString -> URL in
            guard let url = URL(string: urlString), url.host != nil else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Unable to create LocaleURL from a LocaleString"
                    )
                )
            }
            return url
        }
        values = urls
    }
}
