//
// Copyright © 2022 DHSC. All rights reserved.
//

import Combine
import Common
import Domain
import Foundation
import Interface
import Localization
import ExposureNotification

struct SelfReportingFlowInteractor: SelfReportingFlowViewController.Interacting {
    let selfReportingManager: SelfReportingManaging

    var alreadyInIsolation: Bool {
        selfReportingManager.alreadyInIsolation
    }

    func getDiagnosisKeys() -> AnyPublisher<[ENTemporaryExposureKey], Error> {
        selfReportingManager.getDiagnosisKeys()
    }

    func submit(selfReportingInfo: SelfReportingInfo, completion: @escaping (Bool) -> Void) {

        guard let testResult = selfReportingInfo.testResult,
              let testKitType = selfReportingInfo.testKitType,
              let testDay = selfReportingInfo.testDay?.day else {
            completion(false)
            return
        }

        selfReportingManager.submit(
            testResult: testResult == .positive ? .positive : .negative,
            testKitType: testKitType == .labResult ? .labResult : .rapidSelfReported,
            testDate: testDay,
            symptoms: selfReportingInfo.symptoms ?? false,
            onsetDay: selfReportingInfo.symptomsDay?.doNotRemember == false ? selfReportingInfo.symptomsDay?.day : nil,
            nhsTest: selfReportingInfo.nhsTest,
            reportedResult: selfReportingInfo.reportedResult
        )
        completion(true)
    }

    func share(keys: Result<[ENTemporaryExposureKey], Error>,
               selfReportingInfo: SelfReportingInfo,
               completion: @escaping (SelfReportingFlowViewController.State) -> Void) {
        selfReportingManager.share(keys: keys) { completed in
            switch completed {
            case .success(let result):
                completion(.thankYou(reportedResult: selfReportingInfo.reportedResult ?? true, shareResult: result == .sent ? .sent : .notSent))
            case .failure(_):
                completion(.error)
            }
        }
    }

    func doNotShareKeys() {
        selfReportingManager.doNotShareKeys()
    }

    func recordNegativeTestResultMetrics() {
        selfReportingManager.recordNegativeTestResultMetrics()
    }

    func recordVoidTestResultMetrics() {
        selfReportingManager.recordVoidTestResultMetrics()
    }
}
