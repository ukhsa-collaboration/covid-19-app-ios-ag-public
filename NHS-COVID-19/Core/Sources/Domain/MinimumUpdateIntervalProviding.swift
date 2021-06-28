//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

public protocol MinimumUpdateIntervalProviding {
    
    var interval: TimeInterval { get }
    
}

public struct DefaultMinimumUpdateIntervalProvider: MinimumUpdateIntervalProviding {
    
    public let interval: TimeInterval = 10 * 60
    public init() {}
    
}
