//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Scenarios
import XCTest
@testable import Domain

class PostcodeStoreTests: XCTestCase {
    
    private var encryptedStore: MockEncryptedStore!
    private var postcodeStore: PostcodeStore!
    
    override func setUp() {
        super.setUp()
        
        encryptedStore = MockEncryptedStore()
        postcodeStore = PostcodeStore(store: encryptedStore) { _ in true }
    }
    
    func testLoadingPostcodeDataWithLowRisk() {
        encryptedStore.stored["postcode"] = #"""
        {
            "postcode": "P1",
            "riskLevel": "L"
        }
        """# .data(using: .utf8)!
        
        postcodeStore = PostcodeStore(store: encryptedStore) { _ in true }
        
        XCTAssertTrue(postcodeStore.hasPostcode)
        XCTAssertEqual("P1", postcodeStore.load())
        XCTAssertEqual(PostcodeRisk.low, postcodeStore.riskLevel)
    }
    
    func testLoadingPostcodeDataWithMediumRisk() {
        encryptedStore.stored["postcode"] = #"""
        {
            "postcode": "P1",
            "riskLevel": "M"
        }
        """# .data(using: .utf8)!
        
        postcodeStore = PostcodeStore(store: encryptedStore) { _ in true }
        
        XCTAssertTrue(postcodeStore.hasPostcode)
        XCTAssertEqual("P1", postcodeStore.load())
        XCTAssertEqual(PostcodeRisk.medium, postcodeStore.riskLevel)
    }
    
    func testLoadingPostcodeDataWithHighRisk() {
        encryptedStore.stored["postcode"] = #"""
        {
            "postcode": "P1",
            "riskLevel": "H"
        }
        """# .data(using: .utf8)!
        
        postcodeStore = PostcodeStore(store: encryptedStore) { _ in true }
        
        XCTAssertTrue(postcodeStore.hasPostcode)
        XCTAssertEqual("P1", postcodeStore.load())
        XCTAssertEqual(PostcodeRisk.high, postcodeStore.riskLevel)
    }
    
    func testSavePostcodeSucess() throws {
        try postcodeStore.save(postcode: "B44")
        XCTAssertEqual(postcodeStore.load(), "B44")
    }
    
    func testDeletePostcode() throws {
        
        try postcodeStore.save(postcode: "B44")
        postcodeStore.delete()
        XCTAssertNil(postcodeStore.load())
    }
    
    func testNoRiskProvidedByDefault() {
        XCTAssertNil(postcodeStore.riskLevel)
    }
}
