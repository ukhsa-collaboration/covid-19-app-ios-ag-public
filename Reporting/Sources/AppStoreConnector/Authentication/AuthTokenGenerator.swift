//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

struct AuthTokenGenerator {

    var key: EC256PrivateKey
    var keyID: String
    var issuerID: String

    func token(expiryingAt expiryDate: Date) throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970

        let headerAndPayload = [
            try encoder.encode(header),
            try encoder.encode(payload(expiryingAt: expiryDate)),
        ]
        .map { $0.base64URLEncodedString() }
        .joined(separator: ".")

        // `utf8` data generation can’t fail
        let dataToSign = headerAndPayload.data(using: .utf8)!

        let signature = try key.sign(dataToSign).data(using: .jws).base64URLEncodedString()

        return "\(headerAndPayload).\(signature)"
    }

}

private extension AuthTokenGenerator {

    struct Header: Encodable, Equatable {
        var alg: String
        var kid: String
        var typ: String
    }

    struct Payload: Encodable, Equatable {
        var iss: String
        var exp: Date
        var aud: String
    }

    var header: Header {
        Header(
            alg: "ES256",
            kid: keyID,
            typ: "JWT"
        )
    }

    func payload(expiryingAt expiryDate: Date) -> Payload {
        Payload(
            iss: issuerID,
            exp: expiryDate,
            aud: "appstoreconnect-v1"
        )
    }

}
