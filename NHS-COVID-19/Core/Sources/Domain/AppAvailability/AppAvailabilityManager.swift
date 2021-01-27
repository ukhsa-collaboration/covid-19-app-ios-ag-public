//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation
import UIKit

class AppAvailabilityManager {
    
    // To make it easier to test app availability features, always use the production app bundle, even when using the
    // Scenarios app.
    private static let productionAppBundleId = "uk.nhs.covid19.production"
    
    private let availability: CachedResponse<AppAvailability>
    private let latestAppVersion: CachedResponse<Version>
    private var cancellable: AnyCancellable?
    
    @Published
    public private(set) var metadata: AppAvailabilityMetadata = .initial
    
    init(distributeClient: HTTPClient, iTunesClient: HTTPClient, cacheStorage: FileStoring, appInfo: AppInfo) {
        availability = CachedResponse(
            httpClient: distributeClient,
            endpoint: AppAvailabilityEndpoint(),
            storage: cacheStorage,
            name: "app_availability",
            initialValue: .initial
        )
        latestAppVersion = CachedResponse(
            httpClient: iTunesClient,
            endpoint: AppStoreVersionLookupEndpoint(bundleId: Self.productionAppBundleId),
            storage: cacheStorage,
            name: "latest_app_version",
            initialValue: Version(major: 0)
        )
        
        cancellable = availability.$value.combineLatest(latestAppVersion.$value).sink { [weak self] availability, latestAppVersion in
            self?.metadata = AppAvailabilityMetadata(
                availability: availability,
                iOSVersion: .iOSVersion,
                appVersion: appInfo.version,
                latestAppVersion: latestAppVersion
            )
        }
    }
    
    func update() -> AnyPublisher<Void, Never> {
        latestAppVersion.update()
            .merge(with: availability.update())
            .eraseToAnyPublisher()
    }
    
}

private extension AppAvailability {
    
    static let initial = AppAvailability(
        iOSVersion: VersionRequirement(
            minimumSupported: Version(major: 0),
            descriptions: [:]
        ),
        recommendediOSVersion: RecommendationRequirement(
            minimumRecommended: Version(major: 0),
            titles: [:],
            descriptions: [:]
        ),
        appVersion: VersionRequirement(
            minimumSupported: Version(major: 0),
            descriptions: [:]
        ),
        recommendedAppVersion: RecommendationRequirement(
            minimumRecommended: Version(major: 0),
            titles: [:],
            descriptions: [:]
        )
    )
    
}

extension Version {
    
    init(_ version: OperatingSystemVersion) {
        self.init(major: version.majorVersion, minor: version.minorVersion, patch: version.patchVersion)
    }
    
    public static let iOSVersion: Version = {
        Version(ProcessInfo.processInfo.operatingSystemVersion)
    }()
    
}

private extension AppAvailabilityMetadata {
    
    static let initial = AppAvailabilityMetadata(
        titles: [:],
        descriptions: [:],
        state: .available
    )
    
}
