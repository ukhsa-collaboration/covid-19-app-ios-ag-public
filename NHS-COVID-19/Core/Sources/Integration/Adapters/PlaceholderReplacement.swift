//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

extension String {
    private static let postcodePlaceholder = "[postcode]"
    private static let localAuthorityPlaceholder = "[local authority]"
    
    func stringByReplacing(postcode: String) -> String {
        replacingOccurrences(of: Self.postcodePlaceholder, with: postcode)
    }
    
    func stringByReplacing(localAuthority: String) -> String {
        replacingOccurrences(of: Self.localAuthorityPlaceholder, with: localAuthority)
    }
    
    func stringByReplacing(postcode: String, localAuthority: String) -> String {
        stringByReplacing(postcode: postcode)
            .stringByReplacing(localAuthority: localAuthority)
    }
}
