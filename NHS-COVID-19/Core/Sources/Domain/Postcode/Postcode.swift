//
// Copyright © 2020 NHSX. All rights reserved.
//

public struct Postcode: Codable, Hashable, DataConvertible {
    public var value: String
    
    public init(_ value: String) {
        self.value = value.uppercased()
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(String.self).uppercased()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
    
}
