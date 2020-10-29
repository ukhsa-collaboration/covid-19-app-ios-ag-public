//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Domain
import ExposureNotification
import Localization
import TestSupport
import XCTest
@testable import Scenarios

class ExposureNotificationDetectionControllerTests: XCTestCase {
    
    func testGetDiagnosisKeys() throws {
        let exposureManager = MockExposureNotificationManager()
        let keys = [ENTemporaryExposureKey()]
        exposureManager.diagnosisKeys = keys
        let exposureDetectionController = ExposureNotificationDetectionController(manager: exposureManager)
        
        let result = try exposureDetectionController.getDiagnosisKeys().await().get()
        
        XCTAssert(keys == result)
        
    }
    
    func testDetectExposures() throws {
        let exposureManager = MockExposureNotificationManager()
        let summary = ENExposureDetectionSummary()
        exposureManager.summary = summary
        let exposureDetectionController = ExposureNotificationDetectionController(manager: exposureManager)
        
        let urls = [URL(string: UUID().uuidString)!]
        let result = try exposureDetectionController.detectExposures(configuration: ENExposureConfiguration(), diagnosisKeyURLs: urls)
            .await().get()
        
        XCTAssert(summary === result)
        XCTAssert(urls == exposureManager.urls)
    }
    
    func testGetExposureInfo() throws {
        let exposureManager = MockExposureNotificationManager()
        let exposures = [ENExposureInfo()]
        exposureManager.exposureInfo = exposures
        let exposureDetectionController = ExposureNotificationDetectionController(manager: exposureManager)
        let summary = ENExposureDetectionSummary()
        
        let result = try exposureDetectionController.getExposureInfo(summary: summary)
            .await().get()
        
        XCTAssert(summary === exposureManager.summary)
        XCTAssert(result == exposures)
    }
    
    @available(iOS 13.7, *)
    func testGetExposureWindows() throws {
        let mockExposureManager = MockWindowsExposureNotificationManager()
        let passedSummary = ENExposureDetectionSummary()
        let expectedWindows = [ENExposureWindow()]
        mockExposureManager.exposureWindows = expectedWindows
        let exposureDetectionController = ExposureNotificationDetectionController(manager: mockExposureManager)
        
        let windows = try exposureDetectionController.getExposureWindows(summary: passedSummary)
            .await().get()
        
        XCTAssertEqual(passedSummary, mockExposureManager.summary)
        XCTAssertEqual(expectedWindows, windows)
    }
}
