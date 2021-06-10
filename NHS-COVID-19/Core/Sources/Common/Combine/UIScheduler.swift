//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Foundation

/// A scheduler that performs all work on the main queue, as soon as possible.
///
/// If the caller is already running on the main queue when an action is
/// scheduled, it will be run synchronously.
public struct UIScheduler: Scheduler {
    
    public typealias SchedulerOptions = Never
    public typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
    
    public static let shared = UIScheduler()
    
    public var now: SchedulerTimeType {
        DispatchQueue.main.now
    }
    
    public var minimumTolerance: SchedulerTimeType.Stride {
        DispatchQueue.main.minimumTolerance
    }
    
    private init() {}
    
    public func schedule(options: SchedulerOptions? = nil, _ action: @escaping () -> Void) {
        DispatchQueue.onMain(action)
    }
    
    public func schedule(
        after date: SchedulerTimeType,
        tolerance: SchedulerTimeType.Stride,
        options: SchedulerOptions? = nil,
        _ action: @escaping () -> Void
    ) {
        DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: nil, action)
    }
    
    public func schedule(
        after date: SchedulerTimeType,
        interval: SchedulerTimeType.Stride,
        tolerance: SchedulerTimeType.Stride,
        options: SchedulerOptions? = nil,
        _ action: @escaping () -> Void
    ) -> Cancellable {
        DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: nil, action)
    }
    
}
