//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import Interface
import XCTest

class LinkTestResultsFormatterTests: XCTestCase {
    
    func testItDoesntChangeAValidCode() {
        let inputCode = "5aevpnz2"
        let expectedCode = "5aevpnz2"
        XCTAssertEqual(expectedCode, LinkTestResultCodeFormatter.format(inputCode))
    }
    
    func testItDoesntAllowMoreThanNineCharacters() {
        let inputCode = "5aevpnz2sdsfsfsf"
        let expectedCode = "5aevpnz2"
        XCTAssertEqual(expectedCode, LinkTestResultCodeFormatter.format(inputCode))
    }
    
    func testItFiltersNonCrockfordDammCharacters() {
        let inputCode = "5!al@oe£v$--%p^n&z*u2("
        let expectedCode = "5aevpnz2"
        XCTAssertEqual(expectedCode, LinkTestResultCodeFormatter.format(inputCode))
    }
    
    func testItLowerCasesInput() {
        let inputCode = "5AEV-PNZ2"
        let expectedCode = "5aevpnz2"
        XCTAssertEqual(expectedCode, LinkTestResultCodeFormatter.format(inputCode))
    }
}
