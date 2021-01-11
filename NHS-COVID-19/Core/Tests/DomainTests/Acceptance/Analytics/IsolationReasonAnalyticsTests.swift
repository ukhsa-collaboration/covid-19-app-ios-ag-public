//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import XCTest
@testable import Domain
@testable import Scenarios

@available(iOS 13.7, *)
class IsolationReasonAnalyticsTests: AnalyticsTests {
    private var questionnaire: Questionnaire!
    private var riskyContact: RiskyContact!
    
    override func setUpFunctionalities() {
        questionnaire = Questionnaire(context: try! context())
        riskyContact = RiskyContact(configuration: $instance)
    }
    
    // hasSelfDiagnosedBackgroundTick
    // >0 if the app is aware that the user has completed the questionnaire with symptoms
    // this currently happens during an isolation and for the 14 days after isolation.
    func testHasSelfDiagnosedBackgroundTickIsPresentWhenCompletedQuestionnaireAndFor14DaysAfterIsolation() throws {
        // Current date: 1st Jan
        // Starting state: App running normally, not in isolation
        advanceToEndOfAnalyticsWindow()
        // Current date: 2nd Jan -> Analytics packet for: 1st Jan
        assert(\.hasSelfDiagnosedBackgroundTick).isNotPresent()
        assert(\.isIsolatingBackgroundTick).isNotPresent()
        
        // Complete questionnaire with risky symptoms on 2nd Jan
        // Symptom onset date: 2nd Jan
        // Isolation end date: 12th Jan
        try questionnaire.selfDiagnosePositive(onsetDay: currentDateProvider.currentGregorianDay(timeZone: .utc))
        
        advanceToEndOfAnalyticsWindow()
        // Current date: 3rd Jan -> Analytics packet for: 2nd Jan
        // Now in isolation due to self-diagnosis
        assert(\.completedQuestionnaireAndStartedIsolation).equals(1)
        assert(\.isIsolatingBackgroundTick).isPresent()
        assert(\.hasSelfDiagnosedBackgroundTick).isPresent()
        
        // Dates: 4th-13th Jan -> Analytics packets for: 3rd-12th Jan
        // Still in isolation
        for _ in 4 ... 13 {
            advanceToEndOfAnalyticsWindow()
            assert(\.completedQuestionnaireAndStartedIsolation).isNotPresent()
            assert(\.isIsolatingBackgroundTick).isPresent()
            assert(\.isIsolatingForSelfDiagnosedBackgroundTick).isPresent()
            assert(\.hasSelfDiagnosedBackgroundTick).isPresent()
        }
        
        // Dates: 14th-27th Jan -> Analytics packets for: 13th-26th Jan
        // Isolation is over, but isolation reason still stored for 14 days
        for _ in 14 ... 27 {
            advanceToEndOfAnalyticsWindow()
            assert(\.isIsolatingBackgroundTick).isNotPresent()
            assert(\.isIsolatingForSelfDiagnosedBackgroundTick).isNotPresent()
            assert(\.hasSelfDiagnosedBackgroundTick).isPresent()
        }
        
        advanceToEndOfAnalyticsWindow()
        // Current date: 27th Jan -> Analytics packet for: 26th Jan
        // Previous isolation reason no longer stored
        assert(\.isIsolatingBackgroundTick).isNotPresent()
        assert(\.isIsolatingForSelfDiagnosedBackgroundTick).isNotPresent()
        assert(\.hasSelfDiagnosedBackgroundTick).isNotPresent()
    }
    
    // hasHadRiskyContactBackgroundTick
    // >0 if the app is aware that the user has had a risky contact
    // this currently happens during an isolation and for the 14 days after isolation
    func testHasHadRiskyContactBackgroundTickIsPresentWhenIsolatingAndFor14DaysAfter() throws {
        // Current date: 1st Jan
        // Starting state: App running normally, not in isolation
        advanceToEndOfAnalyticsWindow()
        // Current date: 2nd Jan -> Analytics packet for: 1st Jan
        assert(\.hasSelfDiagnosedBackgroundTick).isNotPresent()
        assert(\.isIsolatingBackgroundTick).isNotPresent()
        assert(\.isIsolatingForHadRiskyContactBackgroundTick).isNotPresent()
        
        // Has risky contact on 2nd Jan
        // Isolation end date: 13th Jan
        riskyContact.trigger(exposureDate: currentDateProvider.currentDate) {
            self.advanceToEndOfAnalyticsWindow()
        }
        
        // Current date: 3rd Jan -> Analytics packet for: 2nd Jan
        // Now in isolation due to risky contact
        assert(\.isIsolatingBackgroundTick).isPresent()
        assert(\.isIsolatingForHadRiskyContactBackgroundTick).isPresent()
        assert(\.hasHadRiskyContactBackgroundTick).isPresent()
        
        // Dates: 5th-13th Jan -> Analytics packets for: 4rd-12th Jan
        // Still in isolation
        for _ in 5 ... 14 {
            advanceToEndOfAnalyticsWindow()
            assert(\.isIsolatingBackgroundTick).isPresent()
            assert(\.isIsolatingForHadRiskyContactBackgroundTick).isPresent()
            assert(\.hasHadRiskyContactBackgroundTick).isPresent()
        }
        
        // Dates: 14th-27th Jan -> Analytics packets for: 13th-26th Jan
        // Isolation is over, but isolation reason still stored for 14 days
        for _ in 15 ... 28 {
            advanceToEndOfAnalyticsWindow()
            assert(\.hasHadRiskyContactBackgroundTick).isPresent()
        }
        
        advanceToEndOfAnalyticsWindow()
        // Current date: 31st Jan -> Analytics packet for: 30th Jan
        // Previous isolation reason no longer stored
        assert(\.isIsolatingBackgroundTick).isNotPresent()
        assert(\.isIsolatingForHadRiskyContactBackgroundTick).isNotPresent()
        assert(\.hasHadRiskyContactBackgroundTick).isNotPresent()
    }
}
