//
// Copyright © 2020 NHSX. All rights reserved.
//

import BackgroundTasks
import Domain

class MockBackgroundTaskScheduler: BackgroundTaskScheduling {
    var requests = [BGTaskRequest]()
    private var taskInfo = [String: (queue: DispatchQueue?, launchHandler: (BackgroundJob) -> Void)]()

    func submit(_ taskRequest: BGTaskRequest) throws {
        requests.append(taskRequest)
    }

    @discardableResult
    func register(forTaskWithIdentifier identifier: String, using queue: DispatchQueue?, launchHandler: @escaping (BackgroundJob) -> Void) -> Bool {
        taskInfo[identifier] = (queue, launchHandler)
        return true
    }

    func getPendingTaskRequests(completionHandler: @escaping ([BGTaskRequest]) -> Void) {
        completionHandler(requests)
    }

    func cancel(taskRequestWithIdentifier identifier: String) {
        requests.removeAll { $0.identifier == identifier }
    }
}
