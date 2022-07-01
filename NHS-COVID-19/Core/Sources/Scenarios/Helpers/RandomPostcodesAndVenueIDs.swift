//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

/// Some extensions to `String` to generate random postcodes and venues IDs for tests and the Scenarios app.

extension String {
    static func randomVenueID() -> String {
        let formats = [
            "AA111111A11",
            "111AAAAAAA",
        ]
        return "\(RandomString(from: formats.randomElement()!))"
    }

    static func randomPostcode() -> String {
        let formats = [
            "A11AA",
            "AA11AA",
            "A111AA",
            "AA111AA",
            "A1A1AA",
            "AA1A1AA",
        ]
        return "\(RandomString(from: formats.randomElement()!))"
    }

    /// Flips two coins - if both are tails, returns `nil`. Otherwise generates a random postcode.
    /// - Returns: Either a random postcode (75% chance) or `nil` (25% chance.)
    static func randomPostcodeOrNil() -> String? {
        return Bool.random() || Bool.random() ? randomPostcode() : nil
    }
}

private struct RandomString: CustomStringConvertible {
    enum StringFormatCharacter: Character {
        case letter = "A"
        case number = "1"
        case space = " "
    }

    let format: [StringFormatCharacter]

    init(from string: String) {
        format = string.map { StringFormatCharacter(rawValue: $0)! }
    }

    var description: String {
        let s = format.map { character -> Character in
            switch character {
            case .letter:
                return "ABCDEFGHIJKLMNOPQRSTUVWXYZ".randomElement()!
            case .number:
                return "0123456789".randomElement()!
            case .space:
                return Character(" ")
            }
        }

        return String(s)
    }
}
