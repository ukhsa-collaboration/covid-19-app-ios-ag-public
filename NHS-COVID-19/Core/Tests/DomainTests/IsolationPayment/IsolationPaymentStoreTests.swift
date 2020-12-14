//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Scenarios
import XCTest
@testable import Domain

class IsolationPaymentStoreTests: XCTestCase {
    private var encryptedStore: MockEncryptedStore!
    
    override func setUp() {
        super.setUp()
        
        encryptedStore = MockEncryptedStore()
    }
    
    func testLoad() throws {
        encryptedStore.stored["isolation_payment_store"] = """
        {
            "isEnabled": false
        }
        """.data(using: .utf8)
        let isolationPaymentStore = IsolationPaymentStore(store: encryptedStore)
        let storedIsolationPaymentState = try XCTUnwrap(isolationPaymentStore.load())
        let isolationPaymentState = IsolationPaymentRawState.disabled
        XCTAssertEqual(storedIsolationPaymentState, isolationPaymentState)
    }
    
    func testLoadWithToken() throws {
        let token = UUID().uuidString
        encryptedStore.stored["isolation_payment_store"] = """
        {
            "isEnabled": true,
            "ipcToken": "\(token)"
        }
        """.data(using: .utf8)
        let isolationPaymentStore = IsolationPaymentStore(store: encryptedStore)
        let storedIsolationPaymentState = try XCTUnwrap(isolationPaymentStore.load())
        let isolationPaymentState = IsolationPaymentRawState.ipcToken(token)
        XCTAssertEqual(storedIsolationPaymentState, isolationPaymentState)
    }
    
    func testSave() throws {
        let isolationPaymentStore = IsolationPaymentStore(store: encryptedStore)
        isolationPaymentStore.save(.disabled)
        let storedIsolationPaymentState = try XCTUnwrap(isolationPaymentStore.load())
        let isolationPaymentState = IsolationPaymentRawState.disabled
        XCTAssertEqual(storedIsolationPaymentState, isolationPaymentState)
    }
    
    func testSaveWithToken() throws {
        let isolationPaymentStore = IsolationPaymentStore(store: encryptedStore)
        let token = UUID().uuidString
        isolationPaymentStore.save(.ipcToken(token))
        let storedIsolationPaymentState = try XCTUnwrap(isolationPaymentStore.load())
        let isolationPaymentState = IsolationPaymentRawState.ipcToken(token)
        XCTAssertEqual(storedIsolationPaymentState, isolationPaymentState)
    }
    
    func testDelete() throws {
        encryptedStore.stored["isolation_payment_store"] = """
        {
            "isEnabled": false
        }
        """.data(using: .utf8)
        
        let isolationPaymentStore = IsolationPaymentStore(store: encryptedStore)
        XCTAssertNotNil(isolationPaymentStore.load())
        isolationPaymentStore.delete()
        XCTAssertNil(isolationPaymentStore.load())
    }
}
