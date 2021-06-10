//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Scenarios
import XCTest
@testable import Domain

class HomeAnimationsStoreTests: XCTestCase {
    private var encryptedStore: MockEncryptedStore!
    private var homeAnimationsStore: HomeAnimationsStore!
    
    override func setUp() {
        super.setUp()
        
        encryptedStore = MockEncryptedStore()
        homeAnimationsStore = HomeAnimationsStore(store: encryptedStore)
    }
    
    func testLoadEmptyStore() {
        // By default, animations are enabled
        XCTAssertTrue(homeAnimationsStore.homeAnimationsEnabled.currentValue)
    }
    
    func testLoadNonEmptyStore() {
        encryptedStore.stored["userSettingsInfo"] = """
        {
            "animationsEnabled": true
        }
        """.data(using: .utf8)
        
        XCTAssertTrue(homeAnimationsStore.homeAnimationsEnabled.currentValue)
    }
    
    func testSave() throws {
        let homeAnimationsStore = HomeAnimationsStore(store: encryptedStore)
        
        homeAnimationsStore.save(enabled: false)
        XCTAssertFalse(homeAnimationsStore.homeAnimationsEnabled.currentValue)
        
        homeAnimationsStore.save(enabled: true)
        XCTAssertTrue(homeAnimationsStore.homeAnimationsEnabled.currentValue)
    }
    
    func testDelete() throws {
        homeAnimationsStore.save(enabled: false)
        homeAnimationsStore.delete()
        XCTAssertTrue(homeAnimationsStore.homeAnimationsEnabled.currentValue)
    }
}
