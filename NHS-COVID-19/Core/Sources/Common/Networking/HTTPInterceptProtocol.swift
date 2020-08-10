//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Foundation

public final class HTTPInterceptProtocol: URLProtocol {
    
    private let httpClient: HTTPClient
    
    private var cancellable: AnyCancellable?
    
    override public init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        guard let httpClient = Self.httpClient(for: request) else {
            Thread.fatalError("\(Self.self) should not be initialised without a registered `HTTPClient`.")
        }
        self.httpClient = httpClient
        super.init(request: request, cachedResponse: cachedResponse, client: client)
    }
    
    override public func startLoading() {
        guard
            let method = HTTPMethod(rawValue: request.httpMethod ?? ""),
            let url = request.url,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else { return }
        
        let pathComponents = mutating(components.path.components(separatedBy: "/")) {
            $0.remove(at: 1) // remove service path
        }
        
        let queryParameters = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).map {
            ($0.name, $0.value ?? "")
        })
        
        var headers = request.headers
        
        let body = request.httpBodyStream.map { stream in
            HTTPRequest.Body(content: try! Data(from: stream), type: headers.fields[.contentType] ?? "")
        }
        
        HTTPHeaderFieldName.bodyHeaders.forEach {
            headers.fields.removeValue(forKey: $0)
        }
        
        let httpRequest = HTTPRequest(
            method: method,
            path: pathComponents.joined(separator: "/"),
            body: body,
            fragment: components.fragment,
            queryParameters: queryParameters,
            headers: headers
        )
        
        cancellable = httpClient.perform(httpRequest).sink(
            receiveCompletion: { [weak self] completion in
                guard let self = self, let client = self.client else { return }
                if case .failure(let error) = completion {
                    switch error {
                    case .networkFailure(let underlyingError):
                        client.urlProtocol(self, didFailWithError: underlyingError)
                    case .rejectedRequest(let underlyingError):
                        let urlError = URLError(.unknown, userInfo: [NSUnderlyingErrorKey: underlyingError])
                        client.urlProtocol(self, didFailWithError: urlError)
                    }
                }
                client.urlProtocolDidFinishLoading(self)
            },
            receiveValue: { [weak self] httpResponse in
                guard let self = self, let client = self.client else { return }
                var headers = httpResponse.headers
                headers.fields[.contentType] = httpResponse.body.type
                let response = HTTPURLResponse(
                    url: url,
                    statusCode: httpResponse.statusCode,
                    httpVersion: nil,
                    headerFields: headers.stringFields
                )!
                client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client.urlProtocol(self, didLoad: httpResponse.body.content)
            }
        )
    }
    
    override public func stopLoading() {
        cancellable = nil
    }
    
}

// MARK: Registration

extension HTTPInterceptProtocol {
    
    public struct Registration {
        public var remote: HTTPRemote
        fileprivate var remove: () -> Void
        
        public func deregister() {
            remove()
        }
    }
    
    private static let host = "intercept.local"
    
    private static var clientsById = [String: HTTPClient]()
    
    public static func register(_ client: HTTPClient) -> Registration {
        let id = UUID().uuidString
        clientsById[id] = client
        return Registration(
            remote: HTTPRemote(host: host, path: "/\(id)"),
            remove: { clientsById.removeValue(forKey: id) }
        )
    }
    
    override public class func canInit(with request: URLRequest) -> Bool {
        httpClient(for: request) != nil
    }
    
    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    private static func httpClient(for request: URLRequest) -> HTTPClient? {
        guard
            let url = request.url,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            components.scheme == "https",
            components.host == host
        else { return nil }
        
        let pathComponents = components.path.components(separatedBy: "/")
        guard pathComponents.count > 1, pathComponents[0] == "" else {
            return nil
        }
        
        return clientsById[pathComponents[1]]
    }
    
}

private extension Data {
    init(from input: InputStream) throws {
        self.init()
        input.open()
        defer {
            input.close()
        }
        
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer {
            buffer.deallocate()
        }
        while input.hasBytesAvailable {
            let read = input.read(buffer, maxLength: bufferSize)
            if read < 0 {
                // Stream error occured
                throw input.streamError!
            } else if read == 0 {
                // EOF
                break
            }
            append(buffer, count: read)
        }
    }
}
