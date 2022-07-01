//
// Copyright © 2020 NHSX. All rights reserved.
//

import BackgroundTasks
import Domain
import TestSupport
import XCTest

class ProcessingTaskRequestTests: XCTestCase {

    func testInitializingFromSystemType() {
        let earliestBeginDate = Date(timeIntervalSinceNow: .random(in: 0 ... 1000))
        for requiresNetworkConnectivity in [true, false] {
            for requiresExternalPower in [true, false] {
                let systemRequest = BGProcessingTaskRequest(identifier: UUID().uuidString)
                systemRequest.earliestBeginDate = earliestBeginDate
                systemRequest.requiresNetworkConnectivity = requiresNetworkConnectivity
                systemRequest.requiresExternalPower = requiresExternalPower

                let expected = ProcessingTaskRequest(
                    earliestBeginDate: earliestBeginDate,
                    requiresNetworkConnectivity: requiresNetworkConnectivity,
                    requiresExternalPower: requiresExternalPower
                )

                let actual = ProcessingTaskRequest(systemRequest)

                TS.assert(actual, equals: expected)
            }
        }
    }

    func testConvertingToSystemType() {
        let earliestBeginDate = Date(timeIntervalSinceNow: .random(in: 0 ... 1000))
        for requiresNetworkConnectivity in [true, false] {
            for requiresExternalPower in [true, false] {

                let request = ProcessingTaskRequest(
                    earliestBeginDate: earliestBeginDate,
                    requiresNetworkConnectivity: requiresNetworkConnectivity,
                    requiresExternalPower: requiresExternalPower
                )

                let identifier = UUID().uuidString

                let systemRequest = BGProcessingTaskRequest(identifier: identifier, request: request)
                XCTAssertEqual(systemRequest.identifier, identifier)
                XCTAssertEqual(systemRequest.earliestBeginDate, earliestBeginDate)
                XCTAssertEqual(systemRequest.requiresNetworkConnectivity, requiresNetworkConnectivity)
                XCTAssertEqual(systemRequest.requiresExternalPower, requiresExternalPower)
            }
        }
    }

}
