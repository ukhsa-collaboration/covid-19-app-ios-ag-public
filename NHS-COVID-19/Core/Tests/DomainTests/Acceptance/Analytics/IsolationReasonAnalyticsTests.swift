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
        // Starting state: App running normally, not in isolation
        // Current date: 2nd Jan -> Analytics packet for: 1st Jan
        assertAnalyticsPacketIsNormal()
        
        // Complete questionnaire with risky symptoms on 2nd Jan
        // Symptom onset date: 2nd Jan
        // Isolation end date: 12th Jan
        try questionnaire.selfDiagnosePositive(onsetDay: currentDateProvider.currentGregorianDay(timeZone: .utc))
        
        // Current date: 3rd Jan -> Analytics packet for: 2nd Jan
        // Now in isolation due to self-diagnosis
        assertOnFields { assertField in
            assertField.equals(expected: 1, \.completedQuestionnaireAndStartedIsolation)
            assertField.equals(expected: 1, \.startedIsolation)
            assertField.isPresent(\.isIsolatingBackgroundTick)
            assertField.isPresent(\.hasSelfDiagnosedBackgroundTick)
            assertField.isPresent(\.isIsolatingForSelfDiagnosedBackgroundTick)
        }
        
        // Dates: 4th-13th Jan -> Analytics packets for: 3rd-12th Jan
        // Still in isolation
        assertOnFieldsForDateRange(dateRange: 4 ... 13) { assertField in
            assertField.isPresent(\.isIsolatingBackgroundTick)
            assertField.isPresent(\.isIsolatingForSelfDiagnosedBackgroundTick)
            assertField.isPresent(\.hasSelfDiagnosedBackgroundTick)
        }
        
        // Dates: 14th-27th Jan -> Analytics packets for: 13th-26th Jan
        // Isolation is over, but isolation reason still stored for 14 days
        assertOnFieldsForDateRange(dateRange: 14 ... 27) { assertField in
            assertField.isPresent(\.hasSelfDiagnosedBackgroundTick)
        }
        
        // Current date: 27th Jan -> Analytics packet for: 26th Jan
        // Previous isolation reason no longer stored
        assertAnalyticsPacketIsNormal()
    }
    
    // hasHadRiskyContactBackgroundTick
    // >0 if the app is aware that the user has had a risky contact
    // this currently happens during an isolation and for the 14 days after isolation
    func testHasHadRiskyContactBackgroundTickIsPresentWhenIsolatingAndFor14DaysAfter() throws {
        // Starting state: App running normally, not in isolation
        // Current date: 2nd Jan -> Analytics packet for: 1st Jan
        assertAnalyticsPacketIsNormal()
        
        // Has risky contact on 2nd Jan
        // Isolation end date: 13th Jan
        riskyContact.trigger(exposureDate: currentDateProvider.currentDate) {
            self.assertOnFields { assertField in
                // Current date: 3rd Jan -> Analytics packet for: 2nd Jan
                // Now in isolation due to risky contact
                assertField.equals(expected: 1, \.startedIsolation)
                assertField.equals(expected: 1, \.receivedRiskyContactNotification)
                assertField.isPresent(\.isIsolatingBackgroundTick)
                assertField.isPresent(\.isIsolatingForHadRiskyContactBackgroundTick)
                assertField.isPresent(\.hasHadRiskyContactBackgroundTick)
            }
        }
        
        // Has another risky contact on 3rd Jan as already isolating
        // This should not increment the "new isolation" fields agains
        riskyContact.trigger(exposureDate: currentDateProvider.currentDate) {
            self.assertOnFields { assertField in
                assertField.isPresent(\.isIsolatingBackgroundTick)
                assertField.isPresent(\.isIsolatingForHadRiskyContactBackgroundTick)
                assertField.isPresent(\.hasHadRiskyContactBackgroundTick)
            }
        }
        
        // Dates: 5th-13th Jan -> Analytics packets for: 4rd-12th Jan
        // Still in isolation
        assertOnFieldsForDateRange(dateRange: 5 ... 13) { assertField in
            assertField.isPresent(\.isIsolatingBackgroundTick)
            assertField.isPresent(\.isIsolatingForHadRiskyContactBackgroundTick)
            assertField.isPresent(\.hasHadRiskyContactBackgroundTick)
        }
        
        // Dates: 14th-27th Jan -> Analytics packets for: 13th-26th Jan
        // Isolation is over, but isolation reason still stored for 14 days
        assertOnFieldsForDateRange(dateRange: 14 ... 27) { assertField in
            assertField.isPresent(\.hasHadRiskyContactBackgroundTick)
        }
        
        // Current date: 29th Jan -> Analytics packet for: 28th Jan
        // Previous isolation reason no longer stored
        assertAnalyticsPacketIsNormal()
    }
    
    func testIsolationReasonInteractionWithSelfDiagnosisAfterRiskyContact() throws {
        // Starting state: App running normally, not in isolation
        // Current date: 2nd Jan -> Analytics packet for: 1st Jan
        assertAnalyticsPacketIsNormal()
        
        // Has risky contact on 2nd Jan
        // Isolation end date: 16th Jan
        riskyContact.trigger(exposureDate: currentDateProvider.currentDate) {
            self.assertOnFields { assertField in
                // Current date: 3rd Jan -> Analytics packet for: 2nd Jan
                // Now in isolation due to risky contact
                assertField.equals(expected: 1, \.startedIsolation)
                assertField.equals(expected: 1, \.receivedRiskyContactNotification)
                assertField.isPresent(\.isIsolatingBackgroundTick)
                assertField.isPresent(\.isIsolatingForHadRiskyContactBackgroundTick)
                assertField.isPresent(\.hasHadRiskyContactBackgroundTick)
            }
        }
        
        try questionnaire.selfDiagnosePositive(onsetDay: currentDateProvider.currentGregorianDay(timeZone: .utc))
        
        // This should not increment the "new isolation" fields agains
        assertOnFields { assertField in
            assertField.equals(expected: 1, \.completedQuestionnaireAndStartedIsolation)
            assertField.isPresent(\.isIsolatingBackgroundTick)
            assertField.isPresent(\.isIsolatingForHadRiskyContactBackgroundTick)
            assertField.isPresent(\.isIsolatingForSelfDiagnosedBackgroundTick)
            assertField.isPresent(\.hasHadRiskyContactBackgroundTick)
            assertField.isPresent(\.hasSelfDiagnosedPositiveBackgroundTick)
            assertField.isPresent(\.hasSelfDiagnosedBackgroundTick)
        }
        
        // Still in isolation for both reasons
        assertOnFieldsForDateRange(dateRange: 5 ... 13) { assertField in
            assertField.isPresent(\.isIsolatingBackgroundTick)
            assertField.isPresent(\.isIsolatingForHadRiskyContactBackgroundTick)
            assertField.isPresent(\.isIsolatingForSelfDiagnosedBackgroundTick)
            assertField.isPresent(\.hasHadRiskyContactBackgroundTick)
            assertField.isPresent(\.hasSelfDiagnosedPositiveBackgroundTick)
            assertField.isPresent(\.hasSelfDiagnosedBackgroundTick)
        }
        
        // Still in isolation because self-diagnosed with symptoms
        assertOnFieldsForDateRange(dateRange: 14 ... 14) { assertField in
            assertField.isPresent(\.isIsolatingBackgroundTick)
            assertField.isPresent(\.isIsolatingForSelfDiagnosedBackgroundTick)
            assertField.isPresent(\.hasHadRiskyContactBackgroundTick)
            assertField.isPresent(\.hasSelfDiagnosedPositiveBackgroundTick)
            assertField.isPresent(\.hasSelfDiagnosedBackgroundTick)
        }
        
        // Isolation is over, but isolation reason still stored for 14 days
        assertOnFieldsForDateRange(dateRange: 15 ... 28) { assertField in
            assertField.isPresent(\.hasHadRiskyContactBackgroundTick)
            assertField.isPresent(\.hasSelfDiagnosedPositiveBackgroundTick)
            assertField.isPresent(\.hasSelfDiagnosedBackgroundTick)
        }
        
        // Previous isolation reason no longer stored
        assertAnalyticsPacketIsNormal()
    }
    
    func testIsolationReasonInteractionWithRiskyContactAfterSelfDiagnosis() throws {
        // Starting state: App running normally, not in isolation
        // Current date: 2nd Jan -> Analytics packet for: 1st Jan
        assertAnalyticsPacketIsNormal()
        
        try questionnaire.selfDiagnosePositive(onsetDay: currentDateProvider.currentGregorianDay(timeZone: .utc))
        
        // This should not increment the "new isolation" fields agains
        assertOnFields { assertField in
            assertField.equals(expected: 1, \.startedIsolation)
            assertField.equals(expected: 1, \.completedQuestionnaireAndStartedIsolation)
            assertField.isPresent(\.isIsolatingBackgroundTick)
            assertField.isPresent(\.isIsolatingForSelfDiagnosedBackgroundTick)
            assertField.isPresent(\.hasSelfDiagnosedPositiveBackgroundTick)
            assertField.isPresent(\.hasSelfDiagnosedBackgroundTick)
        }
        
        // Has risky contact on 2nd Jan
        // Isolation end date: 13th Jan
        riskyContact.trigger(exposureDate: currentDateProvider.currentDate) {
            self.assertOnFields { assertField in
                // Current date: 3rd Jan -> Analytics packet for: 2nd Jan
                // Now in isolation due to risky contact
                assertField.equals(expected: 1, \.receivedRiskyContactNotification)
                assertField.isPresent(\.isIsolatingBackgroundTick)
                assertField.isPresent(\.isIsolatingForHadRiskyContactBackgroundTick)
                assertField.isPresent(\.isIsolatingForSelfDiagnosedBackgroundTick)
                assertField.isPresent(\.hasHadRiskyContactBackgroundTick)
                assertField.isPresent(\.hasSelfDiagnosedPositiveBackgroundTick)
                assertField.isPresent(\.hasSelfDiagnosedBackgroundTick)
            }
        }
        
        // Still in isolation for both reasons
        assertOnFieldsForDateRange(dateRange: 5 ... 13) { assertField in
            assertField.isPresent(\.isIsolatingBackgroundTick)
            assertField.isPresent(\.isIsolatingForHadRiskyContactBackgroundTick)
            assertField.isPresent(\.isIsolatingForSelfDiagnosedBackgroundTick)
            assertField.isPresent(\.hasHadRiskyContactBackgroundTick)
            assertField.isPresent(\.hasSelfDiagnosedPositiveBackgroundTick)
            assertField.isPresent(\.hasSelfDiagnosedBackgroundTick)
        }
        
        // Still in isolation for because of the risky contact
        assertOnFieldsForDateRange(dateRange: 14 ... 14) { assertField in
            assertField.isPresent(\.isIsolatingBackgroundTick)
            assertField.isPresent(\.isIsolatingForHadRiskyContactBackgroundTick)
            assertField.isPresent(\.hasHadRiskyContactBackgroundTick)
            assertField.isPresent(\.hasSelfDiagnosedPositiveBackgroundTick)
            assertField.isPresent(\.hasSelfDiagnosedBackgroundTick)
        }
        
        // Isolation is over, but isolation reason still stored for 14 days
        assertOnFieldsForDateRange(dateRange: 15 ... 28) { assertField in
            assertField.isPresent(\.hasHadRiskyContactBackgroundTick)
            assertField.isPresent(\.hasSelfDiagnosedPositiveBackgroundTick)
            assertField.isPresent(\.hasSelfDiagnosedBackgroundTick)
        }
        
        // Previous isolation reason no longer stored
        assertAnalyticsPacketIsNormal()
    }
}
