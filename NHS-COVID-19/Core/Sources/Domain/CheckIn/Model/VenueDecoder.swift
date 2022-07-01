//
// Copyright © 2021 DHSC. All rights reserved.
//

import CryptoKit
import Foundation

public protocol VenueDecoding {
    func decode(_ payload: String) throws -> [Venue]
}

public struct VenueDecoder: VenueDecoding {

    private var prefix = "UKC19TRACING"
    private var minimumVersionNumber = 1

    var keyId: String
    var key: P256.Signing.PublicKey

    public init(
        keyId: String,
        key: P256.Signing.PublicKey
    ) {
        self.keyId = keyId
        self.key = key
    }

    enum InitializationError: Error {
        case invalidFormat
        case invalidPrefix
        case invalidVersionNumber
        case invalidJSONData
        case invalidKey
        case invalidSignature
    }

    public func decode(_ payload: String) throws -> [Venue] {
        let parts = payload.split(separator: ":").map { String($0) }

        guard parts.count == 3 else {
            throw InitializationError.invalidFormat
        }

        guard parts[0] == prefix else {
            throw InitializationError.invalidPrefix
        }

        guard let versionNumber = Int(parts[1]), versionNumber >= minimumVersionNumber else {
            throw InitializationError.invalidVersionNumber
        }

        guard let jwt = JWT(string: parts[2]) else {
            throw InitializationError.invalidJSONData
        }

        guard jwt.keyId == keyId else {
            throw InitializationError.invalidKey
        }

        guard let signature = try? P256.Signing.ECDSASignature(rawRepresentation: jwt.signature) else {
            throw InitializationError.invalidSignature
        }

        let digest = SHA256.hash(data: jwt.signed)
        guard key.isValidSignature(signature, for: digest) else {
            throw InitializationError.invalidSignature
        }

        let decoder = JSONDecoder()
        return [try decoder.decode(Venue.self, from: jwt.payload)]
    }
}

private extension Data {

    init?(jwt: String) {
        let components = jwt.split(separator: ".").map { String($0) }
        switch components.count {
        case 3:
            self.init(jwtPart: components[1])
        default:
            return nil
        }
    }

}

private struct JWT {

    private struct Header: Codable {
        var kid: String
    }

    private struct Raw {
        var header: Data
        var payload: Data
        var signature: Data

        init?(string: String) {
            let components = string.split(separator: ".")
                .map { String($0) }
            guard components.count == 3,
                let header = Data(jwtPart: components[0]),
                let payload = Data(jwtPart: components[1]),
                let signature = Data(jwtPart: components[2]) else { return nil }

            self.header = header
            self.payload = payload
            self.signature = signature
        }
    }

    var keyId: String
    var payload: Data
    var signed: Data
    var signature: Data

    init?(string: String) {
        guard let raw = Raw(string: string) else { return nil }

        let decoder = JSONDecoder()
        guard let header = try? decoder.decode(Header.self, from: raw.header) else { return nil }

        keyId = header.kid
        payload = raw.payload
        signature = raw.signature

        signed = string.split(separator: ".")
            .map { String($0) }
            .dropLast()
            .joined(separator: ".")
            .data(using: .ascii)!
    }

}

private extension Data {

    init?(jwtPart: String) {
        var jwtPart = jwtPart
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let paddingLength = jwtPart.count.quotientAndRemainder(dividingBy: 4).remainder
        jwtPart.append(contentsOf: repeatElement("=", count: paddingLength))
        self.init(base64Encoded: jwtPart)
    }

}
