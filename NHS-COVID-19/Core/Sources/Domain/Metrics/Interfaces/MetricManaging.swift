//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import MetricKit

public protocol MetricManaging {
    typealias Subscriber = MXMetricManagerSubscriber
    
    func add(_ subscriber: Subscriber)
}

extension MXMetricManager: MetricManaging {}
