//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Scenarios
import TestSupport
import XCTest
@testable import Domain

class SelfDiagnosisManagerTests: XCTestCase {
    
    var selfDiagnosisManager: SelfDiagnosisManager!
    private var isolationState: IsolationState!
    private let timeZone = TimeZone.utc
    
    fileprivate let symptoms = [
        (Symptom(title: [Locale(identifier: ""): ""], description: [Locale(identifier: ""): ""], riskWeight: 1), false),
        (Symptom(title: [Locale(identifier: ""): ""], description: [Locale(identifier: ""): ""], riskWeight: 1), true),
        (Symptom(title: [Locale(identifier: ""): ""], description: [Locale(identifier: ""): ""], riskWeight: 1), true),
        (Symptom(title: [Locale(identifier: ""): ""], description: [Locale(identifier: ""): ""], riskWeight: 0), true),
    ]
    
    override func setUp() {
        isolationState = .noNeedToIsolate()
        selfDiagnosisManager = SelfDiagnosisManager(httpClient: MockHTTPClient()) { _ in self.isolationState }
        addTeardownBlock {
            self.selfDiagnosisManager = nil
        }
    }
    
    func testNoNeedToIsolateIfThresholdNotReached() {
        XCTAssertEqual(selfDiagnosisManager.evaluateSymptoms(symptoms: symptoms, onsetDay: nil, threshold: 3), .noNeedToIsolate())
    }
    
    func testIsolateIfExactlyReachedThreshold() {
        isolationState = .isolate(Isolation(fromDay: .today, untilStartOfDay: .today, reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil)))
        XCTAssertEqual(selfDiagnosisManager.evaluateSymptoms(symptoms: symptoms, onsetDay: nil, threshold: 2), isolationState)
    }
    
    func testIsolateIfExactlyAboveThreshold() {
        isolationState = .isolate(Isolation(fromDay: .today, untilStartOfDay: .today, reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil)))
        XCTAssertEqual(selfDiagnosisManager.evaluateSymptoms(symptoms: symptoms, onsetDay: nil, threshold: 1), isolationState)
    }
    
    func testNoNeedToIsolateIfAboveThresholdButIsolationNotRequired() {
        isolationState = .noNeedToIsolate()
        XCTAssertEqual(selfDiagnosisManager.evaluateSymptoms(symptoms: symptoms, onsetDay: nil, threshold: 1), .noNeedToIsolate())
    }
    
}
