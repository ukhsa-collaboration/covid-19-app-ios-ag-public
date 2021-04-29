//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest
@testable import Domain

class PolicyVersionManagerTests: XCTestCase {
    
    func testAcceptingNeededWithNoSavedVersion() throws {
        let manager = PolicyVersionManager(encryptedStore: MockEncryptedStore(), currentVersion: try! .init("3.10"), neededVersion: "3.10")
        XCTAssert(manager.needsAcceptNewVersion)
    }
    
    func testAcceptingNotNeededAfterAcceptingCurrentVersion() throws {
        let manager = PolicyVersionManager(encryptedStore: MockEncryptedStore(), currentVersion: try! .init("3.10"), neededVersion: "3.10")
        manager.acceptWithCurrentAppVersion()
        
        XCTAssertFalse(manager.needsAcceptNewVersion)
    }
    
    func testAcceptingNeededAfterIfNeededVersionIsIncreased() throws {
        let store = MockEncryptedStore()
        var manager = PolicyVersionManager(encryptedStore: store, currentVersion: try! .init("3.10"), neededVersion: "3.10")
        manager.acceptWithCurrentAppVersion()
        
        manager = PolicyVersionManager(encryptedStore: store, currentVersion: try! .init("3.11"), neededVersion: "3.11")
        
        XCTAssert(manager.needsAcceptNewVersion)
    }
    
    func testAcceptingNeededAfterIfNeededVersionIsIncreasedAcceptingSemanticVersioning() throws {
        let store = MockEncryptedStore()
        var manager = PolicyVersionManager(encryptedStore: store, currentVersion: try! .init("3.10"), neededVersion: "3.10")
        manager.acceptWithCurrentAppVersion()
        
        manager = PolicyVersionManager(encryptedStore: store, currentVersion: try! .init("4.1"), neededVersion: "4.1")
        
        XCTAssert(manager.needsAcceptNewVersion)
    }
    
    func testAcceptingNotNeededAfterUpgradeIfNeededVersionIsUnchanged() throws {
        let store = MockEncryptedStore()
        var manager = PolicyVersionManager(encryptedStore: store, currentVersion: try! .init("3.10"), neededVersion: "3.10")
        manager.acceptWithCurrentAppVersion()
        
        manager = PolicyVersionManager(encryptedStore: store, currentVersion: try! .init("4.1"), neededVersion: "3.10")
        
        XCTAssertFalse(manager.needsAcceptNewVersion)
    }
    
}
