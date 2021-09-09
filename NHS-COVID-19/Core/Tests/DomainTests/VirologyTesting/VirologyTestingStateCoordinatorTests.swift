//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Scenarios
import TestSupport
import XCTest
@testable import Domain

class VirologyTestingStateCoordinatorTests: XCTestCase {
    var virologyStore: VirologyTestingStateStore!
    var userNotificationManager: MockUserNotificationsManager!
    var coordinator: VirologyTestingStateCoordinator!
    var isInterestedInAskingForSymptomsOnsetDay: Bool = true
    
    override func setUp() {
        virologyStore = VirologyTestingStateStore(
            store: MockEncryptedStore(),
            dateProvider: MockDateProvider()
        )
        userNotificationManager = MockUserNotificationsManager()
        coordinator = VirologyTestingStateCoordinator(
            virologyTestingStateStore: virologyStore,
            userNotificationsManager: userNotificationManager,
            isInterestedInAskingForSymptomsOnsetDay: {
                self.isInterestedInAskingForSymptomsOnsetDay
            },
            setRequiresOnsetDay: {}
        )
    }
    
    func testHandlePollingTestResult() throws {
        let result = VirologyTestResult(
            testResult: .positive,
            testKitType: .labResult,
            endDate: Date()
        )
        let response = VirologyTestResponse.receivedResult(
            PollVirologyTestResultResponse(
                virologyTestResult: result,
                diagnosisKeySubmissionSupport: true,
                requiresConfirmatoryTest: false
            )
        )
        let tokens = VirologyTestTokens(
            pollingToken: PollingToken(value: .random()),
            creationDay: .today,
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: .random())
        )
        
        coordinator.handlePollingTestResult(response, virologyTestTokens: tokens)
        
        XCTAssertEqual(userNotificationManager.notificationType, UserNotificationType.testResultReceived)
        let savedResult = try XCTUnwrap(virologyStore.virologyTestResult.currentValue)
        XCTAssertEqual(savedResult.testResult, result.testResult)
    }
    
    func testHandleManualTestResult() throws {
        let response = LinkVirologyTestResultResponse(
            virologyTestResult: VirologyTestResult(
                testResult: .positive,
                testKitType: .labResult,
                endDate: Date()
            ),
            diagnosisKeySubmissionSupport: .supported(diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: .random())),
            requiresConfirmatoryTest: false
        )
        coordinator.handleManualTestResult(response)
        
        XCTAssertNil(userNotificationManager.notificationType)
        let savedResult = try XCTUnwrap(virologyStore.virologyTestResult.currentValue)
        XCTAssertEqual(savedResult.testResult, response.virologyTestResult.testResult)
    }
    
    func testDoesNotRequireToAskForSymptomsOnsetDayTestResultRequiresConfirmatoryTest() {
        let virologyTestResult = VirologyTestResult(
            testResult: .positive,
            testKitType: .labResult,
            endDate: Date()
        )
        
        XCTAssertFalse(coordinator.requiresOnsetDay(virologyTestResult, requiresConfirmatoryTest: true))
    }
    
    func testDoesNotRequireToAskForSymptomsOnsetDayTestResultNegative() {
        let virologyTestResult = VirologyTestResult(
            testResult: .negative,
            testKitType: .labResult,
            endDate: Date()
        )
        
        XCTAssertFalse(coordinator.requiresOnsetDay(virologyTestResult, requiresConfirmatoryTest: false))
    }
    
    func testDoesNotRequireToAskForSymptomsOnsetDayIsNotInterestedInAskingForSymptomsOnsetDay() {
        let virologyTestResult = VirologyTestResult(
            testResult: .positive,
            testKitType: .labResult,
            endDate: Date()
        )
        
        isInterestedInAskingForSymptomsOnsetDay = false
        
        XCTAssertFalse(coordinator.requiresOnsetDay(virologyTestResult, requiresConfirmatoryTest: false))
    }
    
    func testRequireToAskForSymptomsOnsetDay() {
        let virologyTestResult = VirologyTestResult(
            testResult: .positive,
            testKitType: .labResult,
            endDate: Date()
        )
        
        XCTAssertTrue(coordinator.requiresOnsetDay(virologyTestResult, requiresConfirmatoryTest: false))
    }
    
    func testHandleSaveOrderTestKitResponseTests() throws {
        let response = OrderTestkitResponse(
            testOrderWebsite: .random(),
            referenceCode: ReferenceCode(value: .random()),
            testResultPollingToken: PollingToken(value: .random()),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: .random())
        )
        coordinator.saveOrderTestKitResponse(response)
        
        let savedTokens = try XCTUnwrap(virologyStore?.virologyTestTokens?.first)
        XCTAssertEqual(savedTokens.diagnosisKeySubmissionToken, response.diagnosisKeySubmissionToken)
        XCTAssertEqual(savedTokens.pollingToken, response.testResultPollingToken)
    }
}
