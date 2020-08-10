//
// Copyright © 2020 NHSX. All rights reserved.
//

enum PostcodeProcessor {
    private static let maxPostcodeLength = 4
    
    static func process(_ postcode: String) -> String {
        let uppercasedPostcode = postcode.uppercased()
        let parts = uppercasedPostcode.split(separator: " ")
        if let nonEmptyPart = parts.first(where: { substring in !substring.isEmpty }) {
            return String(nonEmptyPart.prefix(Self.maxPostcodeLength))
        }
        return postcode
    }
}
