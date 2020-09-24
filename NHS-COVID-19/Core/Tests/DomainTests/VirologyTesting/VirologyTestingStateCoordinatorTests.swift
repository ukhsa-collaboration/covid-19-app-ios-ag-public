//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest
@testable import Domain

class VirologyTestingStateCoordinatorTests: XCTestCase {
    var virologyStore: VirologyTestingStateStore!
    var userNotificationManager: MockUserNotificationsManager!
    var coordinator: VirologyTestingStateCoordinator!
    
    override func setUp() {
        virologyStore = VirologyTestingStateStore(store: MockEncryptedStore())
        userNotificationManager = MockUserNotificationsManager()
        coordinator = VirologyTestingStateCoordinator(
            virologyTestingStateStore: virologyStore,
            userNotificationsManager: userNotificationManager
        )
    }
    
    func testHandleTestResult() throws {
        let result = VirologyTestResult(
            testResult: .positive,
            endDate: Date()
        )
        let response = VirologyTestResponse.receivedResult(result)
        let tokens = VirologyTestTokens(
            pollingToken: PollingToken(value: .random()),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: .random())
        )
        
        coordinator.handleTestResult(response, virologyTestTokens: tokens)
        
        XCTAssertEqual(userNotificationManager.notificationType, UserNotificationType.testResultReceived)
        let savedResult = try XCTUnwrap(virologyStore.relevantUnacknowledgedTestResult)
        XCTAssertEqual(savedResult.testResult, TestResult(result.testResult))
    }
    
    func testHandleLinkTestResult() throws {
        let response = LinkVirologyTestResultResponse(
            virologyTestResult: VirologyTestResult(
                testResult: .positive,
                endDate: Date()
            ),
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: .random())
        )
        coordinator.handleLinkTestResult(response)
        
        XCTAssertNil(userNotificationManager.notificationType)
        let savedResult = try XCTUnwrap(virologyStore.relevantUnacknowledgedTestResult)
        XCTAssertEqual(savedResult.testResult, TestResult(response.virologyTestResult.testResult))
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
