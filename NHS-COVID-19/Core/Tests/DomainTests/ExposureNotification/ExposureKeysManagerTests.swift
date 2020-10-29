//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import ExposureNotification
import TestSupport
import XCTest
@testable import Domain
@testable import Scenarios

class ExposureKeysManagerTests: XCTestCase {
    private var client: MockHTTPClient!
    private var controller: ExposureNotificationDetectionController!
    
    override func setUp() {
        client = MockHTTPClient()
        controller = MockController()
    }
    
    private class MockController: ExposureNotificationDetectionController {
        var summaryToReturn = ENExposureDetectionSummary()
        var diagnosisKeys: [ENTemporaryExposureKey] = []
        
        init() {
            super.init(manager: MockExposureNotificationManager())
        }
        
        override public func detectExposures(
            configuration: ENExposureConfiguration,
            diagnosisKeyURLs: [URL]
        ) -> AnyPublisher<ENExposureDetectionSummary, Error> {
            return Result.Publisher(summaryToReturn).eraseToAnyPublisher()
        }
        
        override public func getExposureInfo(
            summary: ENExposureDetectionSummary
        ) -> AnyPublisher<[ENExposureInfo], Error> {
            return Result.Publisher([]).eraseToAnyPublisher()
        }
        
        override public func getDiagnosisKeys() -> AnyPublisher<[ENTemporaryExposureKey], Error> {
            return Result.Publisher(diagnosisKeys).eraseToAnyPublisher()
        }
    }
    
    /*
     
     For better testing, key renewal happens at 6 PM (18:00) - This means we always need to ensure that the key from
     the day before StartKeyPeriod is also included in the submitted list
     */
    func testFiltersOutKeysWithTransmissionRiskLevelOfZero() throws {
        let client = MockHTTPClient()
        let calendar = Calendar.current
        
        let onsetDay = GregorianDay(dateComponents: DateComponents(year: 2020, month: 7, day: 12))
        
        var diagnosisKeys = [ENTemporaryExposureKey]()
        (1 ... 14).forEach { index in
            let diagnosisKey = ENTemporaryExposureKey()
            var date = DateComponents(year: 2020, month: 7, day: index, hour: 18)
            date.calendar = calendar
            diagnosisKey.keyData = String.random().data
            diagnosisKey.rollingStartNumber = UInt32(exactly: date.date!.timeIntervalSince1970 / (60 * 10))!
            diagnosisKey.rollingPeriod = UInt32(24 * (60 / 10)) // Amount of 10 minute periods in 24 hours
            diagnosisKeys.append(diagnosisKey)
        }
        
        let controller = MockController()
        controller.diagnosisKeys = diagnosisKeys
        
        let manager = ExposureKeysManager(
            controller: controller,
            submissionClient: client
        )
        
        _ = try manager.sendKeys(for: onsetDay, token: DiagnosisKeySubmissionToken(value: String.random())).await()
        
        let requestBody = try XCTUnwrap(client.lastRequest?.body)
        let decoder = JSONDecoder()
        let payload = try decoder.decode(Payload.self, from: requestBody.content)
        XCTAssertEqual(payload.temporaryExposureKeys.count, 5)
        
        let keysInPeriod = Array(diagnosisKeys[9 ... 13])
        keysInPeriod.forEach { key in
            XCTAssertTrue(payload.temporaryExposureKeys.contains(where: { $0.key == key.keyData }))
        }
    }
    
    private struct Payload: Codable {
        struct TemporaryExposureKey: Codable, Equatable {
            var key: Data
            var rollingStartNumber: UInt32
            var rollingPeriod: UInt32
            var transmissionRiskLevel: UInt8
        }
        
        var diagnosisKeySubmissionToken: String
        var temporaryExposureKeys: [TemporaryExposureKey]
    }
    
}
