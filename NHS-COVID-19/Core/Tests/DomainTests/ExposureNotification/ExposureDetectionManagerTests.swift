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

class ExposureDetectionManagerTests: XCTestCase {
    private var store: MockEncryptedStore!
    private var enManager: MockExposureNotificationManager!
    private var client: MockHTTPClient!
    private var transmissionRiskLevelApplier: TransmissionRiskLevelApplier!
    
    override func setUp() {
        store = MockEncryptedStore()
        enManager = MockExposureNotificationManager()
        client = MockHTTPClient()
        transmissionRiskLevelApplier = TransmissionRiskLevelApplier()
    }
    
    func testExposureDetection() throws {
        let manager = ExposureDetectionManager(
            manager: enManager,
            distributionClient: client,
            submissionClient: client,
            encryptedStore: store,
            transmissionRiskLevelApplier: transmissionRiskLevelApplier,
            riskCalculator: MockRiskCalculator.init,
            interestedInExposureNotifications: { true }
        )
        
        XCTAssertNoThrow(try manager.detectExposures(currentDate: Date()).await().get())
    }
    
    func testExposureDetectionDownloadCount() throws {
        let minimumNumberOfDailyDownloads = 13
        
        let manager = ExposureDetectionManager(
            manager: enManager,
            distributionClient: client,
            submissionClient: client,
            encryptedStore: store,
            transmissionRiskLevelApplier: transmissionRiskLevelApplier,
            riskCalculator: MockRiskCalculator.init,
            interestedInExposureNotifications: { true }
        )
        
        XCTAssertNoThrow(try manager.detectExposures(currentDate: Date()).await().get())
        XCTAssertTrue(client.requestCount >= minimumNumberOfDailyDownloads)
    }
    
    func testExposureDetectionStoresLastCheckDate() throws {
        let manager = ExposureDetectionManager(
            manager: enManager,
            distributionClient: client,
            submissionClient: client,
            encryptedStore: store,
            transmissionRiskLevelApplier: transmissionRiskLevelApplier,
            riskCalculator: MockRiskCalculator.init,
            interestedInExposureNotifications: { true }
        )
        
        XCTAssertNoThrow(try manager.detectExposures(currentDate: Date()).await().get())
        XCTAssertNotNil(store.stored["background_task_state"])
    }
    
    func testDetectExposureMaxRiskCorrect() throws {
        let maximumRiskScore: ENRiskScore = 84
        
        var risk = maximumRiskScore
        enManager.createExposure = {
            defer {
                risk -= 1
            }
            return [MockExposureInfo(riskScore: risk)]
        }
        
        let manager = ExposureDetectionManager(
            manager: enManager,
            distributionClient: client,
            submissionClient: client,
            encryptedStore: store,
            transmissionRiskLevelApplier: transmissionRiskLevelApplier,
            riskCalculator: MockRiskCalculator.init,
            interestedInExposureNotifications: { true }
        )
        
        let result = try manager.detectExposures(currentDate: Date()).await().get()
        XCTAssertNotNil(store.stored["background_task_state"])
        XCTAssertEqual(result?.riskScore, Double(maximumRiskScore))
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
        
        enManager.diagnosisKeys = diagnosisKeys
        
        class MockTransmissionRiskLevelApplier: TransmissionRiskLevelApplier {
            var calledWithOnsetDay: GregorianDay?
            override func applyTransmissionRiskLevels(for keys: [ENTemporaryExposureKey], onsetDay: GregorianDay) -> [ENTemporaryExposureKey] {
                calledWithOnsetDay = onsetDay
                return keys.sorted { $0.rollingStartNumber < $1.rollingStartNumber }
                    .enumerated()
                    .map { (i, key) -> ENTemporaryExposureKey in
                        key.transmissionRiskLevel = i < 10 ? 0 : 1
                        return key
                    }
            }
        }
        let mockTransmissionRiskLevelApplier = MockTransmissionRiskLevelApplier()
        
        let manager = ExposureDetectionManager(
            manager: enManager,
            distributionClient: client,
            submissionClient: client,
            encryptedStore: store,
            transmissionRiskLevelApplier: mockTransmissionRiskLevelApplier,
            riskCalculator: MockRiskCalculator.init,
            interestedInExposureNotifications: { true }
        )
        
        _ = try manager.sendKeys(for: onsetDay, token: DiagnosisKeySubmissionToken(value: String.random())).await()
        
        let requestBody = try XCTUnwrap(client.lastRequest?.body)
        let decoder = JSONDecoder()
        let payload = try decoder.decode(Payload.self, from: requestBody.content)
        XCTAssertEqual(payload.temporaryExposureKeys.count, 4)
        
        let keysInPeriod = Array(diagnosisKeys[10 ... 13])
        keysInPeriod.forEach { key in
            let payloadKey = Payload.TemporaryExposureKey(
                key: key.keyData,
                rollingStartNumber: key.rollingStartNumber,
                rollingPeriod: key.rollingPeriod,
                transmissionRiskLevel: key.transmissionRiskLevel
            )
            
            XCTAssertTrue(payload.temporaryExposureKeys.contains(payloadKey))
        }
        XCTAssertEqual(mockTransmissionRiskLevelApplier.calledWithOnsetDay, onsetDay)
    }
    
    private class MockHTTPClient: HTTPClient {
        var requestCount = 0
        var lastRequest: HTTPRequest?
        
        func perform(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, HTTPRequestError> {
            requestCount += 1
            lastRequest = request
            
            if request.path == "/distribution/exposure-configuration" {
                return Result.success(.ok(with: .json(exposureConfiguration))).publisher.eraseToAnyPublisher()
            }
            
            if request.path.starts(with: "/distribution/daily/") || request.path.starts(with: "/distribution/two-hourly/") {
                let response = HTTPResponse(httpUrlResponse: HTTPURLResponse(), bodyContent: getZip())
                return Result.success(response).publisher.eraseToAnyPublisher()
            }
            
            if request.path == "/submission/diagnosis-keys" {
                return Result.success(.ok(with: .empty)).publisher.eraseToAnyPublisher()
            }
            
            let error = HTTPRequestError.rejectedRequest(underlyingError: TestError(""))
            return Result.failure(error).publisher.eraseToAnyPublisher()
        }
        
        private func getZip() -> Data {
            // This is the base64 encoded string of TestKeys.zip
            let base64Zip = "UEsDBBQACAAIAAAAAAAAAAAAAAAAAAAAAAAKAAAAZXhwb3J0LmJpbnL1VnCtKMgvKlEoM1RQUFDg/PDieBwDAwODYIHVSTBDiik0WIFRg9FIUYrRUIm9OD83NT4zRUvYUM9Iz8LEQM/QwMDEVM9Ez1jPyEqaS0Bc/0jD0xmePCbiZSzGs0WdBTgk/txbyKjACJLUTma1OtKs3PuwTGxem7ztWQFGiS6QZBEgAAD//1BLBwhQGAPXhwAAAIcAAABQSwMEFAAIAAgAAAAAAAAAAAAAAAAAAAAAAAoAAABleHBvcnQuc2ln4irkUpRiNFRiL87PTY3PTNESNtQz0rMwMdAzNDAwMdUz0TPWMxJglGBU8jBwY1JkmLft5dW1WRn9Kws2PKvhaDOJe39XQjJS725LgpfMeV8mdyZFhgm59Wc/CR4X+OGlVSnOwFq878N79SXTHTXvaZStyZD8lgUIAAD//1BLBwhEY4HtfAAAAHMAAABQSwECFAAUAAgACAAAAAAAUBgD14cAAACHAAAACgAAAAAAAAAAAAAAAAAAAAAAZXhwb3J0LmJpblBLAQIUABQACAAIAAAAAABEY4HtfAAAAHMAAAAKAAAAAAAAAAAAAAAAAL8AAABleHBvcnQuc2lnUEsFBgAAAAACAAIAcAAAAHMBAAAAAA=="
            let decodedData = Data(base64Encoded: base64Zip)!
            return decodedData
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

private class MockExposureInfo: ENExposureInfo {
    private let riskScore: ENRiskScore
    override var totalRiskScore: ENRiskScore { riskScore }
    
    init(riskScore: ENRiskScore) {
        self.riskScore = riskScore
    }
}

private let exposureConfiguration = """
{
    "exposureNotification": {
        "minimumRiskScore": 11,
        "attenuationDurationThresholds": [55, 63],
        "attenuationLevelValues": [0, 1, 1, 1, 1, 1, 1, 1],
        "daysSinceLastExposureLevelValues": [5, 5, 5, 5, 5, 5, 5, 5],
        "durationLevelValues": [0, 0, 0, 1, 1, 1, 1, 1],
        "transmissionRiskLevelValues": [1, 2, 3, 4, 5, 6, 7, 8],
        "attenuationWeight": 50.0,
        "daysSinceLastExposureWeight": 20,
        "durationWeight": 50.0,
        "transmissionRiskWeight": 50.0
    },
    "riskCalculation": {
        "durationBucketWeights": [1.0, 0.5, 0.0],
        "riskThreshold": 20.0
    }
}
"""
