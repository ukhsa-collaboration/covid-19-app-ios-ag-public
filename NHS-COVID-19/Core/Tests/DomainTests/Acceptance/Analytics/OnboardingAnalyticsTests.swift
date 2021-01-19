//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import XCTest
@testable import Domain

@available(iOS 13.7, *)
class OnboardingAnalyticsTests: AnalyticsTests {
    func testOnboardingPacketSentWhenOnboardingCompleted() throws {
        
        assertOnLastFields { assertField in
            assertField.equals(expected: 1, \.completedOnboarding)
        }
        
        XCTAssert(lastMetricsPayload?.analyticsWindow.startDate == lastMetricsPayload?.analyticsWindow.endDate)
    }
}
