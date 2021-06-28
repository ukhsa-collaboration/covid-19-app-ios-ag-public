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
        Symptom(title: [Locale(identifier: ""): ""], description: [Locale(identifier: ""): ""], riskWeight: 1),
        Symptom(title: [Locale(identifier: ""): ""], description: [Locale(identifier: ""): ""], riskWeight: 1),
        Symptom(title: [Locale(identifier: ""): ""], description: [Locale(identifier: ""): ""], riskWeight: 0),
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
        let evaluation = selfDiagnosisManager.evaluate(selectedSymptoms: symptoms, onsetDay: nil, threshold: 3)
        XCTAssertEqual(evaluation, .noSymptoms)
    }
    
    func testIsolateIfExactlyReachedThreshold() {
        let isolation = Isolation(fromDay: .today, untilStartOfDay: .today, reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil))
        isolationState = .isolate(isolation)
        let evaluation = selfDiagnosisManager.evaluate(selectedSymptoms: symptoms, onsetDay: nil, threshold: 2)
        XCTAssertEqual(evaluation, .hasSymptoms(isolation, .hasNoTest))
    }
    
    func testIsolateIfExactlyAboveThreshold() {
        let isolation = Isolation(fromDay: .today, untilStartOfDay: .today, reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false), contactCaseInfo: nil))
        isolationState = .isolate(isolation)
        let evaluation = selfDiagnosisManager.evaluate(selectedSymptoms: symptoms, onsetDay: nil, threshold: 1)
        XCTAssertEqual(evaluation, .hasSymptoms(isolation, .hasNoTest))
    }
    
    func testNoNeedToIsolateIfAboveThresholdButIsolationNotRequired() {
        isolationState = .noNeedToIsolate()
        let evaluation = selfDiagnosisManager.evaluate(selectedSymptoms: symptoms, onsetDay: nil, threshold: 1)
        XCTAssertEqual(evaluation, .noSymptoms)
    }
    
}
