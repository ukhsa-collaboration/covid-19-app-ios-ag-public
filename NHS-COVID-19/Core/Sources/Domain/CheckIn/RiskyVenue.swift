//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

struct RiskyVenue: Equatable {

    /// The message to show to someone who checked into the venue in the `riskyInterval`.
    enum MessageType: String, Codable {
        /// Just tell the person they were at a venue where someone else tested positive.
        case warnAndInform

        /// Invite the person to book a test because other people have tested positive at a venue
        /// they checked in to.
        case warnAndBookATest

        var severity: VenueMessageTypeSeverityLevel {
            switch self {
            case .warnAndInform: return .level1
            case .warnAndBookATest: return .level2
            }
        }
    }

    var id: String
    var riskyInterval: DateInterval
    var messageType: MessageType
}

enum VenueMessageTypeSeverityLevel: Comparable {
    case level0
    case level1
    case level2
}

extension RiskyVenue: Comparable {
    /// Order .warnAndBookATest venues before the others
    static func < (lhs: RiskyVenue, rhs: RiskyVenue) -> Bool {
        return lhs.messageType.severity > rhs.messageType.severity
    }
}

struct RiskyVenueConfiguration: Codable, Equatable {
    var optionToBookATest: DayDuration

    private enum CodingKeys: String, CodingKey {
        case optionToBookATest
    }
}

extension RiskyVenueConfiguration {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        optionToBookATest = try container.decode(DayDuration.self, forKey: .optionToBookATest)
    }

    static let `default` = RiskyVenueConfiguration(optionToBookATest: 11)

}
