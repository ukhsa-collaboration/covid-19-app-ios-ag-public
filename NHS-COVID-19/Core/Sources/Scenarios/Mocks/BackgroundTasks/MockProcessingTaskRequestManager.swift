//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain

public class MockProcessingTaskRequestManager: ProcessingTaskRequestManaging {
    public var request: ProcessingTaskRequest?
    public var submitCallCount = 0

    public init() {}

    public func submit(_ request: ProcessingTaskRequest) throws {
        self.request = request
        submitCallCount += 1
    }

    public func getPendingRequest(completionHandler: @escaping (ProcessingTaskRequest?) -> Void) {
        completionHandler(request)
    }

    public func cancelPendingRequest() {
        request = nil
    }
}
