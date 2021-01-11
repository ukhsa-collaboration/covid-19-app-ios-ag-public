//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import XCTest
@testable import Domain

@available(iOS 13.7, *)
class PollingTestResultAnalyticsTests: AnalyticsTests {
    private var pollingTestResult: PollingTestResult!
    private var testOrdering: TestOrdering!
    private var questionnaire: Questionnaire!
    
    override func setUpFunctionalities() {
        let runningAppContext = try! context()
        pollingTestResult = PollingTestResult(configuration: $instance, context: runningAppContext)
        testOrdering = TestOrdering(configuration: $instance, context: runningAppContext)
        questionnaire = Questionnaire(context: runningAppContext)
    }
    
    // hasTestedPositiveBackgroundTick - Polling
    // >0 if the app is aware that the user has received/entered a positive test
    // this currently happens during an isolation and for the 14 days after isolation
    func testHasTestedPositiveBackgroundTickPresentAfterTestResultReceived() throws {
        // Current date: 1st Jan
        // Starting state: App running normally, not in isolation
        advanceToEndOfAnalyticsWindow()
        // Current date: 2nd Jan -> Analytics packet for: 1st Jan
        assert(\.isIsolatingBackgroundTick).isNotPresent()
        assert(\.isIsolatingForTestedPositiveBackgroundTick).isNotPresent()
        assert(\.isIsolatingForSelfDiagnosedBackgroundTick).isNotPresent()
        assert(\.hasSelfDiagnosedPositiveBackgroundTick).isNotPresent()
        assert(\.hasTestedPositiveBackgroundTick).isNotPresent()
        
        // Complete questionnaire with risky symptoms and order test on 2nd Jan
        // Symptom onset date: 2nd Jan
        // Isolation end date: 12th Jan
        try questionnaire.selfDiagnosePositive(onsetDay: currentDateProvider.currentGregorianDay(timeZone: .utc))
        try testOrdering.order()
        
        advanceToEndOfAnalyticsWindow()
        
        // Current date: 3rd Jan -> Analytics packet for: 2nd Jan
        // Now in isolation due to self-diagnosis
        assert(\.completedQuestionnaireAndStartedIsolation).equals(1)
        assert(\.hasSelfDiagnosedPositiveBackgroundTick).isPresent()
        assert(\.isIsolatingBackgroundTick).isPresent()
        assert(\.isIsolatingForSelfDiagnosedBackgroundTick).isPresent()
        
        // Receive positive test result via polling
        try pollingTestResult.receivePositiveAndAcknowledge {
            self.advanceToNextBackgroundTaskExecution()
        }
        
        advanceToEndOfAnalyticsWindow(steps: 11)
        // Current date: 4th Jan -> Analytics packet for: 3rd Jan
        // Still in isolation, for both self-diagnosis and positive test result
        assert(\.receivedPositiveTestResult).equals(1)
        assert(\.receivedPositiveTestResultViaPolling).equals(1)
        assert(\.hasSelfDiagnosedPositiveBackgroundTick).isPresent()
        assert(\.hasTestedPositiveBackgroundTick).isPresent()
        assert(\.isIsolatingBackgroundTick).isPresent()
        assert(\.isIsolatingForSelfDiagnosedBackgroundTick).isPresent()
        assert(\.isIsolatingForTestedPositiveBackgroundTick).isPresent()
        
        // Dates: 5th-13th Jan -> Analytics packets for: 4th-13th Jan
        // Still in isolation
        for _ in 5 ... 13 {
            advanceToEndOfAnalyticsWindow()
            
            assert(\.isIsolatingBackgroundTick).isPresent()
            assert(\.isIsolatingForTestedPositiveBackgroundTick).isPresent()
            assert(\.isIsolatingForSelfDiagnosedBackgroundTick).isPresent()
            assert(\.hasSelfDiagnosedPositiveBackgroundTick).isPresent()
            assert(\.hasTestedPositiveBackgroundTick).isPresent()
        }
        
        // Dates: 14th-27th Jan -> Analytics packets for: 13th-26th Jan
        // Isolation is over, but isolation reason still stored for 14 days
        for _ in 14 ... 27 {
            advanceToEndOfAnalyticsWindow()
            
            assert(\.isIsolatingBackgroundTick).isNotPresent()
            assert(\.isIsolatingForTestedPositiveBackgroundTick).isNotPresent()
            assert(\.isIsolatingForSelfDiagnosedBackgroundTick).isNotPresent()
            assert(\.hasSelfDiagnosedPositiveBackgroundTick).isPresent()
            assert(\.hasTestedPositiveBackgroundTick).isPresent()
        }
        
        advanceToEndOfAnalyticsWindow()
        // Current date: 27th Jan -> Analytics packet for: 26th Jan
        // Previous isolation reason no longer stored
        assert(\.hasSelfDiagnosedPositiveBackgroundTick).isNotPresent()
        assert(\.hasTestedPositiveBackgroundTick).isNotPresent()
    }
    
    func testReceivingNegativeTestResultAfterPositiveSelfDiagnosisEndsIsolation() throws {
        // Current date: 1st Jan
        // Starting state: App running normally, not in isolation
        advanceToEndOfAnalyticsWindow()
        // Current date: 2nd Jan -> Analytics packet for: 1st Jan
        assert(\.isIsolatingBackgroundTick).isNotPresent()
        
        // Complete questionnaire with risky symptoms and order test on 2nd Jan
        // Symptom onset date: 2nd Jan
        // Isolation end date: 12th Jan
        try questionnaire.selfDiagnosePositive(onsetDay: currentDateProvider.currentGregorianDay(timeZone: .utc))
        try testOrdering.order()
        
        advanceToEndOfAnalyticsWindow()
        
        // Current date: 3rd Jan -> Analytics packet for: 2nd Jan
        // Now in isolation due to self-diagnosis
        assert(\.completedQuestionnaireAndStartedIsolation).equals(1)
        assert(\.hasSelfDiagnosedPositiveBackgroundTick).isPresent()
        assert(\.isIsolatingBackgroundTick).isPresent()
        assert(\.isIsolatingForSelfDiagnosedBackgroundTick).isPresent()
        
        // Receive negative test result via polling
        try pollingTestResult.receiveNegativeAndAcknowledge {
            self.advanceToNextBackgroundTaskExecution()
        }
        
        advanceToEndOfAnalyticsWindow(steps: 11)
        
        // Current date: 4th Jan -> Analytics packet for: 3rd Jan
        // Isolation ends part way through analytics window due to negative test result
        assert(\.receivedNegativeTestResult).equals(1)
        assert(\.receivedNegativeTestResultViaPolling).equals(1)
        assert(\.hasSelfDiagnosedPositiveBackgroundTick).isPresent()
        assert(\.hasTestedPositiveBackgroundTick).isNotPresent()
        assert(\.isIsolatingBackgroundTick).isLessThanTotalBackgroundTasks()
        assert(\.isIsolatingForSelfDiagnosedBackgroundTick).isLessThanTotalBackgroundTasks()
        assert(\.isIsolatingForTestedPositiveBackgroundTick).isNotPresent()
        
        // Reason stored until 17th
        // Dates: 5th-17th Jan -> Analytics packets for: 4th-16th Jan
        // Isolation is over, but isolation reason still stored for 14 days
        for _ in 5 ... 17 {
            advanceToEndOfAnalyticsWindow()
            
            assert(\.hasSelfDiagnosedPositiveBackgroundTick).isPresent()
            assert(\.isIsolatingBackgroundTick).isNotPresent()
            assert(\.isIsolatingForSelfDiagnosedBackgroundTick).isNotPresent()
        }
        
        advanceToEndOfAnalyticsWindow()
        assert(\.hasSelfDiagnosedPositiveBackgroundTick).isNotPresent()
    }
    
    func testReceivingVoidTestResultAfterPositiveSelfDiagnosis() throws {
        // Complete questionnaire with risky symptoms and order test on 1st Jan
        // Symptom onset date: 1st Jan
        // Isolation end date: 11th Jan
        try questionnaire.selfDiagnosePositive(onsetDay: currentDateProvider.currentGregorianDay(timeZone: .utc))
        try testOrdering.order()
        
        advanceToEndOfAnalyticsWindow()
        
        // Current date: 2nd Jan -> Analytics packet for: 1st Jan
        // Now in isolation due to self-diagnosis
        assert(\.completedQuestionnaireAndStartedIsolation).equals(1)
        assert(\.hasSelfDiagnosedPositiveBackgroundTick).isPresent()
        assert(\.isIsolatingBackgroundTick).isPresent()
        assert(\.isIsolatingForSelfDiagnosedBackgroundTick).isPresent()
        
        // Receive negative test result via polling
        try pollingTestResult.receiveVoidAndAcknowledge {
            self.advanceToNextBackgroundTaskExecution()
        }
        
        advanceToEndOfAnalyticsWindow()
        
        // Current date: 3rd Jan -> Analytics packet for: 2nd Jan
        assert(\.receivedVoidTestResult).isPresent()
        assert(\.receivedVoidTestResultViaPolling).isPresent()
        
        // Still isolating
        assert(\.hasSelfDiagnosedPositiveBackgroundTick).isPresent()
        assert(\.isIsolatingBackgroundTick).isPresent()
        assert(\.isIsolatingForSelfDiagnosedBackgroundTick).isPresent()
    }
}
