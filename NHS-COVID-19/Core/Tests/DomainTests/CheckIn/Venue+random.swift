//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
@testable import Domain

extension Venue {

    static func random() -> Venue {
        Venue(id: .random(), organisation: .random())
    }

    static func randomWithPostcode() -> Venue {
        Venue(id: .random(), organisation: .random(), postcode: .random())
    }
}
