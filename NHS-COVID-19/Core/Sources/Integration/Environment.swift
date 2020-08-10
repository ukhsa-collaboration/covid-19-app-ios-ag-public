//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import CryptoKit
import Domain
import Foundation
import ProductionConfiguration

public struct Environment {
    var distributionClient: HTTPClient
    var apiClient: HTTPClient
    var iTunesClient: HTTPClient
    var venueDecoder: QRCode
    var backgroundTaskIdentifier: String
    var identifier: String
}

public extension Environment {
    
    static func standard(with configuration: EnvironmentConfiguration = .production) -> Environment {
        Environment(
            distributionClient: AppHTTPClient(for: configuration.distributionRemote, kind: .distribution),
            apiClient: AppHTTPClient(for: configuration.submissionRemote, kind: .submission),
            iTunesClient: URLSessionHTTPClient(remote: HTTPRemote.iTunes),
            venueDecoder: QRCode(for: .qrCodes),
            backgroundTaskIdentifier: BackgroundTaskIdentifiers(in: .main).exposureNotification!,
            identifier: configuration.identifier
        )
    }
    
    static func mock(with client: HTTPClient) -> Environment {
        Environment(
            distributionClient: client,
            apiClient: client,
            iTunesClient: client,
            venueDecoder: QRCode(for: .qrCodes),
            backgroundTaskIdentifier: BackgroundTaskIdentifiers(in: .main).exposureNotification!,
            identifier: "mock"
        )
    }
    
}

private extension HTTPRemote {
    
    static let iTunes = HTTPRemote(host: "itunes.apple.com", path: "")
    
}

private extension QRCode {
    
    init(for signatureKey: SignatureKey) {
        self.init(
            keyId: signatureKey.id,
            key: try! P256.Signing.PublicKey(pemRepresentationCompatibility: signatureKey.pemRepresentation)
        )
    }
    
}
