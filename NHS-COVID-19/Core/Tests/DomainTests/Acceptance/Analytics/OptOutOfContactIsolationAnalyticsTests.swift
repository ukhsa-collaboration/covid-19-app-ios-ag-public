//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import XCTest
@testable import Domain

@available(iOS 13.7, *)
class OptOutOfContactIsolationAnalyticsTests: AnalyticsTests {
    private var riskyContact: RiskyContact!

    override func setUpFunctionalities() {
        riskyContact = RiskyContact(configuration: $instance)
    }

    // hasHadRiskyContactBackgroundTick
    // >0 if the app is aware that the user has had a risky contact
    // this currently happens during an isolation and for the 14 days after isolation
    func testHasHadRiskyContactBackgroundTickIsPresentWhenIsolatingAndFor14DaysAfter() throws {
        // Starting state: App running normally, not in isolation
        // Current date: 2nd Jan -> Analytics packet for: 1st Jan
        assertAnalyticsPacketIsNormal()

        // Has risky contact on 2nd Jan
        riskyContact.trigger(exposureDate: currentDateProvider.currentDate) {
            self.assertOnFields { assertField in
                // Current date: 3rd Jan -> Analytics packet for: 2nd Jan
                // Now in isolation due to risky contact
                assertField.equals(expected: 1, \.startedIsolation)
                assertField.equals(expected: 1, \.receivedRiskyContactNotification)
                assertField.isPresent(\.isIsolatingBackgroundTick)
                assertField.isPresent(\.isIsolatingForHadRiskyContactBackgroundTick)
                assertField.isNil(\.hasHadRiskyContactBackgroundTick)
            }
        }

        // Opt-Out on 3rd Jan from contact isolation
        if case .neededForStartContactIsolation(_, let acknowledge) = try context().isolationAcknowledgementState.await().get() {
            acknowledge(true)
        }

        assertOnFields { assertField in
            // Current date: 4th Jan -> Analytics packet for: 3rd Jan
            assertField.isPresent(\.optedOutForContactIsolation)
            assertField.isPresent(\.optedOutForContactIsolationBackgroundTick)
            assertField.isNil(\.hasHadRiskyContactBackgroundTick)
            assertField.isPresent(\.acknowledgedStartOfIsolationDueToRiskyContact)
        }

        // Dates: 5th-16th Jan -> Analytics packets for: 4th-15th Jan
        // Isolation is over, but isolation reason and opt-out flag still stored for 14 days
        assertOnFieldsForDateRange(dateRange: 4 ... 15) { assertField in
            assertField.isPresent(\.optedOutForContactIsolationBackgroundTick)
            assertField.isNil(\.hasHadRiskyContactBackgroundTick)
        }

        // Current date: 17th Jan -> Analytics packet for: 16th Jan
        // Previous isolation reason no longer stored
        assertAnalyticsPacketIsNormal()
    }
}
