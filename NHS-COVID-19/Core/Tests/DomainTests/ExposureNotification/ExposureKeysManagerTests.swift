//
// Copyright © 2021 DHSC. All rights reserved.
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
        
        let today = GregorianDay(dateComponents: DateComponents(year: 2020, month: 7, day: 15))
        
        let onsetDay = GregorianDay(dateComponents: DateComponents(year: 2020, month: 7, day: 12))
        
        let diagnosisKeys = createDiagnosisKeys(year: 2020, month: 7, dayRange: 1 ... 14)
        
        let controller = MockController()
        controller.diagnosisKeys = diagnosisKeys
        
        let manager = ExposureKeysManager(
            controller: controller,
            submissionClient: client,
            trafficObfuscationClient: TrafficObfuscationClient(client: client, rateLimiter: ObfuscationRateLimiter()),
            contactCaseIsolationDuration: 11,
            currentDateProvider: MockDateProvider(getDate: { today.startDate(in: .current) })
        )
        
        _ = try manager.sendKeys(for: onsetDay, token: DiagnosisKeySubmissionToken(value: String.random()), acknowledgementDay: today).await()
        
        let requestBody = try XCTUnwrap(client.lastRequest?.body)
        let decoder = JSONDecoder()
        let payload = try decoder.decode(Payload.self, from: requestBody.content)
        XCTAssertEqual(payload.temporaryExposureKeys.count, 5)
        
        let keysInPeriod = Array(diagnosisKeys[9 ... 13])
        keysInPeriod.forEach { key in
            XCTAssertTrue(payload.temporaryExposureKeys.contains(where: { $0.key == key.keyData }))
        }
    }
    
    func testSendKeysDaysAfterAcknowledgingOnlySendKeysBeforeAckDay() throws {
        let client = MockHTTPClient()
        
        let today = GregorianDay(dateComponents: DateComponents(year: 2020, month: 7, day: 14))
        let onsetDay = GregorianDay(dateComponents: DateComponents(year: 2020, month: 7, day: 6))
        let acknowledgementDay = GregorianDay(dateComponents: DateComponents(year: 2020, month: 7, day: 9))
        
        let diagnosisKeys = createDiagnosisKeys(year: 2020, month: 7, dayRange: 1 ... 14)
        print(diagnosisKeys.map { String(data: $0.keyData) })
        
        let controller = MockController()
        controller.diagnosisKeys = diagnosisKeys
        
        let manager = ExposureKeysManager(
            controller: controller,
            submissionClient: client,
            trafficObfuscationClient: TrafficObfuscationClient(client: client, rateLimiter: ObfuscationRateLimiter()),
            contactCaseIsolationDuration: 11,
            currentDateProvider: MockDateProvider(getDate: { today.startDate(in: .current) })
        )
        
        _ = try manager.sendKeys(for: onsetDay, token: DiagnosisKeySubmissionToken(value: String.random()), acknowledgementDay: acknowledgementDay).await()
        
        let requestBody = try XCTUnwrap(client.lastRequest?.body)
        let decoder = JSONDecoder()
        let payload = try decoder.decode(Payload.self, from: requestBody.content)
        XCTAssertEqual(payload.temporaryExposureKeys.count, 5)
        
        print(payload.temporaryExposureKeys.map { String(data: $0.key) })
        
        let expectedKeys = Array(diagnosisKeys[3 ... 7])
        expectedKeys.forEach { key in
            XCTAssertTrue(
                payload.temporaryExposureKeys
                    .contains(where: { $0.key == key.keyData }),
                "\(String(data: key.keyData)) not present!"
            )
        }
    }
    
    func testSendKeysDaysAfterAcknowledgingMaxContactCaseIsolationDurationRemovesKeys() throws {
        let client = MockHTTPClient()
        
        let today = GregorianDay(dateComponents: DateComponents(year: 2020, month: 7, day: 16))
        let onsetDay = GregorianDay(dateComponents: DateComponents(year: 2020, month: 7, day: 4))
        let acknowledgementDay = GregorianDay(dateComponents: DateComponents(year: 2020, month: 7, day: 12))
        
        let diagnosisKeys = createDiagnosisKeys(year: 2020, month: 7, dayRange: 1 ... 17)
        
        let controller = MockController()
        controller.diagnosisKeys = diagnosisKeys
        
        let manager = ExposureKeysManager(
            controller: controller,
            submissionClient: client,
            trafficObfuscationClient: TrafficObfuscationClient(client: client, rateLimiter: ObfuscationRateLimiter()),
            contactCaseIsolationDuration: 11,
            currentDateProvider: MockDateProvider(getDate: { today.startDate(in: .current) })
        )
        
        _ = try manager.sendKeys(for: onsetDay, token: DiagnosisKeySubmissionToken(value: String.random()), acknowledgementDay: acknowledgementDay).await()
        
        let requestBody = try XCTUnwrap(client.lastRequest?.body)
        let decoder = JSONDecoder()
        let payload = try decoder.decode(Payload.self, from: requestBody.content)
        XCTAssertEqual(payload.temporaryExposureKeys.count, 5)
        
        let expectedKeys = Array(diagnosisKeys[5 ... 9])
        expectedKeys.forEach { key in
            XCTAssertTrue(
                payload.temporaryExposureKeys
                    .contains(where: { $0.key == key.keyData }),
                "\(String(data: key.keyData)) not present!"
            )
        }
    }
    
    private func createDiagnosisKeys(year: Int, month: Int, dayRange: ClosedRange<Int>) -> [ENTemporaryExposureKey] {
        var diagnosisKeys = [ENTemporaryExposureKey]()
        dayRange.forEach { index in
            let diagnosisKey = ENTemporaryExposureKey()
            var date = DateComponents(year: year, month: month, day: index, hour: 18)
            date.calendar = Calendar.current
            diagnosisKey.keyData = String.random().data
            diagnosisKey.rollingStartNumber = UInt32(exactly: date.date!.timeIntervalSince1970 / (60 * 10))!
            diagnosisKey.rollingPeriod = UInt32(24 * (60 / 10)) // Amount of 10 minute periods in 24 hours
            diagnosisKeys.append(diagnosisKey)
        }
        return diagnosisKeys
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
