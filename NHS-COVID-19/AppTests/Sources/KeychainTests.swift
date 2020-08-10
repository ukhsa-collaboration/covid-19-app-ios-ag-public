//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Foundation
import XCTest

class KeychainTests: XCTestCase {
    private let service = UUID().uuidString
    private let key = UUID().uuidString
    
    override func setUp() {
        super.setUp()
        clean()
        addTeardownBlock(clean)
    }
    
    private func clean() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    func testAdd() throws {
        let keychain = Keychain(service: service)
        let value = UUID().uuidString.data(using: .utf8)!
        
        try keychain.add([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: value,
        ])
        
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
    
    func testAddFailing() throws {
        let keychain = Keychain(service: service)
        XCTAssertThrowsError(try keychain.add([:]))
    }
    
    func testGet() throws {
        let keychain = Keychain(service: service)
        let value = UUID().uuidString.data(using: .utf8)!
        
        try keychain.add([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: value,
        ])
        
        let result = try keychain.get([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
        ], as: Data.self)
        
        XCTAssertEqual(value, result)
    }
    
    func testGetFailingDueToBadReturnType() throws {
        let keychain = Keychain(service: service)
        let value = UUID().uuidString.data(using: .utf8)!
        
        try keychain.add([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: value,
        ])
        
        XCTAssertThrowsError(
            try keychain.get([
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecReturnData as String: true,
            ], as: String.self)
        )
    }
    
    func testGetFailing() throws {
        let keychain = Keychain(service: service)
        XCTAssertThrowsError(try keychain.get([:], as: Data.self))
    }
    
    func testUpdate() throws {
        let keychain = Keychain(service: service)
        let oldValue = UUID().uuidString.data(using: .utf8)!
        let newValue = UUID().uuidString.data(using: .utf8)!
        
        try keychain.add([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: oldValue,
        ])
        
        try keychain.update(
            [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
            ],
            with: [
                kSecValueData as String: newValue,
            ]
        )
        
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
        XCTAssertEqual(newValue, item)
    }
    
    func testUpdateFailing() throws {
        let keychain = Keychain(service: service)
        XCTAssertThrowsError(try keychain.update([:], with: [:]))
    }
    
    func testDelete() throws {
        let keychain = Keychain(service: service)
        let oldValue = UUID().uuidString.data(using: .utf8)!
        
        try keychain.add([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: oldValue,
        ])
        
        try keychain.delete([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
        ])
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
        ]
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        XCTAssertEqual(status, errSecItemNotFound)
        
        XCTAssertNil(result)
        
    }
    
    func testDeleteFailing() throws {
        let keychain = Keychain(service: service)
        XCTAssertThrowsError(try keychain.delete([:]))
    }
    
}
