//
// Copyright © 2021 DHSC. All rights reserved.
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
        selfDiagnosisManager = SelfDiagnosisManager(httpClient: MockHTTPClient()) { _ in (self.isolationState, nil) }
        addTeardownBlock {
            self.selfDiagnosisManager = nil
        }
    }
    
    func testNoNeedToIsolateIfThresholdNotReached() {
        isolationState = .noNeedToIsolate()
        let state = selfDiagnosisManager.evaluateSymptoms(symptoms: symptoms, onsetDay: nil, threshold: 3)
        XCTAssertEqual(state.0, isolationState)
        XCTAssertNil(state.1)
    }
    
    func testIsolateIfExactlyReachedThreshold() {
        isolationState = .isolate(Isolation(fromDay: .today, untilStartOfDay: .today, reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil)))
        let state = selfDiagnosisManager.evaluateSymptoms(symptoms: symptoms, onsetDay: nil, threshold: 2)
        XCTAssertEqual(state.0, isolationState)
        XCTAssertNil(state.1)
    }
    
    func testIsolateIfExactlyAboveThreshold() {
        isolationState = .isolate(Isolation(fromDay: .today, untilStartOfDay: .today, reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil)))
        let state = selfDiagnosisManager.evaluateSymptoms(symptoms: symptoms, onsetDay: nil, threshold: 1)
        XCTAssertEqual(state.0, isolationState)
        XCTAssertNil(state.1)
    }
    
    func testNoNeedToIsolateIfAboveThresholdButIsolationNotRequired() {
        isolationState = .noNeedToIsolate()
        let state = selfDiagnosisManager.evaluateSymptoms(symptoms: symptoms, onsetDay: nil, threshold: 1)
        XCTAssertEqual(state.0, isolationState)
        XCTAssertNil(state.1)
    }
    
}
