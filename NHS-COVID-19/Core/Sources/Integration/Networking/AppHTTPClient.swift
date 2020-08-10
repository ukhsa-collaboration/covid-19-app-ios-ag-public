//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import CryptoKit
import Domain
import Foundation
import ProductionConfiguration

public struct AppHTTPClient: HTTPClient {
    
    public enum RemoteKind {
        case distribution
        case submission
    }
    
    private let client: HTTPClient
    private let responseVerifier: HTTPResponseVerifying
    
    public init(for remote: Remote, kind: RemoteKind) {
        client = URLSessionHTTPClient(
            remote: HTTPRemote(for: remote),
            session: URLSession(for: remote)
        )
        switch kind {
        case .distribution:
            responseVerifier = HTTPResponseTimestampedSignatureVerifier(for: remote)
        case .submission:
            responseVerifier = HTTPResponseRequestBoundSignatureVerifier(for: remote)
        }
    }
    
    public func perform(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, HTTPRequestError> {
        let preparedRequest = responseVerifier.prepare(request)
        return client.perform(preparedRequest)
            .flatMap { self.responseVerifier.verify($0, for: preparedRequest).publisher }
            .eraseToAnyPublisher()
    }
    
}

private extension HTTPRemote {
    
    init(for remote: Remote) {
        self.init(
            host: remote.host,
            path: remote.path,
            headers: HTTPHeaders(fields: remote.headers)
        )
    }
    
}

private extension URLSession {
    
    convenience init(for remote: Remote) {
        self.init(trustValidator: PublicKeyValidator(pins: remote.publicKeyPins))
    }
    
}

private extension HTTPResponseRequestBoundSignatureVerifier {
    
    init(for remote: Remote) {
        let key = try! P256.Signing.PublicKey(pemRepresentationCompatibility: remote.signatureKey.pemRepresentation)
        self.init(key: key, id: remote.signatureKey.id)
    }
    
}

private extension HTTPResponseTimestampedSignatureVerifier {
    
    init(for remote: Remote) {
        let key = try! P256.Signing.PublicKey(pemRepresentationCompatibility: remote.signatureKey.pemRepresentation)
        self.init(key: key, id: remote.signatureKey.id)
    }
    
}
