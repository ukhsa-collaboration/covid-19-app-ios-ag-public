//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import TestSupport
import XCTest
@testable import Domain

extension AppAvailabilityLogicalState: TestProp {
    public struct Configuration: TestPropConfiguration {
        var availability = AppAvailability.mock(minOSVersion: "13", minAppVersion: "3")
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
    private var state: AppAvailabilityLogicalState
    
    func testAppIsAvailableWhenVersionsAreAboveMinimum() {
        $state.iOSVersion = Version(major: 14)
        $state.appVersion = Version(major: 4)
        
        TS.assert(state, equals: .available)
    }
    
    func testAppIsAvailableWhenVersionsAreEqualToMinimum() {
        $state.iOSVersion = Version(major: 13)
        $state.appVersion = Version(major: 3)
        
        TS.assert(state, equals: .available)
    }
    
    func testAppIsUnavailableDueToOldOS() {
        $state.iOSVersion = Version(major: 12)
        $state.appVersion = Version(major: 3)
        
        TS.assert(state, equals: .unavailable(reason: .iOSTooOld(descriptions: [:])))
    }
    
    func testAppIsUnavailableDueToOldOSEvenIfTheAppIsAlsoTooOld() {
        $state.iOSVersion = Version(major: 12)
        $state.appVersion = Version(major: 2)
        
        TS.assert(state, equals: .unavailable(reason: .iOSTooOld(descriptions: [:])))
    }
    
    func testAppIsUnavailableDueToOldAppWithLatestVersionUnknown() {
        $state.iOSVersion = Version(major: 13)
        $state.appVersion = Version(major: 2)
        
        TS.assert(state, equals: .unavailable(reason: .appTooOld(updateAvailable: false, descriptions: [:])))
    }
    
    func testAppIsUnavailableDueToOldAppWithLatestVersionBelowMinimum() {
        $state.iOSVersion = Version(major: 13)
        $state.appVersion = Version(major: 2)
        $state.latestAppVersion = Version(major: 2, minor: 1)
        
        TS.assert(state, equals: .unavailable(reason: .appTooOld(updateAvailable: false, descriptions: [:])))
    }
    
    func testAppIsUnavailableDueToOldAppWithLatestVersionEqualToMinimum() {
        $state.iOSVersion = Version(major: 13)
        $state.appVersion = Version(major: 2)
        $state.latestAppVersion = Version(major: 3)
        
        TS.assert(state, equals: .unavailable(reason: .appTooOld(updateAvailable: true, descriptions: [:])))
    }
    
    func testAppIsUnavailableDueToOldAppWithLatestVersionAboveMinimum() {
        $state.iOSVersion = Version(major: 13)
        $state.appVersion = Version(major: 2)
        $state.latestAppVersion = Version(major: 3, minor: 1)
        
        TS.assert(state, equals: .unavailable(reason: .appTooOld(updateAvailable: true, descriptions: [:])))
    }
    
}

private extension AppAvailability {
    
    static func mock(minOSVersion: String, minAppVersion: String) -> AppAvailability {
        AppAvailability(
            iOSVersion: try! VersionRequirement(minimumSupported: Version(minOSVersion), descriptions: [:]),
            appVersion: try! VersionRequirement(minimumSupported: Version(minAppVersion), descriptions: [:])
        )
    }
    
}
