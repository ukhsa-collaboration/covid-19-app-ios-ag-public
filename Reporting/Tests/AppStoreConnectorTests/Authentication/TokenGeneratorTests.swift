//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest
@testable import AppStoreConnector

class TokenGeneratorTests: XCTestCase {
    
    private struct Header: Decodable, Equatable {
        var alg: String
        var kid: String
        var typ: String
    }
    
    private struct Payload: Decodable, Equatable {
        var iss: String
        var exp: Double
        var aud: String
    }
    
    private let key: EC256PrivateKey! = try? EC256PrivateKey(pemFormatted: SampleKey.pemString)
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCTAssertNotNil(key)
        continueAfterFailure = true
    }
    
    func testToken() {
        let keyID = UUID().uuidString
        let issuerID = UUID().uuidString
        let expirationTime = 1554735767.0
        let expirationDate = Date(timeIntervalSince1970: expirationTime)
        
        let expectedHeader = Header(
            alg: "ES256",
            kid: keyID,
            typ: "JWT"
        )
        
        let expectedPayload = Payload(
            iss: issuerID,
            exp: expirationTime,
            aud: "appstoreconnect-v1"
        )
        
        let generator = AuthTokenGenerator(
            key: key,
            keyID: keyID,
            issuerID: issuerID
        )
        
        do {
            let token = try generator.token(expiryingAt: expirationDate)
            let parts = token.components(separatedBy: ".")
            
            continueAfterFailure = false
            XCTAssertEqual(parts.count, 3, "A JWT must have three parts.")
            continueAfterFailure = true
            
            let header = try JSONDecoder().decode(Header.self, fromBase64URLEncoded: parts[0])
            let payload = try JSONDecoder().decode(Payload.self, fromBase64URLEncoded: parts[1])
            
            let message = "\(parts[0]).\(parts[1])".data(using: .utf8)!
            let signatureData = Data(base64URLEncoded: parts[2]) ?? Data()
            let signature = try ES256Signature(data: signatureData, encoding: .jws)
            
            XCTAssertEqual(header, expectedHeader)
            XCTAssertEqual(payload, expectedPayload)
            XCTAssertNoThrow(try key.verify(message, hasSignature: signature))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
}

private extension JSONDecoder {
    
    func decode<T: Decodable>(_ type: T.Type, fromBase64URLEncoded base64URLEncoded: String) throws -> T {
        let data = Data(base64URLEncoded: base64URLEncoded) ?? Data()
        return try decode(type, from: data)
    }
    
}
