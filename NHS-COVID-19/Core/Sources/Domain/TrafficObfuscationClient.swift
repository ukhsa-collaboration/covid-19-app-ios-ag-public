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
    
    var httpClient: HTTPClient
    var cancellables = [AnyCancellable]()
    private static let logger = Logger(label: "TrafficObfuscationClient")
    
    init(client: HTTPClient) {
        httpClient = client
    }
    
    func sendTraffic(for source: TrafficObfuscator, randomRange: ClosedRange<Int>, numberOfActualCalls: Int) {
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
        post(for: source)
    }
    
    private func post(for source: TrafficObfuscator) {
        httpClient.fetch(EmptyEndpoint(), with: source)
            .ensureFinishes(placeholder: ())
            .sink { _ in }
            .store(in: &cancellables)
    }
}
