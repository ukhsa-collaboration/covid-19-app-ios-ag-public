//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Scenarios
import XCTest
@testable import Domain

@available(iOS 13.7, *)
class ExposureWindowStoreTests: XCTestCase {
    private var encryptedStore: MockEncryptedStore!
    private var exposureWindowStore: ExposureWindowStore!
    
    override func setUp() {
        super.setUp()
        
        encryptedStore = MockEncryptedStore()
        exposureWindowStore = ExposureWindowStore(store: encryptedStore, nonRiskyWindowsLimit: 2)
    }
    
    func testLoad() throws {
        encryptedStore.stored["exposure_window_store"] = """
        {
            "exposureWindowsInfo": [{
                "infectiousness": "high",
                "date": {
                    "day" : 11,
                    "month" : 7,
                    "year" : 2020
                },
                "riskScore": 131.44555790888523,
                "riskCalculationVersion": 2,
                "scanInstances": [{
                    "minimumAttenuation": 97,
                    "secondsSinceLastScan": 201,
                    "typicalAttenuation": 0
                }]
            }]
        }
        """.data(using: .utf8)
        
        let exposureWindowInfo = try XCTUnwrap(exposureWindowStore.load())
        let exposureWindowsInfoCollection = ExposureWindowInfoCollection(
            exposureWindowsInfo: [
                self.exposureWindowInfo(date: GregorianDay(year: 2020, month: 7, day: 11), isConsideredRisky: true),
            ]
        )
        XCTAssertEqual(exposureWindowInfo, exposureWindowsInfoCollection)
    }
    
    func testLoadWithIsConsideredRiskyField() throws {
        encryptedStore.stored["exposure_window_store"] = """
        {
            "exposureWindowsInfo": [{
                "infectiousness": "high",
                "date": {
                    "day" : 11,
                    "month" : 7,
                    "year" : 2020
                },
                "riskScore": 131.44555790888523,
                "riskCalculationVersion": 2,
                "isConsideredRisky": false,
                "scanInstances": [{
                    "minimumAttenuation": 97,
                    "secondsSinceLastScan": 201,
                    "typicalAttenuation": 0
                }]
            }]
        }
        """.data(using: .utf8)
        
        let exposureWindowInfo = try XCTUnwrap(exposureWindowStore.load())
        let exposureWindowsInfoCollection = ExposureWindowInfoCollection(
            exposureWindowsInfo: [
                self.exposureWindowInfo(date: GregorianDay(year: 2020, month: 7, day: 11), isConsideredRisky: false),
            ]
        )
        XCTAssertEqual(exposureWindowInfo, exposureWindowsInfoCollection)
    }
    
    func testAppendFirstTimeToNilCollection() throws {
        XCTAssertNil(exposureWindowStore.load())
        exposureWindowStore.append([
            exposureWindowInfo(date: GregorianDay(year: 2020, month: 7, day: 11), isConsideredRisky: true),
        ])
        let exposureWindowInfo = try XCTUnwrap(exposureWindowStore.load())
        let exposureWindowsInfoCollection = ExposureWindowInfoCollection(
            exposureWindowsInfo: [
                self.exposureWindowInfo(date: GregorianDay(year: 2020, month: 7, day: 11), isConsideredRisky: true),
            ]
        )
        XCTAssertEqual(exposureWindowInfo, exposureWindowsInfoCollection)
    }
    
    func testAppend() throws {
        encryptedStore.stored["exposure_window_store"] = """
        {
            "exposureWindowsInfo": [{
                "infectiousness": "high",
                "date": {
                    "day" : 11,
                    "month" : 7,
                    "year" : 2020
                },
                "riskScore": 131.44555790888523,
                "riskCalculationVersion": 2,
                "scanInstances": [{
                    "minimumAttenuation": 97,
                    "secondsSinceLastScan": 201,
                    "typicalAttenuation": 0
                }]
            }]
        }
        """.data(using: .utf8)
        exposureWindowStore.append([
            exposureWindowInfo(date: GregorianDay(year: 2020, month: 7, day: 11), isConsideredRisky: true),
        ])
        let exposureWindowInfo = try XCTUnwrap(exposureWindowStore.load())
        let exposureWindowsInfoCollection = ExposureWindowInfoCollection(
            exposureWindowsInfo: [
                self.exposureWindowInfo(date: GregorianDay(year: 2020, month: 7, day: 11), isConsideredRisky: true),
                self.exposureWindowInfo(date: GregorianDay(year: 2020, month: 7, day: 11), isConsideredRisky: true),
            ]
        )
        XCTAssertEqual(exposureWindowInfo, exposureWindowsInfoCollection)
    }
    
    func testDelete() throws {
        encryptedStore.stored["exposure_window_store"] = """
        {
            "exposureWindowsInfo": [{
                "infectiousness": "high",
                "date": {
                    "day" : 11,
                    "month" : 7,
                    "year" : 2020
                },
                "riskScore": 131.44555790888523,
                "riskCalculationVersion": 2,
                "scanInstances": [{
                    "minimumAttenuation": 97,
                    "secondsSinceLastScan": 201,
                    "typicalAttenuation": 0
                }]
            }]
        }
        """.data(using: .utf8)
        XCTAssertNotNil(exposureWindowStore.load())
        exposureWindowStore.delete()
        XCTAssertNil(exposureWindowStore.load())
    }
    
    // MARK: Non-risky windows
    
    func testAppendNonRiskyWindowsFirstTimeToNilCollection() throws {
        XCTAssertNil(exposureWindowStore.load())
        exposureWindowStore.append([
            exposureWindowInfo(date: GregorianDay(year: 2020, month: 7, day: 11), isConsideredRisky: false),
        ])
        let exposureWindowInfo = try XCTUnwrap(exposureWindowStore.load())
        let exposureWindowsInfoCollection = ExposureWindowInfoCollection(
            exposureWindowsInfo: [
                self.exposureWindowInfo(date: GregorianDay(year: 2020, month: 7, day: 11), isConsideredRisky: false),
            ]
        )
        XCTAssertEqual(exposureWindowInfo, exposureWindowsInfoCollection)
    }
    
    func testAppendNonRiskyWindowsAreGreaterThenOrEqualToLimitReplacesOldWindows() throws {
        
        encryptedStore.stored["exposure_window_store"] = """
        {
            "exposureWindowsInfo": [{
                "infectiousness": "high",
                "date": {
                    "day" : 8,
                    "month" : 7,
                    "year" : 2020
                },
                "riskScore": 131.44555790888523,
                "riskCalculationVersion": 2,
                "isConsideredRisky": false,
                "scanInstances": [{
                    "minimumAttenuation": 97,
                    "secondsSinceLastScan": 201,
                    "typicalAttenuation": 0
                }]
            },
            {
                "infectiousness": "high",
                "date": {
                    "day" : 9,
                    "month" : 7,
                    "year" : 2020
                },
                "riskScore": 131.44555790888523,
                "riskCalculationVersion": 2,
                "isConsideredRisky": false,
                "scanInstances": [{
                    "minimumAttenuation": 97,
                    "secondsSinceLastScan": 201,
                    "typicalAttenuation": 0
                }]
            }]
        }
        """.data(using: .utf8)
        
        let newNonRiskyWindows = [
            self.exposureWindowInfo(date: GregorianDay(year: 2020, month: 7, day: 10), isConsideredRisky: false),
            self.exposureWindowInfo(date: GregorianDay(year: 2020, month: 7, day: 10), isConsideredRisky: false),
        ]
        exposureWindowStore.append(newNonRiskyWindows)
        
        let exposureWindowInfo = try XCTUnwrap(exposureWindowStore.load())
        let exposureWindowsInfoCollection = ExposureWindowInfoCollection(
            exposureWindowsInfo: newNonRiskyWindows
        )
        XCTAssertEqual(exposureWindowInfo, exposureWindowsInfoCollection)
    }
    
    func testAppendNonRiskyWindowShouldAppendExistingWindowsIfUpperLimitIsNotReached() throws {
        
        encryptedStore.stored["exposure_window_store"] = """
        {
            "exposureWindowsInfo": [{
                "infectiousness": "high",
                "date": {
                    "day" : 8,
                    "month" : 7,
                    "year" : 2020
                },
                "riskScore": 131.44555790888523,
                "riskCalculationVersion": 2,
                "isConsideredRisky": false,
                "scanInstances": [{
                    "minimumAttenuation": 97,
                    "secondsSinceLastScan": 201,
                    "typicalAttenuation": 0
                }]
            }]
        }
        """.data(using: .utf8)
        
        exposureWindowStore.append([
            self.exposureWindowInfo(date: GregorianDay(year: 2020, month: 7, day: 7), isConsideredRisky: false),
        ])
        
        let expectedStoredNonRiskyWindows = [
            self.exposureWindowInfo(date: GregorianDay(year: 2020, month: 7, day: 8), isConsideredRisky: false),
            self.exposureWindowInfo(date: GregorianDay(year: 2020, month: 7, day: 7), isConsideredRisky: false),
        ]
        
        let exposureWindowInfo = try XCTUnwrap(exposureWindowStore.load())
        let exposureWindowsInfoCollection = ExposureWindowInfoCollection(
            exposureWindowsInfo: expectedStoredNonRiskyWindows
        )
        
        XCTAssertEqual(exposureWindowInfo, exposureWindowsInfoCollection)
    }
    
    private func exposureWindowInfo(date: GregorianDay) -> ExposureWindowInfo {
        ExposureWindowInfo(
            date: date,
            infectiousness: .high,
            scanInstances: [
                ExposureWindowInfo.ScanInstance(
                    minimumAttenuation: 97,
                    typicalAttenuation: 0,
                    secondsSinceLastScan: 201
                ),
            ],
            riskScore: 131.44555790888523,
            riskCalculationVersion: 2,
            isConsideredRisky: true
        )
    }
    
    func testDeleteExpiredWindowsPriorToASpecificDate() throws {
        
        // User A meets with user B on 1st of March
        // Keys are matched on the 5th of March and EWs are stored that day
        // EWs should no longer be on the device on the 15th of March
        
        let fifteenthOfMarch = GregorianDay(year: 2021, month: 3, day: 15)
        let secondOfMarch = GregorianDay(year: 2021, month: 3, day: 2)
        let firstOfMarch = GregorianDay(year: 2021, month: 3, day: 1)
        
        // add windows with a range of dates
        let exposureWindowsInfoCollection = ExposureWindowInfoCollection(
            exposureWindowsInfo: [
                exposureWindowInfo(date: fifteenthOfMarch),
                exposureWindowInfo(date: fifteenthOfMarch),
                exposureWindowInfo(date: secondOfMarch),
                exposureWindowInfo(date: secondOfMarch),
                exposureWindowInfo(date: firstOfMarch),
                exposureWindowInfo(date: firstOfMarch),
            ]
        )
        
        // add to the store
        exposureWindowStore.append(exposureWindowsInfoCollection.exposureWindowsInfo)
        
        // load it back up and check they match
        let exposureWindowInfo = try XCTUnwrap(exposureWindowStore.load())
        XCTAssertEqual(exposureWindowInfo, exposureWindowsInfoCollection)
        
        // expire the older windows - we only expect the ones from fifteenDaysAgo to be deleted
        exposureWindowStore.deleteWindows(includingAndPriorTo: secondOfMarch)
        
        let exposureWindowInfoAfterExpiry = try XCTUnwrap(exposureWindowStore.load())
        let remainingWindows = exposureWindowInfoAfterExpiry.exposureWindowsInfo.filter {
            $0.date == fifteenthOfMarch
        }
        XCTAssertEqual(remainingWindows.count, 2)
    }
    
    // MARK: Utilities
    
    private func exposureWindowInfo(date: GregorianDay, isConsideredRisky: Bool) -> ExposureWindowInfo {
        ExposureWindowInfo(
            date: date,
            infectiousness: .high,
            scanInstances: [
                ExposureWindowInfo.ScanInstance(
                    minimumAttenuation: 97,
                    typicalAttenuation: 0,
                    secondsSinceLastScan: 201
                ),
            ],
            riskScore: 131.44555790888523,
            riskCalculationVersion: 2,
            isConsideredRisky: isConsideredRisky
        )
    }
}
