//
// Copyright © 2021 DHSC. All rights reserved.
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
    var venueDecoder: VenueDecoder
    var backgroundTaskIdentifier: String
    var identifier: String
    var appInfo: AppInfo
}

public extension Environment {
    
    static func standard(with configuration: EnvironmentConfiguration = .production) -> Environment {
        let appInfo = AppInfo(for: .main)
        let userAgentHeaderValue = "p=iOS,o=\(Version.iOSVersion.readableRepresentation),v=\(appInfo.version.readableRepresentation),b=\(appInfo.buildNumber)"
        
        return Environment(
            distributionClient: AppHTTPClient(for: configuration.distributionRemote, kind: .distribution),
            apiClient: AppHTTPClient(for: configuration.submissionRemote, kind: .submission(userAgentHeaderValue: userAgentHeaderValue)),
            iTunesClient: URLSessionHTTPClient(remote: HTTPRemote.iTunes),
            venueDecoder: VenueDecoder(for: .qrCodes),
            backgroundTaskIdentifier: BackgroundTaskIdentifiers(in: .main).exposureNotification!,
            identifier: configuration.identifier,
            appInfo: appInfo
        )
    }
    
    static func mock(with client: HTTPClient) -> Environment {
        Environment(
            distributionClient: client,
            apiClient: client,
            iTunesClient: client,
            venueDecoder: VenueDecoder(for: .qrCodes),
            backgroundTaskIdentifier: BackgroundTaskIdentifiers(in: .main).exposureNotification!,
            identifier: "mock",
            appInfo: AppInfo(for: .main)
        )
    }
    
}

private extension HTTPRemote {
    
    static let iTunes = HTTPRemote(host: "itunes.apple.com", path: "")
    
}

private extension VenueDecoder {
    
    init(for signatureKey: SigningKeyInfo) {
        self.init(
            keyId: signatureKey.id,
            key: try! P256.Signing.PublicKey(pemRepresentationCompatibility: signatureKey.pemRepresentation)
        )
    }
    
}
