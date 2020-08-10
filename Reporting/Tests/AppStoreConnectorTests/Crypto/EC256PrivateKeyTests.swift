//
// Copyright © 2020 NHSX. All rights reserved.
//

import AppStoreConnector
import XCTest

class EC256PrivateKeyTests: XCTestCase {
    
    func testThatInitializerThrowsForInvalidPrivateKey() {
        XCTAssertThrowsError(try EC256PrivateKey(pemFormatted: UUID().uuidString))
    }
    
    func testThatInitializerDoesNotThrowForValidPrivateKeyWithoutPEMDecoration() {
        XCTAssertNoThrow(try EC256PrivateKey(pemFormatted: SampleKey.pemString))
    }
    
    func testThatInitializerDoesNotThrowForValidPrivateKeyWithPEMDecoration() {
        XCTAssertNoThrow(try EC256PrivateKey(pemFormatted: SampleKey.pemStringWithDecodaration))
    }
    
}
