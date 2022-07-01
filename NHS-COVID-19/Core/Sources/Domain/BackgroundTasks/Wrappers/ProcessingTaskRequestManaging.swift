//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

import BackgroundTasks

/// A type for managing processing task requests.
///
/// This type differs from `BackgroundTaskScheduling` in these ways:
/// * The consumer can only submit tasks requests, and not register any handlers.
/// * This type uses `ProcessingTaskRequest` to hide the identifier of the request from the consumer.
public protocol ProcessingTaskRequestManaging {

    func submit(_ request: ProcessingTaskRequest) throws

    func getPendingRequest(completionHandler: @escaping (ProcessingTaskRequest?) -> Void)

    func cancelPendingRequest()

}

public class ProcessingTaskRequestManager: ProcessingTaskRequestManaging {

    private let identifier: String
    private let scheduler: BackgroundTaskScheduling

    public init(identifier: String, scheduler: BackgroundTaskScheduling) {
        self.identifier = identifier
        self.scheduler = scheduler
    }

    public func submit(_ request: ProcessingTaskRequest) throws {
        try scheduler.submit(BGProcessingTaskRequest(identifier: identifier, request: request))
    }

    public func getPendingRequest(completionHandler: @escaping (ProcessingTaskRequest?) -> Void) {
        scheduler.getPendingTaskRequests { requests in
            let request = requests.lazy
                .compactMap { $0 as? BGProcessingTaskRequest }
                .filter { $0.identifier == self.identifier }
                .first
                .map(ProcessingTaskRequest.init)

            completionHandler(request)
        }
    }

    public func cancelPendingRequest() {
        scheduler.cancel(taskRequestWithIdentifier: identifier)
    }

}
