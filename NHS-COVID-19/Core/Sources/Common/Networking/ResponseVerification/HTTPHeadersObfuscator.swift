//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

public struct HTTPHeadersObfuscator {
    private let minMessageSize = 4000
    private let randomPaddingSize = 4000

    public init() {}

    public func prepare(_ request: HTTPRequest) -> HTTPRequest {
        let targetMessageSize = minMessageSize + Int.random(in: 0 ... randomPaddingSize)
        let headerPaddingSize = targetMessageSize - (request.body?.content.count ?? 0)
        guard headerPaddingSize > 0 else { return request }

        var preparedHeadersFields = request.headers.fields
        let headerFieldsSizes = randomHeaderFieldsSize(from: headerPaddingSize)
        guard headerFieldsSizes.count > 0 else { return request }

        for (index, size) in headerFieldsSizes.enumerated() {
            preparedHeadersFields = randomized(index: index + 1, bytes: size)
                .merging(preparedHeadersFields) { _, rhs in rhs }
        }

        let request = HTTPRequest(
            method: request.method,
            path: request.path,
            body: request.body,
            fragment: request.fragment,
            queryParameters: request.queryParameters,
            headers: HTTPHeaders(fields: preparedHeadersFields)
        )
        return request
    }
}

extension HTTPHeadersObfuscator {
    func randomHeaderFieldsSize(from size: Int) -> [Int] {
        let maxHeaderSize = 2000
        var sizes = Array(repeating: maxHeaderSize, count: size / maxHeaderSize)
        let mod = size % maxHeaderSize
        if mod > 0 { sizes.append(mod) }
        return sizes
    }

    func randomized(index: Int, bytes: Int) -> [HTTPHeaderFieldName: String] {
        guard bytes > 0 else {
            Thread.assert(bytes > 0, "The bytes cannot be less than zero")
            return [:]
        }
        let string = randomAlphanumericString(length: bytes)
        return [HTTPHeaderFieldName("X-Randomised-\(index)"): string]
    }

    private func randomAlphanumericString(length: Int) -> String {
        enum Statics {
            static let scalars = [UnicodeScalar("a").value ... UnicodeScalar("z").value,
                                  UnicodeScalar("A").value ... UnicodeScalar("Z").value,
                                  UnicodeScalar("0").value ... UnicodeScalar("9").value].joined()

            static let characters = scalars.map { Character(UnicodeScalar($0)!) }
        }

        let result = (0 ..< length).map { _ in Statics.characters.randomElement()! }
        return String(result)
    }
}
