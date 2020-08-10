//
// Copyright © 2020 NHSX. All rights reserved.
//

import CryptoKit
import Foundation

/// A signature made with ECDSA using P-256 and SHA-256.
struct ES256Signature {
    
    // `r` and `s` are both guaranteed to be 32 bytes
    fileprivate let r: Data
    fileprivate let s: Data
    
    private init(r: Data, s: Data) {
        precondition(r.count == 32)
        precondition(s.count == 32)
        self.r = r
        self.s = s
    }
    
}

extension ES256Signature {
    
    struct Encoding {
        fileprivate var encode: (ES256Signature) -> Data
        fileprivate var decode: (Data) throws -> ES256Signature
    }
    
    func data(using encoding: Encoding) -> Data {
        encoding.encode(self)
    }
    
    init(data: Data, encoding: Encoding) throws {
        self = try encoding.decode(data)
    }
    
    init(_ signature: P256.Signing.ECDSASignature) throws {
        try self.init(data: signature.derRepresentation, encoding: .der)
    }
    
}

extension ES256Signature.Encoding {
    
    private enum Errors: Error {
        case invalidSignatureData
    }
    
    /// JWS encoding
    ///
    /// Spec: https://tools.ietf.org/html/rfc7518#section-3.4
    static let jws = ES256Signature.Encoding(
        // Encoding is just r|s
        encode: { $0.r + $0.s },
        decode: { data in
            guard data.count == 64 else {
                throw Errors.invalidSignatureData
            }
            let start = data.startIndex
            return ES256Signature(
                r: data[start ..< start + 32],
                s: data[start + 32 ..< start + 64]
            )
        }
    )
    
    private static let asn1Sequence = UInt8(0x30)
    private static let asn1Integer = UInt8(0x02)
    
    /// ASN.1 DER encoding
    ///
    /// Spec: https://tools.ietf.org/html/rfc5480#appendix-A
    static let der = ES256Signature.Encoding(
        // Signature is encoded as:
        // ECDSA-Sig-Value ::= SEQUENCE {
        //   r  INTEGER,
        //   s  INTEGER
        // }
        encode: { signature in
            
            let makeASN1Int = { (value: Data) -> Data in
                // DER encoding requires the top bit to be zero
                let hasLeadingZero = (value.first! & 0b1000_0000) == 0
                let header: Data
                if hasLeadingZero {
                    header = Data([asn1Integer, UInt8(value.count)])
                } else {
                    header = Data([asn1Integer, UInt8(value.count) + 1, 0])
                }
                return header + value
            }
            
            let integers = makeASN1Int(signature.r) + makeASN1Int(signature.s)
            return Data([asn1Sequence, UInt8(integers.count)]) + integers
        },
        decode: { data in
            var scanner = ASN1Scanner(data: data)
            
            try scanner.scanSequenceHeader()
            
            let readInteger = { () -> Data in
                let integer = try scanner.scanInteger()
                
                // there may be leading a zero in `integer`. Trim it
                let expectedLength = 32
                guard integer.count >= expectedLength else {
                    throw Errors.invalidSignatureData
                }
                
                return integer.suffix(expectedLength)
            }
            
            return ES256Signature(
                r: try readInteger(),
                s: try readInteger()
            )
        }
    )
    
}

extension P256.Signing.ECDSASignature {
    
    init(_ signature: ES256Signature) throws {
        try self.init(derRepresentation: signature.data(using: .der))
    }
    
}
