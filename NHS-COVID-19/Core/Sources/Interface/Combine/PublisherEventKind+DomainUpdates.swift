//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

extension PublisherEventKind {
    
    public static let modelChange = PublisherEventKind.receive(on: RunLoop.main)
    
}
