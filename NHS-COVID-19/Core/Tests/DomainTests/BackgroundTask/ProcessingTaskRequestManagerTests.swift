//
// Copyright © 2020 NHSX. All rights reserved.
//

import BackgroundTasks
import Domain
import TestSupport
import XCTest

class ProcessingTaskRequestManagerTests: XCTestCase {

    func testSubmittingRequests() throws {
        let request = ProcessingTaskRequest(
            earliestBeginDate: Date(timeIntervalSinceNow: .random(in: 0 ... 1000)),
            requiresNetworkConnectivity: .random(),
            requiresExternalPower: .random()
        )

        let identifier = UUID().uuidString
        let scheduler = MockBackgroundTaskScheduler()

        let manager = ProcessingTaskRequestManager(identifier: identifier, scheduler: scheduler)

        try manager.submit(request)

        let systemRequest = try XCTUnwrap(scheduler.requests.first as? BGProcessingTaskRequest)
        XCTAssertEqual(systemRequest.identifier, identifier)
        XCTAssertEqual(systemRequest.earliestBeginDate, request.earliestBeginDate)
        XCTAssertEqual(systemRequest.requiresNetworkConnectivity, request.requiresNetworkConnectivity)
        XCTAssertEqual(systemRequest.requiresExternalPower, request.requiresExternalPower)
    }

    func testGettingRequest() throws {
        let request = ProcessingTaskRequest(
            earliestBeginDate: Date(timeIntervalSinceNow: .random(in: 0 ... 1000)),
            requiresNetworkConnectivity: .random(),
            requiresExternalPower: .random()
        )

        let identifier = UUID().uuidString
        let scheduler = MockBackgroundTaskScheduler()
        scheduler.requests = [BGProcessingTaskRequest(identifier: identifier, request: request)]

        let manager = ProcessingTaskRequestManager(identifier: identifier, scheduler: scheduler)

        var callbackCount = 0
        manager.getPendingRequest { actualRequest in
            callbackCount += 1
            TS.assert(actualRequest, equals: request)
        }

        XCTAssertEqual(callbackCount, 1)
    }

    func testGettingRequestFiltersOutRequestsIfIdentifierDoesNotMatch() throws {
        let scheduler = MockBackgroundTaskScheduler()
        scheduler.requests = [BGProcessingTaskRequest(identifier: "a", request: ProcessingTaskRequest())]

        let manager = ProcessingTaskRequestManager(identifier: "b", scheduler: scheduler)

        var callbackCount = 0
        manager.getPendingRequest { request in
            callbackCount += 1
            XCTAssertNil(request)
        }

        XCTAssertEqual(callbackCount, 1)
    }

    func testCancellingRequests() throws {

        let identifier = UUID().uuidString
        let scheduler = MockBackgroundTaskScheduler()

        scheduler.requests = [BGProcessingTaskRequest(identifier: identifier, request: ProcessingTaskRequest())]

        let manager = ProcessingTaskRequestManager(identifier: identifier, scheduler: scheduler)
        manager.cancelPendingRequest()

        XCTAssert(scheduler.requests.isEmpty)
    }

}
