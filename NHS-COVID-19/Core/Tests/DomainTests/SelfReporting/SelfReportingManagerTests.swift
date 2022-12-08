//
// Copyright © 2022 DHSC. All rights reserved.
//

import Common
import ExposureNotification
import XCTest
@testable import Domain
@testable import Scenarios

@available(iOS 13.7, *)
class SelfReportingManagerTests: AcceptanceTestCase {
    var manager: SelfReportingManaging!

    private let startDate = GregorianDay(year: 2020, month: 1, day: 1).startDate(in: .utc)

    override func setUp() {
        $instance.exposureNotificationManager = MockWindowsExposureNotificationManager()
        currentDateProvider.setDate(startDate)
        try! completeRunning()

        let runningAppContext = try! context()
        manager = runningAppContext.selfReportingManager

        addTeardownBlock {
            self.manager = nil
        }
    }

    func testGetDiagnosisKeys() throws {
        let keys = [ENTemporaryExposureKey()]
        $instance.exposureNotificationManager.diagnosisKeys = keys

        let result = try manager.getDiagnosisKeys().await().get()

        XCTAssert(keys == result)
    }

    func testShareKeys() throws {
        manager.submit(testResult: .positive, testKitType: .labResult, testDate: GregorianDay.today, symptoms: false, onsetDay: nil, nhsTest: nil, reportedResult: nil)

        let keys: Result<[ENTemporaryExposureKey], Error> = .success([ENTemporaryExposureKey()])

        let exp = expectation(description: "callback called")
        manager.share(keys: keys) { completion in
            switch completion {
            case .success(let result):
                XCTAssertTrue(result == .sent)
            case .failure(_):
                XCTFail()
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testDoNotShareKeys() throws {
        manager.submit(testResult: .positive, testKitType: .labResult, testDate: GregorianDay.today, symptoms: false, onsetDay: nil, nhsTest: nil, reportedResult: nil)

        let keys: Result<[ENTemporaryExposureKey], Error> = .failure(ENError(.notAuthorized))

        let exp = expectation(description: "callback called")
        manager.share(keys: keys) { completion in
            switch completion {
            case .success(let result):
                XCTAssertTrue(result == .notSent)
            case .failure(_):
                XCTFail()
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testShareKeysError() {
        enum TestError: Error {
            case expectedError
        }

        manager.submit(testResult: .positive, testKitType: .labResult, testDate: GregorianDay.today, symptoms: false, onsetDay: nil, nhsTest: nil, reportedResult: nil)

        let keys: Result<[ENTemporaryExposureKey], Error> = .failure(TestError.expectedError)

        let exp = expectation(description: "callback called")
        manager.share(keys: keys) { completion in
            switch completion {
            case .success(_):
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error as? TestError, TestError.expectedError)
            }
            exp.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
}
