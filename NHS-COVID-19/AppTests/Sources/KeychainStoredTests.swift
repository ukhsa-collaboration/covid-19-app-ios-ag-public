//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import XCTest
@testable import Domain

class KeychainStoredTests: XCTestCase {
    private var storage: KeychainStored<Data>!
    
    override func tearDown() {
        super.tearDown()
        storage.wrappedValue = nil
    }
    
    func testCanSetValue() throws {
        let service = UUID().uuidString
        let key = UUID().uuidString
        
        storage = KeychainStored<Data>(keychain: Keychain(service: service), key: key)
        let value = "test".data(using: .utf8)!
        storage.wrappedValue = value
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
        ]
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        XCTAssertEqual(status, errSecSuccess)
        
        let item = try XCTUnwrap(result as? Data)
        XCTAssertEqual(value, item)
    }
    
    func testSettingAValueMakesItAccessibleAfterFirstUnlockThisDeviceOnly() throws {
        let service = UUID().uuidString
        let key = UUID().uuidString
        
        storage = KeychainStored<Data>(keychain: Keychain(service: service), key: key)
        let value = "test".data(using: .utf8)!
        storage.wrappedValue = value
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnAttributes as String: true,
        ]
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        XCTAssertEqual(status, errSecSuccess)
        
        let item = try XCTUnwrap(result as? NSDictionary)
        let accessibility = try XCTUnwrap(item[kSecAttrAccessible as String] as? String)
        XCTAssertEqual(accessibility, kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String)
    }
    
    func testCanGetValue() throws {
        let service = UUID().uuidString
        let key = UUID().uuidString
        
        storage = KeychainStored<Data>(keychain: Keychain(service: service), key: key)
        let value = "test".data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: value,
        ]
        
        SecItemAdd(query as CFDictionary, nil)
        
        let retrievedValue = storage.wrappedValue
        XCTAssertEqual(retrievedValue, value)
    }
    
    func testCanCorrectlyUpdateValue() throws {
        let service = UUID().uuidString
        let key = UUID().uuidString
        
        storage = KeychainStored<Data>(keychain: Keychain(service: service), key: key)
        let value1 = "test1".data(using: .utf8)!
        let value2 = "test2".data(using: .utf8)!
        
        storage.wrappedValue = value1
        storage.wrappedValue = value2
        
        XCTAssertEqual(value2, storage.wrappedValue)
    }
    
    func testUpdatingAValueAdjustsAccessiblityToAfterFirstUnlockThisDeviceOnly() throws {
        let service = UUID().uuidString
        let key = UUID().uuidString
        
        let keychain = Keychain(service: service)
        storage = KeychainStored<Data>(keychain: keychain, key: key)
        let value1 = "test1".data(using: .utf8)!
        let value2 = "test2".data(using: .utf8)!
        
        try keychain.add([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: value1,
        ])
        
        storage.wrappedValue = value2
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnAttributes as String: true,
        ]
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        XCTAssertEqual(status, errSecSuccess)
        
        let item = try XCTUnwrap(result as? NSDictionary)
        let accessibility = try XCTUnwrap(item[kSecAttrAccessible as String] as? String)
        XCTAssertEqual(accessibility, kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String)
    }
    
    func testGetWithoutSetReturnsNil() {
        let service = UUID().uuidString
        let key = UUID().uuidString
        
        storage = KeychainStored<Data>(keychain: Keychain(service: service), key: key)
        let result = storage.wrappedValue
        XCTAssertNil(result)
    }
    
    func testCanDeleteSetValue() {
        let service = UUID().uuidString
        let key = UUID().uuidString
        
        storage = KeychainStored<Data>(keychain: Keychain(service: service), key: key)
        let value = "test".data(using: .utf8)!
        storage.wrappedValue = value
        storage.wrappedValue = nil
        XCTAssertFalse(storage.hasValue)
    }
    
    func testHasValueReturnsTrueWhenValueSet() {
        let service = UUID().uuidString
        let key = UUID().uuidString
        
        storage = KeychainStored<Data>(keychain: Keychain(service: service), key: key)
        let value = "test".data(using: .utf8)!
        storage.wrappedValue = value
        XCTAssertTrue(storage.hasValue)
    }
}
