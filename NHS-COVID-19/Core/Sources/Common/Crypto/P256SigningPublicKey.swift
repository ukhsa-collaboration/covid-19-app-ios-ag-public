//
// Copyright © 2020 NHSX. All rights reserved.
//

import CryptoKit
import Foundation

extension P256.Signing.PublicKey {
    
    fileprivate enum Errors: Error {
        case dataIsNotBase64Encoded
    }
    
    #warning("Use the implementation provided by the OS on iOS 14.")
    // This needs to be done in two stages.
    // * When we start using Xcode 12, implement an availability check and use new API if available.
    // * Whenever we stop supporting iOS 13, we can delete this completely.
    public init(pemRepresentationCompatibility string: String) throws {
        let undecoratedString = string
            .split(separator: "\n")
            .filter { !($0.isEmpty || $0.hasPrefix("-----")) }
            .joined()
        
        guard let asn1 = Data(base64Encoded: undecoratedString) else {
            throw Errors.dataIsNotBase64Encoded
        }
        try self.init(asn1Encoded: asn1)
    }
    
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

private enum EllipticCurveErrors: Error {
    case invalidASN1
    case publicKeyConversionFailed
    case unhandledCFError(_ error: CFError)
    
    case couldNotSaveToKeychain(_ status: OSStatus)
    case unhandledKeychainError(_ status: OSStatus)
}
