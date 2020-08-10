//
// Copyright © 2020 NHSX. All rights reserved.
//

import BackgroundTasks

public protocol BackgroundTaskScheduling {
    func submit(_ taskRequest: BGTaskRequest) throws
    
    @discardableResult
    func register(
        forTaskWithIdentifier identifier: String,
        using queue: DispatchQueue?,
        launchHandler: @escaping (BackgroundTask) -> Void
    ) -> Bool
    
    func getPendingTaskRequests(completionHandler: @escaping ([BGTaskRequest]) -> Void)
    
    func cancel(taskRequestWithIdentifier identifier: String)
}

extension BGTaskScheduler: BackgroundTaskScheduling {
    public func register(forTaskWithIdentifier identifier: String, using queue: DispatchQueue?, launchHandler: @escaping (BackgroundTask) -> Void) -> Bool {
        register(forTaskWithIdentifier: identifier, using: queue) { (bgTask: BGTask) in
            launchHandler(bgTask)
        }
    }
}
