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

class ExposureDetectionManagerTests: XCTestCase {
    private var store: MockEncryptedStore!
    private var client: MockHTTPClient!
    private var controller: MockController!

    override func setUp() {
        store = MockEncryptedStore()
        client = MockHTTPClient()
        controller = MockController()
    }

    private class MockController: ExposureNotificationDetectionController {
        var summaryToReturn: ENExposureDetectionSummary = ENExposureDetectionSummary()
        var diagnosisKeys: [ENTemporaryExposureKey] = []
        var exposureInfos: [MockExposureInfo] = []
        var countOfDiagnosisKeyURLsRequested = 0

        init() {
            super.init(manager: MockExposureNotificationManager())
        }

        override public func detectExposures(
            configuration: ENExposureConfiguration,
            diagnosisKeyURLs: [URL]
        ) -> AnyPublisher<ENExposureDetectionSummary, Error> {
            countOfDiagnosisKeyURLsRequested += diagnosisKeyURLs.count
            return Result.Publisher(summaryToReturn).eraseToAnyPublisher()
        }

        override public func getExposureInfo(
            summary: ENExposureDetectionSummary
        ) -> AnyPublisher<[ENExposureInfo], Error> {
            return Result.Publisher(exposureInfos).eraseToAnyPublisher()
        }

        override public func getDiagnosisKeys() -> AnyPublisher<[ENTemporaryExposureKey], Error> {
            return Result.Publisher(diagnosisKeys).eraseToAnyPublisher()
        }
    }

    func testExposureDetection() throws {
        let manager = ExposureDetectionManager(
            controller: controller,
            distributionClient: client,
            fileStorage: FileStorage(forCachesOf: .random()),
            encryptedStore: store,
            interestedInExposureNotifications: { true },
            exposureRiskManager: MockExposureRiskManager()
        )

        XCTAssertNoThrow(try manager.detectExposures(currentDate: Date(), sendFakeExposureWindows: {}).await().get())
    }

    func testExposureDetectionStoreSavesTheLastCheckedDateWithNetworkCallsButNoRiskInfoIfNotInterested() throws {
        let minimumNumberOfDailyDownloads = 13
        let maximumRiskScore: ENRiskScore = 84
        let controller = MockController()
        controller.exposureInfos = [MockExposureInfo(riskScore: maximumRiskScore)]

        let mockExposureRiskManager = MockExposureRiskManager()
        mockExposureRiskManager.riskInfoToReturn = ExposureRiskInfo(riskScore: Double(maximumRiskScore), riskScoreVersion: 1, day: GregorianDay.today, isConsideredRisky: false)
        let manager = ExposureDetectionManager(
            controller: controller,
            distributionClient: client,
            fileStorage: FileStorage(forCachesOf: .random()),
            encryptedStore: store,
            interestedInExposureNotifications: { false },
            exposureRiskManager: mockExposureRiskManager
        )

        let currentDate = GregorianDay(year: 2020, month: 8, day: 15).startDate(in: .utc)
        var didSendFakeWindows = false
        let result = try manager.detectExposures(
            currentDate: currentDate,
            sendFakeExposureWindows: { didSendFakeWindows = true }
        ).await().get()

        XCTAssertNil(result)
        let exposureDetectionStore = ExposureDetectionStore(store: store)
        TS.assert(exposureDetectionStore.load()?.lastKeyDownloadDate, equals: currentDate)
        XCTAssertTrue(client.batchEndpointCallCount >= minimumNumberOfDailyDownloads)
        XCTAssertTrue(didSendFakeWindows)
    }

    func testExposureDetectionDownloadCount() throws {
        let minimumNumberOfDailyDownloads = 13

        let manager = ExposureDetectionManager(
            controller: controller,
            distributionClient: client,
            fileStorage: FileStorage(forCachesOf: .random()),
            encryptedStore: store,
            interestedInExposureNotifications: { true },
            exposureRiskManager: MockExposureRiskManager()
        )

        XCTAssertNoThrow(try manager.detectExposures(currentDate: Date(), sendFakeExposureWindows: {}).await().get())
        XCTAssertTrue(client.batchEndpointCallCount >= minimumNumberOfDailyDownloads)
    }

    func testExposureDetectionProcessesEachFileSeparatelyWhenInIncrementalMode() throws {
        let riskManager = configuring(MockExposureRiskManager()) {
            $0.preferredProcessingMode = .incremental
        }

        let manager = ExposureDetectionManager(
            controller: controller,
            distributionClient: client,
            fileStorage: FileStorage(forCachesOf: .random()),
            encryptedStore: store,
            interestedInExposureNotifications: { true },
            exposureRiskManager: riskManager
        )

        XCTAssertNoThrow(try manager.detectExposures(currentDate: Date(), sendFakeExposureWindows: {}).await().get())
        XCTAssertEqual(controller.countOfDiagnosisKeyURLsRequested, client.batchEndpointCallCount * MockHTTPClient.numberOfFilesInZip)
        XCTAssertEqual(riskManager.riskInfoCalledWith.count, client.batchEndpointCallCount)
    }

    func testExposureDetectionProcessesAllFileInBulkWhenInBulkMode() throws {
        let riskManager = configuring(MockExposureRiskManager()) {
            $0.preferredProcessingMode = .bulk
        }

        let manager = ExposureDetectionManager(
            controller: controller,
            distributionClient: client,
            fileStorage: FileStorage(forCachesOf: .random()),
            encryptedStore: store,
            interestedInExposureNotifications: { true },
            exposureRiskManager: riskManager
        )

        XCTAssertNoThrow(try manager.detectExposures(currentDate: Date(), sendFakeExposureWindows: {}).await().get())
        XCTAssertEqual(controller.countOfDiagnosisKeyURLsRequested, client.batchEndpointCallCount * MockHTTPClient.numberOfFilesInZip)
        XCTAssertEqual(riskManager.riskInfoCalledWith.count, 1)
    }

    func testExposureDetectionStoresLastCheckDate() throws {
        let manager = ExposureDetectionManager(
            controller: controller,
            distributionClient: client,
            fileStorage: FileStorage(forCachesOf: .random()),
            encryptedStore: store,
            interestedInExposureNotifications: { true },
            exposureRiskManager: MockExposureRiskManager()
        )

        XCTAssertNoThrow(try manager.detectExposures(currentDate: Date(), sendFakeExposureWindows: {}).await().get())
        XCTAssertNotNil(store.stored["background_task_state"])
    }

    func testDetectExposureMaxRiskCorrect() throws {
        let maximumRiskScore: ENRiskScore = 84
        let controller = MockController()
        controller.exposureInfos = [MockExposureInfo(riskScore: maximumRiskScore)]

        let mockExposureRiskManager = MockExposureRiskManager()
        mockExposureRiskManager.riskInfoToReturn = ExposureRiskInfo(riskScore: Double(maximumRiskScore), riskScoreVersion: 1, day: GregorianDay.today, isConsideredRisky: false)
        let manager = ExposureDetectionManager(
            controller: controller,
            distributionClient: client,
            fileStorage: FileStorage(forCachesOf: .random()),
            encryptedStore: store,
            interestedInExposureNotifications: { true },
            exposureRiskManager: mockExposureRiskManager
        )

        let result = try manager.detectExposures(currentDate: Date(), sendFakeExposureWindows: {}).await().get()

        XCTAssertNotNil(store.stored["background_task_state"])
        XCTAssertEqual(result?.riskScore, Double(maximumRiskScore))
    }

    func testUseExposureRiskManagerToCalculateRiskInfo() throws {
        let exposureRiskManager = MockExposureRiskManager()
        let expectedRiskInfo = ExposureRiskInfo(riskScore: 1000.0, riskScoreVersion: 1, day: GregorianDay.today, isConsideredRisky: false)
        exposureRiskManager.riskInfoToReturn = expectedRiskInfo
        let expectedSummary = ENExposureDetectionSummary()
        let controller = MockController()
        controller.summaryToReturn = expectedSummary
        let manager = ExposureDetectionManager(
            controller: controller,
            distributionClient: client,
            fileStorage: FileStorage(forCachesOf: .random()),
            encryptedStore: store,
            interestedInExposureNotifications: { true },
            exposureRiskManager: exposureRiskManager
        )

        let riskInfo = try manager.detectExposures(currentDate: Date(), sendFakeExposureWindows: {}).await().get()

        XCTAssertEqual(exposureRiskManager.riskInfoCalledWith.last, expectedSummary)
        XCTAssertEqual(riskInfo?.riskScore, expectedRiskInfo.riskScore)
        XCTAssertEqual(riskInfo?.day, expectedRiskInfo.day)
    }

    func testDetectExposuresOnlyWithinGivenFrequency() throws {
        let riskManager = MockExposureRiskManager()
        riskManager.checkFrequency = 4 * 60 * 60
        let manager = ExposureDetectionManager(
            controller: controller,
            distributionClient: client,
            fileStorage: FileStorage(forCachesOf: .random()),
            encryptedStore: store,
            interestedInExposureNotifications: { true },
            exposureRiskManager: riskManager
        )

        let currentDate = Date()
        let lastDownloadDate = currentDate.advanced(by: -3 * 60 * 60)

        let exposureDetectionStore = ExposureDetectionStore(store: store)
        exposureDetectionStore.save(lastKeyDownloadDate: lastDownloadDate)

        XCTAssertNoThrow(try manager.detectExposures(currentDate: currentDate, sendFakeExposureWindows: {}).prepend(nil).await().get())

        TS.assert(exposureDetectionStore.load()?.lastKeyDownloadDate, equals: lastDownloadDate)
        XCTAssertEqual(client.batchEndpointCallCount, 0)
    }

    private class MockExposureRiskManager: ExposureRiskManaging {
        var riskInfoCalledWith = [ENExposureDetectionSummary]()
        var riskInfoToReturn: ExposureRiskInfo?
        var checkFrequency: TimeInterval = 2 * 60 * 60

        var preferredProcessingMode = ProcessingMode.incremental

        func riskInfo(for summary: ENExposureDetectionSummary, configuration: ExposureDetectionConfiguration) -> AnyPublisher<ExposureRiskInfo?, Error> {
            riskInfoCalledWith.append(summary)
            return Result.Publisher(riskInfoToReturn).eraseToAnyPublisher()
        }
    }

    private class MockHTTPClient: HTTPClient {
        static let numberOfFilesInZip = 2

        var batchEndpointCallCount = 0
        var lastRequest: HTTPRequest?

        func perform(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, HTTPRequestError> {
            lastRequest = request

            if request.path == "/distribution/exposure-configuration" {
                return Result.success(.ok(with: .json(exposureConfiguration))).publisher.eraseToAnyPublisher()
            }

            if request.path.starts(with: "/distribution/daily/") || request.path.starts(with: "/distribution/two-hourly/") {
                batchEndpointCallCount += 1
                let response = HTTPResponse(httpUrlResponse: HTTPURLResponse(), bodyContent: getZip())
                return Result.success(response).publisher.eraseToAnyPublisher()
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
    },
    "v2RiskCalculation": {
        "daysSinceOnsetToInfectiousness": [
            0, 0, 0, 0, 0, 0, 0, 0, 0,
            1, 1, 1,
            2, 2, 2, 2, 2, 2,
            1, 1, 1, 1, 1, 1,
            0, 0, 0, 0, 0
        ],
        "infectiousnessWeights": [0.0, 0.4, 1.0],
        "reportTypeWhenMissing": 1,
        "riskThreshold": 0.0
    },
    "riskScore": {
        "sampleResolution": 1.0,
        "expectedDistance": 0.1,
        "minimumDistance": 1.0,
        "rssiParameters" : {
            "weightCoefficient": 0.1270547531082051,
            "intercept": 4.2309333657856945,
            "covariance": 0.4947614361027773
        },
        "powerLossParameters": {
            "wavelength": 0.125,
            "pathLossFactor": 20.0,
            "refDeviceLoss": 0.0
        },
        "observationType": "log",
        "initialData": {
            "mean": 2.0,
            "covariance": 10.0
        },
        "smootherParameters": {
            "alpha": 1.0,
            "beta": 0.0,
            "kappa": 0.0
        }
    }
}
"""
