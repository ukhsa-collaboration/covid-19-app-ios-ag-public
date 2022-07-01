//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import TestSupport
import XCTest

class PublisherRegulationTests: XCTestCase {

    func testRegulationUsesRegulator() {
        let regulator = NoOpPublisherRegulator()
        let eventKind = PublisherEventKind(regulator: regulator)
        _ = Empty<Void, Never>().regulate(as: eventKind)

        // This is a weak assertion: regulator being called back doesn’t mean we are actually _using_ the regulated
        // publisher. But given the simplicity of the implementation, it’s quite likely that we are.
        // Testing that we’re indeed returning the regulated publisher (and that it hasn’t been further modified) is
        // not that easy, so it’s not worth the code complexity in the tests.
        TS.assert(regulator.callbackCount, equals: 1)
    }

}

private class NoOpPublisherRegulator: PublisherRegulator {
    var callbackCount = 0

    func regulate<T>(_ publisher: T) -> AnyPublisher<T.Output, T.Failure> where T: Publisher {
        callbackCount += 1
        return publisher.eraseToAnyPublisher()
    }
}
