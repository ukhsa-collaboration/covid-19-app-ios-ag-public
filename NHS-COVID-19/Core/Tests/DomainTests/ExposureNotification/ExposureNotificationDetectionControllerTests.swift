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
        
        let exposureDetectionManager = ExposureNotificationDetectionController(manager: exposureManager)
        
        let result = try exposureDetectionManager.getDiagnosisKeys().await().get()
        
        XCTAssert(keys == result)
        
    }
    
    func testDetectExposures() throws {
        let exposureManager = MockExposureNotificationManager()
        let summary = ENExposureDetectionSummary()
        exposureManager.summary = summary
        
        let exposureDetectionManager = ExposureNotificationDetectionController(manager: exposureManager)
        
        let urls = [URL(string: UUID().uuidString)!]
        let result = try exposureDetectionManager.detectExposures(configuration: ENExposureConfiguration(), diagnosisKeyURLs: urls)
            .await().get()
        
        XCTAssert(summary === result)
        XCTAssert(urls == exposureManager.urls)
    }
    
    func testGetExposureInfo() throws {
        let exposureManager = MockExposureNotificationManager()
        let exposures = [ENExposureInfo()]
        exposureManager.exposures = exposures
        
        let exposureDetectionManager = ExposureNotificationDetectionController(manager: exposureManager)
        
        let summary = ENExposureDetectionSummary()
        
        let result = try exposureDetectionManager.getExposureInfo(summary: summary)
            .await().get()
        
        XCTAssert(summary === exposureManager.summary)
        XCTAssert(result == exposures)
    }
}
