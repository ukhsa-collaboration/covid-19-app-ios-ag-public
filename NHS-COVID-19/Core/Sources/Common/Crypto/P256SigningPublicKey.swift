//
// Copyright © 2021 DHSC. All rights reserved.
//

import CryptoKit
import Foundation

extension P256.Signing.PublicKey {
    
    @available(iOS, deprecated: 14.0)
    fileprivate enum Errors: Error {
        case dataIsNotBase64Encoded
    }
    
    @available(iOS, deprecated: 14.0, renamed: "init(pemRepresentation:)")
    public init(pemRepresentationCompatibility string: String) throws {
        if #available(iOS 14, *) {
            try self.init(pemRepresentation: string)
        } else {
            let undecoratedString = string
                .split(separator: "\n")
                .filter { !($0.isEmpty || $0.hasPrefix("-----")) }
                .joined()
            
            guard let asn1 = Data(base64Encoded: undecoratedString) else {
                throw Errors.dataIsNotBase64Encoded
            }
            try self.init(asn1Encoded: asn1)
        }
    }
    
    @available(iOS, deprecated: 14.0)
    private init(asn1Encoded data: Data) throws {
        var scanner = ASN1Scanner(data: data)
        try scanner.scanSequenceHeader()
        
        let algorithmIdentifierLength = try scanner.scanSequenceHeader()
        scanner.stream = scanner.stream.dropFirst(algorithmIdentifierLength)
        
        let publicKey = try scanner.scanBitString()
        let publicKeyIsUncompressed = publicKey.starts(with: [0x00, 0x04])
        guard publicKeyIsUncompressed else {
            throw EllipticCurveErrors.invalidASN1
        }
        
        let x = publicKey[publicKey.startIndex + 2 ..< publicKey.startIndex + 2 + 32]
        let y = publicKey[publicKey.startIndex + 2 + 32 ..< publicKey.startIndex + 2 + 32 + 32]
        let rawRepresentation = x + y
        
        try self.init(rawRepresentation: rawRepresentation)
    }
    
}

@available(iOS, deprecated: 14.0)
private enum EllipticCurveErrors: Error {
    case invalidASN1
    case publicKeyConversionFailed
    case unhandledCFError(_ error: CFError)
    
    case couldNotSaveToKeychain(_ status: OSStatus)
    case unhandledKeychainError(_ status: OSStatus)
}
