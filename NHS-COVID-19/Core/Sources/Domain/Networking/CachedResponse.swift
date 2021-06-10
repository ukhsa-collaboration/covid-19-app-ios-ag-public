//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation

/// Provides a cached value
///
/// This type returns the cached response from an endpoint. If there’s no cached value, then an initial value is used.
/// You can call `update` to ask the cache to refresh its response.
class CachedResponse<Output> {
    
    private let httpClient: HTTPClient
    private let endpoint: ResponseEchoingEndpoint<Output>
    private let currentDateProvider: DateProviding?
    private let updatedSubject: CurrentValueSubject<(old: Output?,new: Output?)?, Never>?

    @FileStored
    private var cachedData: Data?
    
    @Published
    private(set) var value: Output
    private(set) var lastUpdated: Date?
    private(set) var updating: Bool = false
    
    init<Endpoint>(
        httpClient: HTTPClient,
        endpoint: Endpoint,
        storage: FileStoring,
        name: String,
        initialValue: Output,
        currentDateProvider: DateProviding? = nil,
        updatedSubject:  CurrentValueSubject<(old: Output?,new: Output?)?, Never>? = nil
    ) where Endpoint: HTTPEndpoint, Endpoint.Input == Void, Endpoint.Output == Output {
        self.httpClient = httpClient
        self.endpoint = ResponseEchoingEndpoint(endpoint)
        
        _cachedData = FileStored<Data>(storage: storage, name: name)
        let storedValue = _cachedData.response.flatMap { try? endpoint.parse($0) }
        value = storedValue ?? initialValue
        self.currentDateProvider = currentDateProvider
        self.updatedSubject = updatedSubject
    }
    
    func load() {
        if let updatedSubject = self.updatedSubject {
            updatedSubject.send((old: value, new: value))
        }
    }
    
    /// Attempts to update the cache.
    ///
    /// This method does nothing if the network call fails.
    func update() -> AnyPublisher<Void, Never> {
        #warning("'updating' may not be changed atomically but at worst should result in multiple fetches rather than none")
        updating = true
        return httpClient.fetch(endpoint)
            .map(receive)
            .catch(failed)
            .eraseToAnyPublisher()
    }
    
    private func failed(_ error: Error) -> AnyPublisher<Void, Never> {
        updating = false
        return Empty().eraseToAnyPublisher()
    }
    
    private func receive(_ response: HTTPResponse, _ output: Output) {
        if let currentDateProvider = currentDateProvider {
            lastUpdated = currentDateProvider.currentDate
        }
        let original = value
        cachedData = response.body.content
        value = output
        updating = false
        updatedSubject?.send((old: original, new: value))
    }
    
}

private extension FileStored where Wrapped == Data {
    
    var response: HTTPResponse? {
        wrappedValue.map {
            .ok(with: .untyped($0))
        }
    }
    
}

private struct ResponseEchoingEndpoint<Payload>: HTTPEndpoint {
    
    var makeRequest: (()) throws -> HTTPRequest
    var parsePayload: (HTTPResponse) throws -> Payload
    
    init<Endpoint>(_ endpoint: Endpoint) where Endpoint: HTTPEndpoint, Endpoint.Input == Void, Endpoint.Output == Payload {
        makeRequest = endpoint.request
        parsePayload = endpoint.parse
    }
    
    func request(for input: ()) throws -> HTTPRequest {
        try makeRequest(())
    }
    
    func parse(_ response: HTTPResponse) throws -> (HTTPResponse, Payload) {
        (response, try parsePayload(response))
    }
    
}
