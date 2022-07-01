//
// Copyright © 2022 DHSC. All rights reserved.
//

import Common
import Scenarios
import XCTest
@testable import Domain

class SymptomsCheckerStoreTest: XCTestCase {
    private var encryptedStore: MockEncryptedStore!
    private var symptomsCheckerStore: SymptomsCheckerStore!

    override func setUp() {
        super.setUp()

        encryptedStore = MockEncryptedStore()
        symptomsCheckerStore = SymptomsCheckerStore(store: encryptedStore)
    }

    func testLoadEmptyStore() {
        // By default, lastCompletedSymptomsQuestionnaireDay is nil
        XCTAssertNil(symptomsCheckerStore.lastCompletedSymptomsQuestionnaireDay.currentValue)
    }

    func testSave() throws {
        symptomsCheckerStore.save(lastCompletedSymptomsQuestionnaireDay: .today, toldToStayHome: true)
        XCTAssertNotNil(symptomsCheckerStore.lastCompletedSymptomsQuestionnaireDay.currentValue)
        XCTAssertEqual(symptomsCheckerStore.toldToStayHome.currentValue, true)

        symptomsCheckerStore.save(lastCompletedSymptomsQuestionnaireDay: .today, toldToStayHome: false)
        XCTAssertEqual(symptomsCheckerStore.toldToStayHome.currentValue, false)
    }

    func testDelete() throws {
        symptomsCheckerStore.save(lastCompletedSymptomsQuestionnaireDay: .today, toldToStayHome: true)
        symptomsCheckerStore.delete()
        XCTAssertNil(symptomsCheckerStore.lastCompletedSymptomsQuestionnaireDay.currentValue)
        XCTAssertNil(symptomsCheckerStore.toldToStayHome.currentValue)
    }
}

