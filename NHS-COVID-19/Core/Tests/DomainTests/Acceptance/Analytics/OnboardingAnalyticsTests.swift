//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import XCTest
@testable import Domain

@available(iOS 13.7, *)
class OnboardingAnalyticsTests: AnalyticsTests {
    func testOnboardingPacketSentWhenOnboardingCompleted() throws {
        assert(\.completedOnboarding).equals(1)
        XCTAssert(lastMetricsPayload?.analyticsWindow.startDate == lastMetricsPayload?.analyticsWindow.endDate)
    }
}
