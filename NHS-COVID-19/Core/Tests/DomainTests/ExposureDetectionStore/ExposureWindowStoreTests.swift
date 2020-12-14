//
// Copyright © 2020 NHSX. All rights reserved.
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
        exposureWindowStore = ExposureWindowStore(store: encryptedStore)
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
                ExposureWindowInfo(
                    date: GregorianDay(year: 2020, month: 7, day: 11),
                    infectiousness: .high,
                    scanInstances: [
                        ExposureWindowInfo.ScanInstance(
                            minimumAttenuation: 97,
                            typicalAttenuation: 0,
                            secondsSinceLastScan: 201
                        ),
                    ],
                    riskScore: 131.44555790888523,
                    riskCalculationVersion: 2
                ),
            ]
        )
        XCTAssertEqual(exposureWindowInfo, exposureWindowsInfoCollection)
    }
    
    func testAppendFirstTimeToNilCollection() throws {
        XCTAssertNil(exposureWindowStore.load())
        exposureWindowStore.append(
            ExposureWindowInfo(
                date: GregorianDay(year: 2020, month: 7, day: 11),
                infectiousness: .high,
                scanInstances: [
                    ExposureWindowInfo.ScanInstance(
                        minimumAttenuation: 97,
                        typicalAttenuation: 0,
                        secondsSinceLastScan: 201
                    ),
                ],
                riskScore: 131.44555790888523,
                riskCalculationVersion: 2
            )
        )
        let exposureWindowInfo = try XCTUnwrap(exposureWindowStore.load())
        let exposureWindowsInfoCollection = ExposureWindowInfoCollection(
            exposureWindowsInfo: [
                ExposureWindowInfo(
                    date: GregorianDay(year: 2020, month: 7, day: 11),
                    infectiousness: .high,
                    scanInstances: [
                        ExposureWindowInfo.ScanInstance(
                            minimumAttenuation: 97,
                            typicalAttenuation: 0,
                            secondsSinceLastScan: 201
                        ),
                    ],
                    riskScore: 131.44555790888523,
                    riskCalculationVersion: 2
                ),
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
        exposureWindowStore.append(
            ExposureWindowInfo(
                date: GregorianDay(year: 2020, month: 7, day: 11),
                infectiousness: .high,
                scanInstances: [
                    ExposureWindowInfo.ScanInstance(
                        minimumAttenuation: 97,
                        typicalAttenuation: 0,
                        secondsSinceLastScan: 201
                    ),
                ],
                riskScore: 131.44555790888523,
                riskCalculationVersion: 2
            )
        )
        let exposureWindowInfo = try XCTUnwrap(exposureWindowStore.load())
        let exposureWindowsInfoCollection = ExposureWindowInfoCollection(
            exposureWindowsInfo: [
                ExposureWindowInfo(
                    date: GregorianDay(year: 2020, month: 7, day: 11),
                    infectiousness: .high,
                    scanInstances: [
                        ExposureWindowInfo.ScanInstance(
                            minimumAttenuation: 97,
                            typicalAttenuation: 0,
                            secondsSinceLastScan: 201
                        ),
                    ],
                    riskScore: 131.44555790888523,
                    riskCalculationVersion: 2
                ),
                ExposureWindowInfo(
                    date: GregorianDay(year: 2020, month: 7, day: 11),
                    infectiousness: .high,
                    scanInstances: [
                        ExposureWindowInfo.ScanInstance(
                            minimumAttenuation: 97,
                            typicalAttenuation: 0,
                            secondsSinceLastScan: 201
                        ),
                    ],
                    riskScore: 131.44555790888523,
                    riskCalculationVersion: 2
                ),
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
}
