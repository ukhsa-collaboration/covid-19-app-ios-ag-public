//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import TestSupport
import XCTest

class PublisherRegulationMonitoringTests: XCTestCase {

    func testCapturingRegulations() {
        let regulator = EmptyingRegulator()
        let emptied = PublisherEventKind(regulator: regulator)

        TS.capturePublisherRegulations { _ in
            var emittedCount = 0
            let cancellable = Just(1)
                .regulate(as: emptied)
                .sink(receiveValue: { _ in emittedCount += 1 })
            cancellable.cancel()

            // We expect the value to be passed through without calling `EmptyingRegulator`.
            TS.assert(regulator.callbackCount, equals: 0)
            TS.assert(emittedCount, equals: 1)
        }

        // We should be back to normal now:

        var emittedCount = 0
        let cancellable = Just(1)
            .regulate(as: emptied)
            .sink(receiveValue: { _ in emittedCount += 1 })
        cancellable.cancel()

        TS.assert(regulator.callbackCount, equals: 1)
        TS.assert(emittedCount, equals: 0)
    }

    func testCapturedRegulationsAreReported() {
        let regulator = EmptyingRegulator()
        let kind = PublisherEventKind(regulator: regulator)

        TS.capturePublisherRegulations { monitor in
            var completionCount = 0
            var emittedCount = 0
            Just(1)
                .regulate(as: kind)
                .sink(
                    receiveCompletion: { _ in
                        completionCount += 1
                        XCTAssert(monitor.isBeingRegualted(as: kind))
                    },
                    receiveValue: { _ in
                        emittedCount += 1
                        XCTAssert(monitor.isBeingRegualted(as: kind))
                    }
                )
                .cancel()

            XCTAssertFalse(monitor.isBeingRegualted(as: kind))

            TS.assert(emittedCount, equals: 1)
            TS.assert(completionCount, equals: 1)
        }
    }

    func testPausingEventDelivery() {
        let regulator = EmptyingRegulator()
        let kind = PublisherEventKind(regulator: regulator)

        TS.capturePublisherRegulations { monitor in
            var completionCount = 0
            var emittedCount = 0

            monitor.pauseEvents(for: kind)

            let cancellable = Just(1)
                .regulate(as: kind)
                .sink(
                    receiveCompletion: { _ in
                        completionCount += 1
                        // Should be regulated even if delivered after resume
                        XCTAssert(monitor.isBeingRegualted(as: kind))
                    },
                    receiveValue: { _ in
                        emittedCount += 1
                        // Should be regulated even if delivered after resume
                        XCTAssert(monitor.isBeingRegualted(as: kind))
                    }
                )
            defer { cancellable.cancel() }

            TS.assert(emittedCount, equals: 0)
            TS.assert(completionCount, equals: 0)

            monitor.resumeEvents(for: kind)

            TS.assert(emittedCount, equals: 1)
            TS.assert(completionCount, equals: 1)
        }
    }

}

private class EmptyingRegulator: PublisherRegulator {
    var callbackCount = 0
    func regulate<T>(_ publisher: T) -> AnyPublisher<T.Output, T.Failure> where T: Publisher {
        callbackCount += 1
        return Empty().eraseToAnyPublisher()
    }
}
