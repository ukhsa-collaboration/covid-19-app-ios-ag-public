//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation

class MockServer: HTTPClient {
    
    private let queue = DispatchQueue(label: "MockServer")
    
    var requestCount = 0
    
    private var handlers: [RequestHandler]
    
    init(dataProvider: MockDataProvider = MockScenario.mockDataProvider) {
        handlers = [
            ActivationHandler(),
            AppAvailabilityHandler(dataProvider: dataProvider),
            CircuitBreakerExposureNotificationHandler(),
            CircuitBreakerVenueHandler(),
            DiagnosisKeysHandler(),
            ExposureConfigurationHandler(),
            KeysDistributionHandler(),
            LookUpHandler(dataProvider: dataProvider),
            RiskyPostDistrictsHandler(dataProvider: dataProvider),
            RiskyVenueHandler(dataProvider: dataProvider),
            SymptomaticQuestionnaireHandler(),
            VirologyTestOrderHandler(dataProvider: dataProvider),
            VirologyTestResultsHandler(dataProvider: dataProvider),
        ]
    }
    
    struct TestError: Error {}
    var cancellables = [AnyCancellable]()
    
    func perform(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, HTTPRequestError> {
        _perform(request).regulate(as: .simulatedNetwork)
    }
    
    func _perform(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, HTTPRequestError> {
        requestCount += 1
        
        if let handler = handlers.first(where: { $0.hasResponse(for: request.path) }) {
            return handler.response.publisher.eraseToAnyPublisher()
        }
        
        let error = HTTPRequestError.rejectedRequest(underlyingError: TestError())
        return Result.failure(error).publisher.eraseToAnyPublisher()
    }
}

private extension PublisherEventKind {
    
    static let simulatedNetwork = PublisherEventKind(label: "simualtedNetwork", regulator: SimulatedNetworkRegulator())
    
}

private class SimulatedNetworkRegulator: PublisherRegulator {
    
    static let queue = DispatchQueue(label: "simulated-network")
    
    var maximumDelay: Double = 3
    
    func regulate<T>(_ publisher: T) -> AnyPublisher<T.Output, T.Failure> where T: Publisher {
        publisher
            .delay(for: .milliseconds(.random(in: 0 ... Int(maximumDelay * 1000))), scheduler: Self.queue)
            .eraseToAnyPublisher()
    }
}
