//
// Copyright © 2022 DHSC. All rights reserved.
//

import Foundation
import XCTest
@testable import Domain

@available(iOS 13.7, *)
class SymptomsCheckerAnalyticsTests: AnalyticsTests {

    private var symptomsCheckerManager: SymptomsCheckerManaging!

    override func setUpFunctionalities() {
        symptomsCheckerManager = try! context().symptomsCheckerManager
    }

    func testCountsNumberOfCompletedQuestionnaires() throws {
        symptomsCheckerManager.store(shouldTryToStayAtHome: false)

        assertOnFields { assertField in
            assertField.equals(expected: 1, \.completedV2SymptomsQuestionnaire)
            assertField.equals(expected: 0, \.completedV2SymptomsQuestionnaireAndStayAtHome)
            assertField.isPresent(\.hasCompletedV2SymptomsQuestionnaireBackgroundTick)
        }
    }

    func testCountsNumberOfCompletedQuestionnairesWithResultTryToStayAtHome() throws {
        symptomsCheckerManager.store(shouldTryToStayAtHome: true)

        assertOnFields { assertField in
            assertField.equals(expected: 1, \.completedV2SymptomsQuestionnaire)
            assertField.equals(expected: 1, \.completedV2SymptomsQuestionnaireAndStayAtHome)
            assertField.isPresent(\.hasCompletedV2SymptomsQuestionnaireBackgroundTick)
            assertField.isPresent(\.hasCompletedV2SymptomsQuestionnaireAndStayAtHomeBackgroundTick)
        }
    }
}
