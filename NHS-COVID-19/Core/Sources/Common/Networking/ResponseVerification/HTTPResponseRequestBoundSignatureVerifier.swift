//
// Copyright © 2020 NHSX. All rights reserved.
//

import CryptoKit
import Foundation

public struct HTTPResponseRequestBoundSignatureVerifier: HTTPResponseVerifying {
    
    public var key: P256.Signing.PublicKey
    public var id: String
    
    public init(key: P256.Signing.PublicKey, id: String) {
        self.key = key
        self.id = id
    }
    
    public func prepare(_ request: HTTPRequest) -> HTTPRequest {
        
        let preparedHeaders = mutating(request.headers) {
            $0.requestId = UUID().uuidString
        }
        
        return HTTPRequest(
            method: request.method,
            path: request.path,
            body: request.body,
            fragment: request.fragment,
            queryParameters: request.queryParameters,
            headers: preparedHeaders
        )
    }
    
    public func canAccept(_ response: HTTPResponse, for request: HTTPRequest) -> Bool {
        guard
            let requestId = request.headers.requestId,
            let signatureHeader = response.headers.signatureHeader,
            let signatureDate = response.headers.signatureDate,
            signatureHeader.keyId == id
        else { return false }
        
        let digest = SHA256.hash(from: [
            "\(requestId):\(request.method.rawValue):\(request.path):\(signatureDate):".data(using: .utf8)!,
            response.body.content,
        ])
        
        return key.isValidSignature(signatureHeader.signature, for: digest)
    }
    
}
