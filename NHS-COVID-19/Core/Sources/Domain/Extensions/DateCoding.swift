//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

extension JSONDecoder.DateDecodingStrategy {

    static let appNetworking = JSONDecoder.DateDecodingStrategy.custom { decoder in
        var container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard let date = ISO8601DateFormatter.date(from: string) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date string \(string)")
        }
        return date
    }

}

private extension ISO8601DateFormatter {

    static func date(from string: String) -> Date? {
        withoutFractionalSeconds.date(from: string) ?? withFractionalSeconds.date(from: string)
    }

    static let withoutFractionalSeconds = ISO8601DateFormatter()
    static let withFractionalSeconds = configuring(ISO8601DateFormatter()) {
        $0.formatOptions.insert(.withFractionalSeconds)
    }

}
