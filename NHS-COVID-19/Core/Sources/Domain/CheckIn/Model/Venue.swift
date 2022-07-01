//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

public struct Venue: Codable, Equatable, Hashable {
    private enum CodingKeys: String, CodingKey {
        case id
        case organisation = "opn"
        case postcode = "pc"
    }

    var id: String
    var organisation: String
    var postcode: String?

    public init(
        id: String,
        organisation: String,
        postcode: String? = nil
    ) {
        self.id = id
        self.organisation = organisation
        self.postcode = postcode
    }
}
