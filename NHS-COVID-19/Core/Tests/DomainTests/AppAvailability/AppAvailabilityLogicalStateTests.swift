//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import TestSupport
import XCTest
@testable import Domain

extension AppAvailabilityMetadata: TestProp {
    public struct Configuration: TestPropConfiguration {
        var availability = AppAvailability.mock(
            minOSVersion: "13",
            recommendedOSVersion: "13",
            minAppVersion: "3",
            recommendedAppVersion: "3"
        )
        var iOSVersion = Version(major: 0)
        var appVersion = Version(major: 0)
        var latestAppVersion: Version?
        
        public init() {}
    }
    
    public init(configuration: Configuration) {
        self.init(
            availability: configuration.availability,
            iOSVersion: configuration.iOSVersion,
            appVersion: configuration.appVersion,
            latestAppVersion: configuration.latestAppVersion
        )
    }
}

class AppAvailabilityLogicalStateTests: XCTestCase {
    
    @Propped
    private var metadata: AppAvailabilityMetadata
    
    func testAppIsAvailableWhenVersionsAreAboveMinimum() {
        $metadata.iOSVersion = Version(major: 14)
        $metadata.appVersion = Version(major: 4)
        
        TS.assert(metadata.state, equals: .available)
    }
    
    func testAppIsAvailableWhenVersionsAreEqualToMinimum() {
        $metadata.iOSVersion = Version(major: 13)
        $metadata.appVersion = Version(major: 3)
        
        TS.assert(metadata.state, equals: .available)
    }
    
    func testAppIsUnavailableDueToOldOS() {
        $metadata.iOSVersion = Version(major: 12)
        $metadata.appVersion = Version(major: 3)
        
        TS.assert(metadata.state, equals: .unavailable(reason: .iOSTooOld))
    }
    
    func testAppIsUnavailableDueToOldOSEvenIfTheAppIsAlsoTooOld() {
        $metadata.iOSVersion = Version(major: 12)
        $metadata.appVersion = Version(major: 2)
        
        TS.assert(metadata.state, equals: .unavailable(reason: .iOSTooOld))
    }
    
    func testAppIsUnavailableDueToOldAppWithLatestVersionUnknown() {
        $metadata.iOSVersion = Version(major: 13)
        $metadata.appVersion = Version(major: 2)
        
        TS.assert(metadata.state, equals: .unavailable(reason: .appTooOld(updateAvailable: false)))
    }
    
    func testAppIsUnavailableDueToOldAppWithLatestVersionBelowMinimum() {
        $metadata.iOSVersion = Version(major: 13)
        $metadata.appVersion = Version(major: 2)
        $metadata.latestAppVersion = Version(major: 2, minor: 1)
        
        TS.assert(metadata.state, equals: .unavailable(reason: .appTooOld(updateAvailable: false)))
    }
    
    func testAppIsUnavailableDueToOldAppWithLatestVersionEqualToMinimum() {
        $metadata.iOSVersion = Version(major: 13)
        $metadata.appVersion = Version(major: 2)
        $metadata.latestAppVersion = Version(major: 3)
        
        TS.assert(metadata.state, equals: .unavailable(reason: .appTooOld(updateAvailable: true)))
    }
    
    func testAppIsUnavailableDueToOldAppWithLatestVersionAboveMinimum() {
        $metadata.iOSVersion = Version(major: 13)
        $metadata.appVersion = Version(major: 2)
        $metadata.latestAppVersion = Version(major: 3, minor: 1)
        
        TS.assert(metadata.state, equals: .unavailable(reason: .appTooOld(updateAvailable: true)))
    }
    
    func testOSIsRecommendingWhenVersionsAreEqualToMinimum() {
        $metadata.availability = AppAvailability.mock(
            minOSVersion: "13",
            recommendedOSVersion: "13.1",
            minAppVersion: "3",
            recommendedAppVersion: "3.1"
        )
        $metadata.iOSVersion = Version(major: 13)
        $metadata.appVersion = Version(major: 3)
        
        TS.assert(metadata.state, equals: .recommending(reason: .iOSOlderThanRecommended(version: Version(major: 13, minor: 1))))
    }
    
    func testAppIsRecommendingWheniOSVersionIsRecommendedAndAppVersionsIsEqualToMinimum() {
        $metadata.availability = AppAvailability.mock(
            minOSVersion: "13",
            recommendedOSVersion: "13.1",
            minAppVersion: "3",
            recommendedAppVersion: "3.1"
        )
        $metadata.iOSVersion = Version(major: 13, minor: 1)
        $metadata.appVersion = Version(major: 3)
        $metadata.latestAppVersion = Version(major: 3, minor: 1)
        
        TS.assert(metadata.state, equals: .recommending(reason: .appOlderThanRecommended(version: Version(major: 3, minor: 1))))
    }
    
    func testAppIsRecommendingLatestAppVersionIsGreaterThanRecommendedAppVersion() {
        $metadata.availability = AppAvailability.mock(
            minOSVersion: "13",
            recommendedOSVersion: "13.1",
            minAppVersion: "3",
            recommendedAppVersion: "3.1"
        )
        $metadata.iOSVersion = Version(major: 13, minor: 1)
        $metadata.appVersion = Version(major: 3)
        $metadata.latestAppVersion = Version(major: 3, minor: 2)
        
        TS.assert(metadata.state, equals: .recommending(reason: .appOlderThanRecommended(version: Version(major: 3, minor: 1))))
    }
    
    func testAppIsAvailableWhenLatestVersionIsLessThanRecommendedVersion() {
        $metadata.availability = AppAvailability.mock(
            minOSVersion: "13",
            recommendedOSVersion: "13.1",
            minAppVersion: "3",
            recommendedAppVersion: "3.1"
        )
        $metadata.iOSVersion = Version(major: 13, minor: 1)
        $metadata.appVersion = Version(major: 3)
        $metadata.latestAppVersion = Version(major: 3)
        
        TS.assert(metadata.state, equals: .available)
    }
}

private extension AppAvailability {
    
    static func mock(
        minOSVersion: String,
        recommendedOSVersion: String,
        minAppVersion: String,
        recommendedAppVersion: String
    ) -> AppAvailability {
        AppAvailability(
            iOSVersion: try! VersionRequirement(minimumSupported: Version(minOSVersion), descriptions: [:]),
            recommendediOSVersion: try! RecommendationRequirement(minimumRecommended: Version(recommendedOSVersion), titles: [:], descriptions: [:]),
            appVersion: try! VersionRequirement(minimumSupported: Version(minAppVersion), descriptions: [:]),
            recommendedAppVersion: try! RecommendationRequirement(minimumRecommended: Version(recommendedAppVersion), titles: [:], descriptions: [:])
        )
    }
    
}
