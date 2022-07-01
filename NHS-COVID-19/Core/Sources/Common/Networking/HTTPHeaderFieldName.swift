//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

public struct HTTPHeaderFieldName: Hashable {
    public var lowercaseName: String

    public init(_ name: String) {
        lowercaseName = name.lowercased()
    }
}

extension HTTPHeaderFieldName {

    public static let contentType = HTTPHeaderFieldName("content-type")

    public static let contentLength = HTTPHeaderFieldName("content-length")

    static let bodyHeaders: [HTTPHeaderFieldName] = [
        .contentLength,
        .contentType,
    ]

}
