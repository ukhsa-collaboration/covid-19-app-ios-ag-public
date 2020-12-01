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
        (Symptom(title: ["": ""], description: ["": ""], riskWeight: 1), false),
        (Symptom(title: ["": ""], description: ["": ""], riskWeight: 1), true),
        (Symptom(title: ["": ""], description: ["": ""], riskWeight: 1), true),
        (Symptom(title: ["": ""], description: ["": ""], riskWeight: 0), true),
    ]
    
    override func setUp() {
        isolationState = .noNeedToIsolate
        selfDiagnosisManager = SelfDiagnosisManager(httpClient: MockHTTPClient()) { _ in self.isolationState }
        addTeardownBlock {
            self.selfDiagnosisManager = nil
        }
    }
    
    func testNoNeedToIsolateIfThresholdNotReached() {
        XCTAssertEqual(selfDiagnosisManager.evaluateSymptoms(symptoms: symptoms, onsetDay: nil, threshold: 3), .noNeedToIsolate)
    }
    
    func testIsolateIfExactlyReachedThreshold() {
        isolationState = .isolate(Isolation(fromDay: .today, untilStartOfDay: .today, reason: .indexCase(hasPositiveTestResult: false, isSelfDiagnosed: true)))
        XCTAssertEqual(selfDiagnosisManager.evaluateSymptoms(symptoms: symptoms, onsetDay: nil, threshold: 2), isolationState)
    }
    
    func testIsolateIfExactlyAboveThreshold() {
        isolationState = .isolate(Isolation(fromDay: .today, untilStartOfDay: .today, reason: .indexCase(hasPositiveTestResult: false, isSelfDiagnosed: true)))
        XCTAssertEqual(selfDiagnosisManager.evaluateSymptoms(symptoms: symptoms, onsetDay: nil, threshold: 1), isolationState)
    }
    
    func testNoNeedToIsolateIfAboveThresholdButIsolationNotRequired() {
        isolationState = .noNeedToIsolate
        XCTAssertEqual(selfDiagnosisManager.evaluateSymptoms(symptoms: symptoms, onsetDay: nil, threshold: 1), .noNeedToIsolate)
    }
    
}
