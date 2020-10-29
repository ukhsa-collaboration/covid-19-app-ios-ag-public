//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest
@testable import Domain

class ExposureDetectionStoreTests: XCTestCase {
    private var encryptedStore: MockEncryptedStore!
    private var exposureDetectionStore: ExposureDetectionStore!
    
    override func setUp() {
        super.setUp()
        
        encryptedStore = MockEncryptedStore()
        exposureDetectionStore = ExposureDetectionStore(store: encryptedStore)
    }
    
    func testCanLoadLastKeyDownloadDate() throws {
        let date = Calendar.utc.date(from: DateComponents(year: 2020, month: 5, day: 7, hour: 8))
        
        encryptedStore.stored["background_task_state"] = """
        {
            "lastKeyDownloadDate": 610531200
        }
        """.data(using: .utf8)
        
        let exposureDetectionInfo = try XCTUnwrap(exposureDetectionStore.load())
        XCTAssertEqual(exposureDetectionInfo.lastKeyDownloadDate, date)
    }
    
    func testCanLoadRiskInfoOld() throws {
        
        encryptedStore.stored["background_task_state"] = """
        {
            "exposureInfo": {
                "riskInfo": {
                    "riskScore": 5.5,
                    "day": {
                        "year": 2020,
                        "month": 5,
                        "day": 5
                    }
                }
            }
        }
        
        """.data(using: .utf8)
        
        let exposureDetectionInfo = try XCTUnwrap(exposureDetectionStore.load())
        let expectedRiskInfo = RiskInfo(riskScore: 5.5, riskScoreVersion: 1, day: .init(year: 2020, month: 5, day: 5))
        XCTAssertEqual(exposureDetectionInfo.exposureInfo?.riskInfo, expectedRiskInfo)
    }
    
    func testCanLoadRiskInfoNew() throws {
        
        encryptedStore.stored["background_task_state"] = """
        {
            "exposureInfo": {
                "riskInfo": {
                    "riskScore": 5.5,
                    "day": {
                        "year": 2020,
                        "month": 5,
                        "day": 5
                    },
                    "riskScoreVersion": 2
                }
            }
        }
        
        """.data(using: .utf8)
        
        let exposureDetectionInfo = try XCTUnwrap(exposureDetectionStore.load())
        let expectedRiskInfo = RiskInfo(riskScore: 5.5, riskScoreVersion: 2, day: .init(year: 2020, month: 5, day: 5))
        XCTAssertEqual(exposureDetectionInfo.exposureInfo?.riskInfo, expectedRiskInfo)
    }
    
    func testCanLoadApprovalToken() throws {
        let approvalTokenString = UUID().uuidString
        
        encryptedStore.stored["background_task_state"] = """
        {
            "exposureInfo": {
                "riskInfo":{
                    "riskScore": 5.5,
                    "day": {
                        "year": 2020,
                        "month": 5,
                        "day": 5
                    }
                },
                "approvalToken": "\(approvalTokenString)"
            }
        }
        """.data(using: .utf8)
        
        let exposureDetectionInfo = try XCTUnwrap(exposureDetectionStore.load())
        XCTAssertEqual(exposureDetectionInfo.exposureInfo?.approvalToken, .init(approvalTokenString))
    }
    
    func testCanNotLoadApprovalTokenWithoutRiskScore() {
        let approvalTokenString = UUID().uuidString
        
        encryptedStore.stored["background_task_state"] = """
        {
            "exposureInfo": {
                "approvalToken": "\(approvalTokenString)"
            }
        }
        """.data(using: .utf8)
        
        XCTAssertNil(exposureDetectionStore.load())
    }
    
    func testSaveLastKeyDownloadDate() {
        let date = Date()
        exposureDetectionStore.save(lastKeyDownloadDate: date)
        XCTAssertEqual(exposureDetectionStore.load()?.lastKeyDownloadDate, date)
    }
    
    func testSaveRiskInfo() {
        let riskInfo = RiskInfo(riskScore: 5.5, riskScoreVersion: 1, day: .init(year: 2020, month: 5, day: 5))
        exposureDetectionStore.save(riskInfo: riskInfo)
        XCTAssertEqual(exposureDetectionStore.load()?.exposureInfo?.riskInfo, riskInfo)
    }
    
    func testSaveExposureInfoToken() {
        let approvalTokenString = UUID().uuidString
        let riskInfo = RiskInfo(riskScore: 5.5, riskScoreVersion: 1, day: .init(year: 2020, month: 5, day: 5))
        exposureDetectionStore.exposureInfo = ExposureInfo(approvalToken: .init(approvalTokenString), riskInfo: riskInfo)
        XCTAssertEqual(exposureDetectionStore.load()?.exposureInfo?.approvalToken, .init(approvalTokenString))
    }
    
    func testDeletingLastKeyDownloadDate() {
        exposureDetectionStore.save(lastKeyDownloadDate: Date())
        exposureDetectionStore.delete()
        XCTAssertNil(exposureDetectionStore.load()?.lastKeyDownloadDate)
    }
    
    func testDeletingRiskScore() {
        exposureDetectionStore.save(riskInfo: RiskInfo(riskScore: 5.5, riskScoreVersion: 1, day: .init(year: 2020, month: 5, day: 5)))
        exposureDetectionStore.delete()
        XCTAssertNil(exposureDetectionStore.load()?.exposureInfo?.riskInfo)
    }
    
    func testDeletingApprovalToken() {
        let approvalTokenString = UUID().uuidString
        let riskInfo = RiskInfo(riskScore: 5.5, riskScoreVersion: 1, day: .init(year: 2020, month: 5, day: 5))
        exposureDetectionStore.exposureInfo = ExposureInfo(approvalToken: .init(approvalTokenString), riskInfo: riskInfo)
        exposureDetectionStore.delete()
        XCTAssertNil(exposureDetectionStore.load()?.exposureInfo?.approvalToken)
    }
    
    func testDeletingExposureInfo() {
        let approvalTokenString = UUID().uuidString
        let riskInfo = RiskInfo(riskScore: 5.5, riskScoreVersion: 1, day: .init(year: 2020, month: 5, day: 5))
        exposureDetectionStore.exposureInfo = ExposureInfo(approvalToken: .init(approvalTokenString), riskInfo: riskInfo)
        exposureDetectionStore.delete()
        XCTAssertNil(exposureDetectionStore.exposureInfo)
    }
}
