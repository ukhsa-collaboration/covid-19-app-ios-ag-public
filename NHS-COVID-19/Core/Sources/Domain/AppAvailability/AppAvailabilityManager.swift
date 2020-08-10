//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation
import UIKit

class AppAvailabilityManager {
    
    private let availability: CachedResponse<AppAvailability>
    private let latestAppVersion: CachedResponse<Version>
    private var cancellable: AnyCancellable?
    
    @Published
    public private(set) var state: AppAvailabilityLogicalState = .available
    
    init(distributeClient: HTTPClient, iTunesClient: HTTPClient, cacheStorage: FileStorage, appInfo: AppInfo) {
        availability = CachedResponse(
            httpClient: distributeClient,
            endpoint: AppAvailabilityEndpoint(),
            storage: cacheStorage,
            name: "app_availability",
            initialValue: .initial
        )
        latestAppVersion = CachedResponse(
            httpClient: iTunesClient,
            endpoint: AppStoreVersionLookupEndpoint(bundleId: appInfo.bundleId),
            storage: cacheStorage,
            name: "latest_app_version",
            initialValue: Version(major: 0)
        )
        
        cancellable = availability.$value.combineLatest(latestAppVersion.$value).sink { [weak self] availability, latestAppVersion in
            self?.state = AppAvailabilityLogicalState(
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
        iOSVersion: VersionRequirement(minimumSupported: Version(major: 0), descriptions: [:]),
        appVersion: VersionRequirement(minimumSupported: Version(major: 0), descriptions: [:])
    )
    
}

private extension Version {
    
    init(_ version: OperatingSystemVersion) {
        self.init(major: version.majorVersion, minor: version.minorVersion, patch: version.patchVersion)
    }
    
    static let iOSVersion: Version = {
        Version(ProcessInfo.processInfo.operatingSystemVersion)
    }()
    
}
