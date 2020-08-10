//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import CryptoKit
import Foundation

public final class MockHTTPResponseVerifier: HTTPResponseVerifying {
    
    public var shouldConsiderSignatureValid = true
    
    public init() {}
    
    public func prepare(_ request: HTTPRequest) -> HTTPRequest {
        request
    }
    
    public func canAccept(_ response: HTTPResponse, for request: HTTPRequest) -> Bool {
        shouldConsiderSignatureValid
    }
    
}
