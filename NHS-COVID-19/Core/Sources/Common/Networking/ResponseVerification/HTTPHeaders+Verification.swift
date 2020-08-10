//
// Copyright © 2020 NHSX. All rights reserved.
//

import CryptoKit
import Foundation

extension HTTPHeaders {
    
    var signatureHeader: SignatureHeader? {
        SignatureHeader(from: self)
    }
    
    var requestId: String? {
        get {
            fields[.requestId]
        }
        set {
            fields[.requestId] = newValue
        }
    }
    
    var signatureDate: String? {
        fields[.signatureDate]
    }
    
}

struct SignatureHeader {
    
    var keyId: String
    var signature: P256.Signing.ECDSASignature
    
    fileprivate init?(from headers: HTTPHeaders) {
        guard let header = headers.fields[.signature] else { return nil }
        
        let rawParts = header.components(separatedBy: ",")
        guard
            rawParts.count == 2,
            let keyId = Part(from: rawParts[0], expectName: "keyId"),
            let signatureField = Part(from: rawParts[1], expectName: "signature"),
            let signatureData = Data(base64Encoded: signatureField.value),
            let signature = try? P256.Signing.ECDSASignature(derRepresentation: signatureData)
        else { return nil }
        
        self.keyId = keyId.value
        self.signature = signature
    }
    
    private struct Part {
        var value: String
        
        init?(from string: String, expectName name: String) {
            let scanner = Scanner(string: string)
            guard
                scanner.scanString(name) != nil,
                scanner.scanString("=\"") != nil,
                let value = scanner.scanUpToString("\""), !value.isEmpty,
                scanner.scanString("\"") != nil,
                scanner.isAtEnd
            else { return nil }
            
            self.value = value
        }
    }
}

private extension HTTPHeaderFieldName {
    
    static let signature = HTTPHeaderFieldName("x-amz-meta-signature")
    static let signatureDate = HTTPHeaderFieldName("x-amz-meta-signature-date")
    static let requestId = HTTPHeaderFieldName("request-id")
    
}
