//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation
import Logging

enum TrafficObfuscator: String, Encodable {
    case circuitBreaker
    case exposureWindow
    case keySubmission
    case exposureWindowAfterPositive
}

class TrafficObfuscationClient {

    let httpClient: HTTPClient
    let rateLimiter: ObfuscationRateLimiting

    var cancellables = [AnyCancellable]()
    private static let logger = Logger(label: "TrafficObfuscationClient")

    init(client: HTTPClient, rateLimiter: ObfuscationRateLimiting) {
        self.httpClient = client
        self.rateLimiter = rateLimiter
    }

    func sendTraffic(for source: TrafficObfuscator, randomRange: ClosedRange<Int>, numberOfActualCalls: Int) {

        guard rateLimiter.allow else {
            Self.logger.info("Blocking traffic")
            return
        }
        Self.logger.info("Sending traffic")

        let randomNumberOfCalls = Int.random(in: randomRange)
        Self.logger.info("Random number: \(randomNumberOfCalls)")

        guard numberOfActualCalls < randomNumberOfCalls else {
            return
        }

        for _ in 1 ... randomNumberOfCalls - numberOfActualCalls {
            post(for: source)
        }
    }

    func sendSingleTraffic(for source: TrafficObfuscator) {

        guard rateLimiter.allow else {
            Self.logger.info("Blocking single traffic")
            return
        }
        Self.logger.info("Sending single traffic")

        post(for: source)
    }

    private func post(for source: TrafficObfuscator) {
        httpClient.fetch(EmptyEndpoint(), with: source)
            .ensureFinishes(placeholder: ())
            .sink { _ in }
            .store(in: &cancellables)
    }
}
