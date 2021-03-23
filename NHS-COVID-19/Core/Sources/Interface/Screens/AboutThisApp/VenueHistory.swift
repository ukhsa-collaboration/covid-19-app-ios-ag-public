//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

public struct VenueHistory {
    let id: String
    let organisation: String
    let postcode: String?
    let checkedIn: Date
    let checkedOut: Date
    public let delete: () -> Void
    
    public init(id: String, organisation: String, postcode: String?, checkedIn: Date, checkedOut: Date, delete: @escaping () -> Void) {
        self.id = id
        self.organisation = organisation
        self.postcode = postcode
        self.checkedIn = checkedIn
        self.checkedOut = checkedOut
        self.delete = delete
    }
}

extension VenueHistory: Equatable {
    public static func == (lhs: VenueHistory, rhs: VenueHistory) -> Bool {
        return lhs.id == rhs.id &&
            lhs.organisation == rhs.organisation &&
            lhs.checkedIn == rhs.checkedIn &&
            lhs.checkedOut == rhs.checkedOut
    }
}
