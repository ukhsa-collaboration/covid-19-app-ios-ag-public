//
// Copyright © 2022 DHSC. All rights reserved.
//

import XCTest
@testable import Domain

class SymptomCheckerAdviceHandlerTest: XCTestCase {

    let adviceHandler = SymptomCheckerAdviceHandler()

    func testHasNonCardinalAndCardinalSymptomsAndFeelsWell() throws {
        let symptomCheckerQuestions = SymptomCheckerQuestions(
            hasNonCardinalSymptoms: true,
            hasCardinalSymptoms: true,
            isFeelingWell: true
        )

        let expectedResult: SymptomCheckerAdviceResult = .tryToStayAtHome
        let actualResult = adviceHandler.invoke(symptomCheckerQuestions: symptomCheckerQuestions)

        XCTAssertEqual(actualResult, expectedResult)
    }

    func testHasNonCardinalAndCardinalSymptomsButDontFeelsWell() throws {
        let symptomCheckerQuestions = SymptomCheckerQuestions(
            hasNonCardinalSymptoms: true,
            hasCardinalSymptoms: true,
            isFeelingWell: false
        )

        let expectedResult: SymptomCheckerAdviceResult = .tryToStayAtHome
        let actualResult = adviceHandler.invoke(symptomCheckerQuestions: symptomCheckerQuestions)

        XCTAssertEqual(actualResult, expectedResult)
    }

    func testHasNonCardinalSymptomsDontHaveCardinalSymptomsAndFeelsWell() throws {
        let symptomCheckerQuestions = SymptomCheckerQuestions(
            hasNonCardinalSymptoms: true,
            hasCardinalSymptoms: false,
            isFeelingWell: true
        )

        let expectedResult: SymptomCheckerAdviceResult = .continueNormalActivities
        let actualResult = adviceHandler.invoke(symptomCheckerQuestions: symptomCheckerQuestions)

        XCTAssertEqual(actualResult, expectedResult)
    }

    func testHasNonCardinalSymptomsDontHaveCardinalSymptomsButDontFeelsWell() throws {
        let symptomCheckerQuestions = SymptomCheckerQuestions(
            hasNonCardinalSymptoms: true,
            hasCardinalSymptoms: false,
            isFeelingWell: false
        )

        let expectedResult: SymptomCheckerAdviceResult = .tryToStayAtHome
        let actualResult = adviceHandler.invoke(symptomCheckerQuestions: symptomCheckerQuestions)

        XCTAssertEqual(actualResult, expectedResult)
    }

    func testDontHaveNonCardinalSymptomsHaveCardinalSymptomsAndFeelsWell() throws {
        let symptomCheckerQuestions = SymptomCheckerQuestions(
            hasNonCardinalSymptoms: false,
            hasCardinalSymptoms: true,
            isFeelingWell: true
        )

        let expectedResult: SymptomCheckerAdviceResult = .tryToStayAtHome
        let actualResult = adviceHandler.invoke(symptomCheckerQuestions: symptomCheckerQuestions)

        XCTAssertEqual(actualResult, expectedResult)
    }

    func testDontHaveNonCardinalSymptomsHaveCardinalSymptomsButDontFeelsWell() throws {
        let symptomCheckerQuestions = SymptomCheckerQuestions(
            hasNonCardinalSymptoms: false,
            hasCardinalSymptoms: true,
            isFeelingWell: false
        )

        let expectedResult: SymptomCheckerAdviceResult = .tryToStayAtHome
        let actualResult = adviceHandler.invoke(symptomCheckerQuestions: symptomCheckerQuestions)

        XCTAssertEqual(actualResult, expectedResult)
    }

    func testDontHaveNonCardinalSymptomsDontHaveCardinalSymptomsAndFeelsWell() throws {
        let symptomCheckerQuestions = SymptomCheckerQuestions(
            hasNonCardinalSymptoms: false,
            hasCardinalSymptoms: false,
            isFeelingWell: true
        )

        let expectedResult: SymptomCheckerAdviceResult = .continueNormalActivities
        let actualResult = adviceHandler.invoke(symptomCheckerQuestions: symptomCheckerQuestions)

        XCTAssertEqual(actualResult, expectedResult)
    }

    func testDontHaveNonCardinalSymptomsDontHaveCardinalSymptomsButDontFeelsWell() throws {
        let symptomCheckerQuestions = SymptomCheckerQuestions(
            hasNonCardinalSymptoms: false,
            hasCardinalSymptoms: false,
            isFeelingWell: false
        )

        let expectedResult: SymptomCheckerAdviceResult = .tryToStayAtHome
        let actualResult = adviceHandler.invoke(symptomCheckerQuestions: symptomCheckerQuestions)

        XCTAssertEqual(actualResult, expectedResult)
    }
}
