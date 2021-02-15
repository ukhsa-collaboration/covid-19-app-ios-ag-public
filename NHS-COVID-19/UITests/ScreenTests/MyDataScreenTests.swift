//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class MyDataScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<MyDataScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = MyDataScreen(app: app)
            XCTAssertTrue(runner.scenario.localAuthority == nil ? screen.postcodeSectionHeader.exists : screen.localAuthoritySectionHeader.exists)
            XCTAssertTrue(screen.postcodeCell(postcode: runner.scenario.postcode).exists)
            XCTAssertTrue(screen.editPostcodeButton.exists)
            XCTAssertTrue(screen.testResultSectionHeader.exists)
            XCTAssertTrue(screen.testResult(testResult: localize(.mydata_test_result_positive)).exists)
            XCTAssertTrue(screen.cellTestKitType(testKitType: localize(.mydata_test_result_lab_result)).exists)
            XCTAssertTrue(screen.cellDate(date: runner.scenario.testResultDate).exists)
            XCTAssertTrue(screen.cellDate(date: runner.scenario.encounterDate).exists)
            XCTAssertTrue(screen.cellDate(date: runner.scenario.symptomsDate).exists)
            
            app.scrollTo(element: screen.deleteDataButton)
            XCTAssertTrue(screen.deleteDataButton.exists)
        }
    }
    
    func testTappingEditPostcode() throws {
        try runner.run { app in
            let screen = MyDataScreen(app: app)
            
            screen.editPostcodeButton.tap()
            XCTAssertTrue(app.staticTexts[verbatim: runner.scenario.didTapEditPostcode].exists)
        }
    }
    
    func testDeletingAllData() throws {
        try runner.run { app in
            let screen = MyDataScreen(app: app)
            
            app.scrollTo(element: screen.deleteDataButton)
            screen.deleteDataButton.tap()
            
            XCTAssertTrue(screen.deleteDataAlertConfirmationButton.exists)
            screen.deleteDataAlertConfirmationButton.tap()
            
            XCTAssertTrue(app.staticTexts[verbatim: runner.scenario.confirmedDeleteAllData].exists)
        }
    }
    
    func testDeleteVenueHistoryUsingSwipeGesture() throws {
        try runner.run { app in
            let screen = MyDataScreen(app: app)
            
            let elementToDelete = app.staticTexts[runner.scenario.venueNameToDelete]
            app.scrollToHittable(element: elementToDelete)
            
            XCTAssertTrue(elementToDelete.displayed)
            
            elementToDelete.swipeLeft()
            
            XCTAssertTrue(screen.cellDeleteButton.exists)
            screen.cellDeleteButton.tap()
            
            XCTAssertTrue(app.staticTexts[runner.scenario.venueID1].existsAndNotEmpty)
            XCTAssertFalse(app.staticTexts[runner.scenario.venueID2ToDelete].existsAndNotEmpty)
            XCTAssertTrue(app.staticTexts[runner.scenario.venueID3].existsAndNotEmpty)
            XCTAssertTrue(app.staticTexts[runner.scenario.venueID4].existsAndNotEmpty)
            XCTAssertTrue(app.staticTexts[runner.scenario.venueID5].existsAndNotEmpty)
            
        }
    }
    
    func testVenueHistoryEditButtonTitleChanges() throws {
        try runner.run { app in
            let screen = MyDataScreen(app: app)
            
            app.scrollTo(element: screen.editVenueHistoryButton)
            XCTAssertTrue(screen.editVenueHistoryButton.exists)
            screen.editVenueHistoryButton.tap()
            
            // Edit button title switched to `Done`
            XCTAssertTrue(screen.doneVenueHistoryButton.exists)
            screen.doneVenueHistoryButton.tap()
            
            // Done button title switched to `Edit`
            XCTAssertTrue(screen.editVenueHistoryButton.exists)
        }
    }
}
