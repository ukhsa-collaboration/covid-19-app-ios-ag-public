//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common

protocol CTATokenValidating {
    func validate(_ token: String) -> Bool
}

struct CTATokenValidator: CTATokenValidating {
    private static let crockfordBase32Alphabet = "0123456789abcdefghjkmnpqrstvwxyz"
    private static let dammModulus = 32
    private static let dammMask = 5
    private static let tokenLength = 8

    func validate(_ token: String) -> Bool {
        guard token.count == Self.tokenLength,
            matchesAllowedCharacters(token: token)
        else { return false }

        let checksum = token.lowercased().reduce(0) { checksum, character in
            let digit = Array(Self.crockfordBase32Alphabet).firstIndex(of: character)!
            return damm32(checksum: checksum, digit: digit)
        }

        return checksum == 0

    }

    private func matchesAllowedCharacters(token: String) -> Bool {
        token.range(of: "^[\(Self.crockfordBase32Alphabet)]+$", options: .regularExpression) != nil
    }

    private func damm32(checksum: Int, digit: Int) -> Int {
        var newChecksum = checksum ^ digit
        newChecksum *= 2
        if newChecksum >= Self.dammModulus {
            newChecksum = (newChecksum ^ Self.dammMask) % Self.dammModulus
        }
        return newChecksum
    }
}
