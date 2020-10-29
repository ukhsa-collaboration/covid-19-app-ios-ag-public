//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

struct RiskyVenue: Equatable {
    enum MessageType {
        case inform
        case isolate
    }
    
    var id: String
    var riskyInterval: DateInterval
    var messageType: MessageType
}
