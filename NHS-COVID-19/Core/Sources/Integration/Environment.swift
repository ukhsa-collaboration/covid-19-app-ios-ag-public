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
    public let distributionClient: HTTPClient
    public let apiClient: HTTPClient
    public let iTunesClient: HTTPClient
    public let venueDecoder: VenueDecoding
    public let backgroundTaskIdentifier: String
    public let identifier: String
    public let appInfo: AppInfo

    public struct CopyServices {
        public let project: String
        public let token: String

        public init(project: String, token: String) {
            self.project = project
            self.token = token
        }
    }

    public let copyServices: CopyServices?
}

public extension Environment {

    static func standard(with configuration: EnvironmentConfiguration = .production) -> Environment {
        let appInfo = AppInfo(for: .main)
        let userAgentHeaderValue = "p=iOS,o=\(Version.iOSVersion.readableRepresentation),v=\(appInfo.version.readableRepresentation),b=\(appInfo.buildNumber)"

        let copyServices: Environment.CopyServices?
        if let project = configuration.copyServices?.project,
            let token = configuration.copyServices?.token {
            copyServices = Environment.CopyServices(project: project, token: token)
        } else {
            copyServices = nil
        }

        return Environment(
            distributionClient: AppHTTPClient(for: configuration.distributionRemote, kind: .distribution),
            apiClient: AppHTTPClient(for: configuration.submissionRemote, kind: .submission(userAgentHeaderValue: userAgentHeaderValue)),
            iTunesClient: URLSessionHTTPClient(remote: HTTPRemote.iTunes),
            venueDecoder: VenueDecoder(for: .qrCodes),
            backgroundTaskIdentifier: BackgroundTaskIdentifiers(in: .main).exposureNotification!,
            identifier: configuration.identifier,
            appInfo: appInfo,
            copyServices: copyServices
        )
    }

    static func mock(with client: HTTPClient, copyServices: CopyServices? = nil) -> Environment {
        Environment(
            distributionClient: client,
            apiClient: client,
            iTunesClient: client,
            venueDecoder: VenueDecoder(for: .qrCodes),
            backgroundTaskIdentifier: BackgroundTaskIdentifiers(in: .main).exposureNotification!,
            identifier: "mock",
            appInfo: AppInfo(for: .main),
            copyServices: copyServices.map { Environment.CopyServices(project: $0.project, token: $0.token) }
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
