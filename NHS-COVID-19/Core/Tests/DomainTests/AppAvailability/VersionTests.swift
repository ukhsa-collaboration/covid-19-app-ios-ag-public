//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import TestSupport
import XCTest
@testable import Domain

class VersionTests: XCTestCase {
    
    // MARK: - Init
    
    func testInitializingWithAllPartsProvided() {
        XCTAssertNoThrow(try Version("12.0.1"))
    }
    
    func testInitializingWithMajorAnMinorOnly() {
        XCTAssertNoThrow(try Version("12.2.0"))
    }
    
    func testInitializingWithMajorOnly() {
        XCTAssertNoThrow(try Version("99"))
    }
    
    func testInitializingWithEmptyStringThrows() {
        XCTAssertThrowsError(try Version(" "))
    }
    
    func testInitializingWithInvalidMajorThrows() {
        XCTAssertThrowsError(try Version("z.1.1"))
    }
    
    func testInitializingWithNonNumericMinorThrows() {
        XCTAssertThrowsError(try Version("1.z.1"))
    }
    
    func testInitializingWithInvalidPatchThrows() {
        XCTAssertThrowsError(try Version("1.1.z"))
    }
    
    func testInitializingWithEmptyMajorThrows() {
        XCTAssertThrowsError(try Version(".1.1"))
    }
    
    func testInitializingWithEmptyMinorThrows() {
        XCTAssertThrowsError(try Version("1..1"))
    }
    
    func testInitializingWithEmptyPatchThrows() {
        XCTAssertThrowsError(try Version("1.1."))
    }
    
    func testInitializingWithMoreThanThreeComponentsThrows() {
        XCTAssertThrowsError(try Version("1.2.3.4"))
    }
    
    // MARK: - Equate
    
    func testVersionsWithPatchOmittedStillCountEqual() throws {
        try TS.assert(Version("1.0"), equals: Version("1.0.0"))
    }
    
    func testVersionsWithMinorAndPatchOmittedStillCountEqual() throws {
        try TS.assert(Version("1"), equals: Version("1.0.0"))
    }
    
    // MARK: - Compare
    
    func testComparingSameVersion() throws {
        try XCTAssertFalse(Version("17") < Version("17"))
        try XCTAssertFalse(Version("17") > Version("17"))
    }
    
    func testComparingVersionsWithDifferentMajorVersion() throws {
        try XCTAssert(Version("16.9.9") < Version("17"))
    }
    
    func testComparingVersionsWithDifferentMintorVersion() throws {
        try XCTAssert(Version("16.8.9") < Version("16.9"))
    }
    
    func testComparingVersionsWithDifferentPatchVersion() throws {
        try XCTAssert(Version("16.9.8") < Version("16.9.9"))
    }
    
    func testMajorVersionIsPreferredWhenComparing() throws {
        try XCTAssert(Version("5.6.6") < Version("6.5.4"))
    }
    
    func testFullIntegerIsConsideredWhenComparing() throws {
        try XCTAssert(Version("6.5.9") < Version("6.5.10"))
    }
    
    func testVersionWithFewerVersionDigitsCanStillBeBigger() throws {
        try XCTAssert(Version("5.10.0") < Version("6.0.0"))
    }
    
}
