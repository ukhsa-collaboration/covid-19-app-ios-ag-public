//
// Copyright © 2020 NHSX. All rights reserved.
//

enum PostcodeProcessor {
    private static let maxPostcodeLength = 4
    
    static func process(_ postcode: String) -> String {
        
        var result = postcode
        
        // Only interested in first part of the string
        let parts = result.split(separator: " ")
        if let nonEmptyFirstPartOfThePostcode = parts.first(where: { !$0.isEmpty }) {
            result = String(nonEmptyFirstPartOfThePostcode)
        }
        
        return String(result.alphamuneric.uppercased().prefix(maxPostcodeLength))
    }
}
