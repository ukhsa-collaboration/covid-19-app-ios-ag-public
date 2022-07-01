//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

public struct VenueHistory: Identifiable, Equatable, Hashable {
    public struct ID: Hashable {
        public let value: String

        public init(
            value: String
        ) {
            self.value = value
        }
    }

    public let id: ID
    let venueId: String
    let organisation: String
    let postcode: String?
    let checkedIn: Date
    let checkedOut: Date

    public init(
        id: ID,
        venueId: String,
        organisation: String,
        postcode: String?,
        checkedIn: Date,
        checkedOut: Date
    ) {
        self.id = id
        self.venueId = venueId
        self.organisation = organisation
        self.postcode = postcode
        self.checkedIn = checkedIn
        self.checkedOut = checkedOut
    }
}
