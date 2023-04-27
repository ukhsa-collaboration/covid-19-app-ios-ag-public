//
// Copyright © 2023 DHSC. All rights reserved.
//

import XCTest
import TestSupport
@testable import Domain

final class DecommissioningTests: AcceptanceTestCase {

    func testStateIsDecommissionedWhenDecommissioningClosureSceenFeatureFlagIsEnabled() throws {

        $instance.enabledFeatures = []

        if case .decommissioned(_) = coordinator.state {
            throw TestError("Unexpected state decommissioned")
        }

        resetInstance()
        $instance.enabledFeatures = [.decommissioningClosureSceen]

        guard case .decommissioned(_) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }
    }

    func testABackgroundTaskIsNotScheduledWhenDecommissioningFeatureIsEnabled() throws {
        $instance.enabledFeatures = []

        if case .decommissioned(_) = coordinator.state {
            throw TestError("Unexpected state decommissioned")
        }

        XCTAssertNotNil($instance.processingTaskRequestManager.request)

        resetInstance()
        $instance.enabledFeatures = [.decommissioningClosureSceen]

        guard case .decommissioned(_) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }

        XCTAssertNil($instance.processingTaskRequestManager.request)
    }

    func testLanguageInformationIsKeptWhenAllOtherDataIsDeleted() throws {
        $instance.enabledFeatures = [.decommissioningClosureSceen]

        let languageStore = LanguageStore(store: $instance.encryptedStore)
        let postcodeStore = PostcodeStore(store: $instance.encryptedStore)

        XCTAssertFalse($instance.encryptedStore.dataEncryptor("language").hasValue)
        XCTAssertFalse($instance.encryptedStore.dataEncryptor("postcode").hasValue)

        languageStore.save(localeConfiguration: .custom(localeIdentifier: "en"))
        XCTAssert($instance.encryptedStore.dataEncryptor("language").hasValue)

        postcodeStore.save(postcode: .init("L1"))
        XCTAssert($instance.encryptedStore.dataEncryptor("postcode").hasValue)

        guard case .decommissioned(_) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }

        XCTAssert($instance.encryptedStore.dataEncryptor("language").hasValue)
        XCTAssertFalse($instance.encryptedStore.dataEncryptor("postcode").hasValue)
    }

    func testAllNotificationRequestsAreRemovedWhenDecommissioningClosureSceenFeatureFlagIsEnabled() throws {
        $instance.enabledFeatures = [.decommissioningClosureSceen]

        XCTAssertNil($instance.userNotificationsManager.removedAll)

        guard case .decommissioned(_) = coordinator.state else {
            throw TestError("Unexpected state \(coordinator.state)")
        }

        XCTAssert($instance.userNotificationsManager.removedAll == true)
    }

    func testDecommissioningNotificationNotScheduledWhenFeatureFlagIsOff() throws {
        UserDefaults.standard.set(nil, forKey: "DecommissioningNotificationAlert")
        $instance.enabledFeatures = []

        if case .decommissioned(_) = coordinator.state {
            throw TestError("Unexpected state decommissioned")
        }

        XCTAssertNil($instance.userNotificationsManager.notificationType)
    }
}

