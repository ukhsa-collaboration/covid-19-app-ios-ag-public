//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

struct Venue: Codable, Equatable, Hashable {
    private enum CodingKeys: String, CodingKey {
        case id
        case organisation = "opn"
    }
    
    var id: String
    var organisation: String
    
    init(
        id: String,
        organisation: String
    ) {
        self.id = id
        self.organisation = organisation
    }
}
