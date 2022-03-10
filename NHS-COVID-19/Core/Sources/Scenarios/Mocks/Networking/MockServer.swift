//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation
import Logging

class MockServer: HTTPClient {
    
    private static let logger = Logger(label: "MockServer")
    
    private let queue = DispatchQueue(label: "MockServer")
    
    var requestCount = 0
    
    private var handlers: [RequestHandler]
    
    init(dataProvider: MockDataProvider = .shared) {
        handlers = [
            ActivationHandler(),
            AppAvailabilityHandler(dataProvider: dataProvider),
            CircuitBreakerExposureNotificationHandler(),
            CircuitBreakerVenueHandler(),
            DiagnosisKeysHandler(),
            ExposureConfigurationHandler(),
            KeysDistributionHandler(),
            LocalMessagesHandler(dataProvider: dataProvider),
            LookUpHandler(dataProvider: dataProvider),
            RiskyPostDistrictsHandler(dataProvider: dataProvider),
            RiskyVenueHandler(dataProvider: dataProvider),
            RiskyVenueConfigurationHandler(dataProvider: dataProvider),
            SymptomaticQuestionnaireHandler(),
            VirologyTestOrderHandler(dataProvider: dataProvider),
            VirologyTestResultsHandler(dataProvider: dataProvider),
            LinkVirologyTestResultHandler(dataProvider: dataProvider),
            IsolationPaymentCreateHandler(),
            IsolationPaymentUpdateHandler(),
            EmptyHandler(),
            LocalCovidStatsHandler(dataProvider: dataProvider),
            IsolationConfigurationHandler(dataProvider: dataProvider),
        ]
    }
    
    struct TestError: Error {}
    var cancellables = [AnyCancellable]()
    
    func perform(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, HTTPRequestError> {
        _perform(request).regulate(as: .simulatedNetwork)
    }
    
    func _perform(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, HTTPRequestError> {
        requestCount += 1
        
        Self.logger.debug("starting request", metadata: .describing(request))
        
        let responseHandlers = handlers.filter { $0.hasResponse(for: request.path) }
        precondition(responseHandlers.count <= 1, "Found multiple handlers for same url")
        if let handler = responseHandlers.first {
            return handler.response.publisher
                .handleEvents()
                .log(into: Self.logger, level: .debug, "ending request- \(request.path)")
                .eraseToAnyPublisher()
        }
        
        let error = HTTPRequestError.rejectedRequest(underlyingError: TestError())
        return Result.failure(error).publisher
            .handleEvents(
                receiveCompletion: { _ in
                    Self.logger.debug("ending request with error, no response implemented - \(request.path)")
                }
            )
            .eraseToAnyPublisher()
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
