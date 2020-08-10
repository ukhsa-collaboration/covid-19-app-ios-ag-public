//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import Interface
import XCTest

class PilotActivationCodeFormatterTests: XCTestCase {
    
    func testItDoesntChangeAValidCode() {
        let inputCode = "5aev-pnz2"
        let expectedCode = "5aev-pnz2"
        XCTAssertEqual(expectedCode, PilotActivationCodeFormatter.format(inputCode))
    }
    
    func testItDoesntAllowMoreThanNineCharacters() {
        let inputCode = "5aev-pnz2sdsfsfsf"
        let expectedCode = "5aev-pnz2"
        XCTAssertEqual(expectedCode, PilotActivationCodeFormatter.format(inputCode))
    }
    
    func testItInsertsADashWithMoreThanFiveCharacters() {
        let inputCode = "5aevpnz2"
        let expectedCode = "5aev-pnz2"
        XCTAssertEqual(expectedCode, PilotActivationCodeFormatter.format(inputCode))
    }
    
    func testItLowerCasesInput() {
        let inputCode = "5AEV-PNZ2"
        let expectedCode = "5aev-pnz2"
        XCTAssertEqual(expectedCode, PilotActivationCodeFormatter.format(inputCode))
    }
    
    func testItFiltersNonAlphaNumerics() {
        let inputCode = "5!a@e£v$--%p^n&z*2("
        let expectedCode = "5aev-pnz2"
        XCTAssertEqual(expectedCode, PilotActivationCodeFormatter.format(inputCode))
    }
}
