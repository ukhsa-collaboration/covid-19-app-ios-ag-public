//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest
@testable import Domain

class PolicyVersionManagerTests: XCTestCase {
    
    func testAcceptingNeededWithNoSavedVersion() throws {
        let manager = PolicyVersionManager(encryptedStore: MockEncryptedStore(), currentVersion: try! .init("3.10"), neededVersion: "3.10")
        XCTAssertTrue(manager.needsAcceptNewVersion)
    }
    
    func testAcceptingNotNeededWithCurrentVersion() throws {
        let manager = PolicyVersionManager(encryptedStore: MockEncryptedStore(), currentVersion: try! .init("3.9"), neededVersion: "3.10")
        manager.acceptWithCurrentAppVersion()
        
        XCTAssertTrue(manager.needsAcceptNewVersion)
    }
    
    func testAcceptingNeededWithOlderSavedVersion() throws {
        let manager = PolicyVersionManager(encryptedStore: MockEncryptedStore(), currentVersion: try! .init("3.10"), neededVersion: "3.10")
        manager.acceptWithCurrentAppVersion()
        
        XCTAssertFalse(manager.needsAcceptNewVersion)
    }
}
