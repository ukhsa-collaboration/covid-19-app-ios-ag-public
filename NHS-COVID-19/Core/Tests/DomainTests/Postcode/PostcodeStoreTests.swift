//
// Copyright © 2021 DHSC. All rights reserved.
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
        postcodeStore = PostcodeStore(store: encryptedStore)
    }
    
    func testLoadingPostcodeDataWithLowRiskV1() {
        encryptedStore.stored["postcode"] = #"""
        {
            "postcode": "P1",
            "riskLevel": "L"
        }
        """# .data(using: .utf8)!
        
        postcodeStore = PostcodeStore(store: encryptedStore)
        
        XCTAssertTrue(postcodeStore.state.currentValue == .onlyPostcode)
        XCTAssertEqual("P1", postcodeStore.postcode.currentValue?.value)
    }
    
    func testLoadingPostcodeDataWithMediumRiskV1() {
        encryptedStore.stored["postcode"] = #"""
        {
            "postcode": "P1",
            "riskLevel": "M"
        }
        """# .data(using: .utf8)!
        
        postcodeStore = PostcodeStore(store: encryptedStore)
        
        XCTAssertTrue(postcodeStore.state.currentValue == .onlyPostcode)
        XCTAssertEqual("P1", postcodeStore.postcode.currentValue?.value)
    }
    
    func testLoadingPostcodeDataWithHighRiskV1() {
        encryptedStore.stored["postcode"] = #"""
        {
            "postcode": "P1",
            "riskLevel": "H"
        }
        """# .data(using: .utf8)!
        
        postcodeStore = PostcodeStore(store: encryptedStore)
        
        XCTAssertTrue(postcodeStore.state.currentValue == .onlyPostcode)
        XCTAssertEqual("P1", postcodeStore.postcode.currentValue?.value)
    }
    
    func testLoadingPostcodeDataWithoutLocalAuthority() {
        encryptedStore.stored["postcode"] = #"""
        {
            "postcode": "P1"
        }
        """# .data(using: .utf8)!
        
        postcodeStore = PostcodeStore(store: encryptedStore)
        
        XCTAssertTrue(postcodeStore.state.currentValue == .onlyPostcode)
        XCTAssertEqual("P1", postcodeStore.postcode.currentValue?.value)
        XCTAssertNil(postcodeStore.localAuthorityId.currentValue)
    }
    
    func testLoadingPostcodeDataWithLocalAuthority() {
        encryptedStore.stored["postcode"] = #"""
        {
            "postcode": "p1",
            "localAuthorityId": "la1"
        }
        """# .data(using: .utf8)!
        
        postcodeStore = PostcodeStore(store: encryptedStore)
        
        XCTAssertTrue(postcodeStore.state.currentValue == .postcodeAndLocalAuthority)
        XCTAssertEqual("P1", postcodeStore.postcode.currentValue?.value)
        XCTAssertEqual("LA1", postcodeStore.localAuthorityId.currentValue?.value)
    }
    
    func testSavePostcodeSucess() throws {
        postcodeStore.save(postcode: Postcode("B44"))
        XCTAssertEqual(postcodeStore.postcode.currentValue?.value, "B44")
    }
    
    func testSavePostcodeWithLocalAuthoritySuccess() throws {
        let postcode = Postcode("B44")
        let localAuthority = LocalAuthorityId("LA44")
        postcodeStore.save(postcode: postcode, localAuthorityId: localAuthority)
        XCTAssertEqual(postcodeStore.postcode.currentValue, postcode)
        XCTAssertEqual(postcodeStore.localAuthorityId.currentValue, localAuthority)
    }
    
    func testDeletePostcode() throws {
        postcodeStore.save(postcode: Postcode("B44"))
        postcodeStore.delete()
        XCTAssertNil(postcodeStore.postcode.currentValue)
    }
}
