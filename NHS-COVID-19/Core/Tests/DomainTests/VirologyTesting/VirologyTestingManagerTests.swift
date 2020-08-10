//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Scenarios
import XCTest
@testable import Domain

class VirologyTestingManagerTests: XCTestCase {
    private var mockServer: MockHTTPClient!
    private var virologyStore: VirologyTestingStateStore!
    private var manager: VirologyTestingManager!
    private var notificationManager: MockUserNotificationsManager!
    
    private var isolationStateUpdate: TestResult?
    private var testResultReceivedDay: GregorianDay?
    
    override func setUp() {
        mockServer = MockHTTPClient()
        virologyStore = VirologyTestingStateStore(store: MockEncryptedStore())
        notificationManager = MockUserNotificationsManager()
        isolationStateUpdate = nil
        manager = VirologyTestingManager(
            httpClient: mockServer,
            virologyTestingStateStore: virologyStore,
            userNotificationsManager: notificationManager,
            updateIsolationState: {
                self.isolationStateUpdate = $0
                self.testResultReceivedDay = $1
            }
        )
    }
    
    func testOrderTestkit() throws {
        _ = manager.orderTestkit()
        XCTAssertEqual(mockServer.amountOfCalls, 1)
    }
    
    func testSaveOrderTestkitResponse() throws {
        let testOrderWebsite = URL.random()
        let referenceCode = ReferenceCode(value: .random())
        let pollingToken = PollingToken(value: .random())
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        let response = OrderTestkitResponse(
            testOrderWebsite: testOrderWebsite,
            referenceCode: referenceCode,
            testResultPollingToken: pollingToken,
            diagnosisKeySubmissionToken: submissionToken
        )
        
        manager.saveOrderTestKitResponse(response)
        
        let savedTestTokens = try XCTUnwrap(virologyStore.virologyTestTokens?.first)
        XCTAssertEqual(pollingToken, savedTestTokens.pollingToken)
        XCTAssertEqual(submissionToken, savedTestTokens.diagnosisKeySubmissionToken)
    }
    
    func testEvaluateTestResultsWithResult() throws {
        let pollingToken = PollingToken(value: .random())
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        virologyStore.saveTest(pollingToken: pollingToken, diagnosisKeySubmissionToken: submissionToken)
        virologyStore.saveTest(pollingToken: pollingToken, diagnosisKeySubmissionToken: submissionToken)
        virologyStore.saveTest(pollingToken: pollingToken, diagnosisKeySubmissionToken: submissionToken)
        
        let testDay = GregorianDay.today
        mockServer.response = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "2020-04-23T00:00:00.0000000Z",
            "testResult": "POSITIVE"
        }
        """#))
        
        _ = try manager.evaulateTestResults().await().get()
        XCTAssertEqual(mockServer.amountOfCalls, 3)
        let storedTokens = try XCTUnwrap(virologyStore.virologyTestTokens)
        XCTAssertEqual(storedTokens.count, 0)
        XCTAssertEqual(isolationStateUpdate, TestResult.positive)
        XCTAssertEqual(testResultReceivedDay, testDay)
    }
    
    func testEvaluateTestResultsWithoutResult() throws {
        let pollingToken = PollingToken(value: .random())
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        virologyStore.saveTest(pollingToken: pollingToken, diagnosisKeySubmissionToken: submissionToken)
        virologyStore.saveTest(pollingToken: pollingToken, diagnosisKeySubmissionToken: submissionToken)
        virologyStore.saveTest(pollingToken: pollingToken, diagnosisKeySubmissionToken: submissionToken)
        
        mockServer.response = HTTPResponse.noContent(with: .json(""))
        
        _ = try manager.evaulateTestResults().await().get()
        XCTAssertEqual(mockServer.amountOfCalls, 3)
        let storedTokens = try XCTUnwrap(virologyStore.virologyTestTokens)
        XCTAssertEqual(storedTokens.count, 3)
        XCTAssertNil(notificationManager.notificationType)
    }
    
    func testEvaluateTestResultsPositive() throws {
        let pollingToken = PollingToken(value: .random())
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        virologyStore.saveTest(pollingToken: pollingToken, diagnosisKeySubmissionToken: submissionToken)
        
        let testDay = GregorianDay.today
        mockServer.response = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "2020-04-23T00:00:00.0000000Z",
            "testResult": "POSITIVE"
        }
        """#))
        
        _ = try manager.evaulateTestResults().await().get()
        XCTAssertEqual(notificationManager.notificationType, UserNotificationType.testResultReceived)
        let storedResult = try XCTUnwrap(virologyStore.latestUnacknowledgedTestResult)
        XCTAssertEqual(storedResult.testResult, TestResult.positive)
        XCTAssertEqual(storedResult.diagnosisKeySubmissionToken, submissionToken)
        let storedTokens = try XCTUnwrap(virologyStore.virologyTestTokens)
        XCTAssertEqual(storedTokens.count, 0)
        XCTAssertEqual(isolationStateUpdate, TestResult.positive)
        XCTAssertEqual(testResultReceivedDay, testDay)
    }
    
    func testEvaluateTestResultsNegative() throws {
        let pollingToken = PollingToken(value: .random())
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        virologyStore.saveTest(pollingToken: pollingToken, diagnosisKeySubmissionToken: submissionToken)
        
        let testDay = GregorianDay.today
        mockServer.response = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "2020-04-23T00:00:00.0000000Z",
            "testResult": "NEGATIVE"
        }
        """#))
        
        _ = try manager.evaulateTestResults().await().get()
        XCTAssertEqual(notificationManager.notificationType, UserNotificationType.testResultReceived)
        let storedResult = try XCTUnwrap(virologyStore.latestUnacknowledgedTestResult)
        XCTAssertEqual(storedResult.testResult, TestResult.negative)
        XCTAssertNil(storedResult.diagnosisKeySubmissionToken)
        let storedTokens = try XCTUnwrap(virologyStore.virologyTestTokens)
        XCTAssertEqual(storedTokens.count, 0)
        XCTAssertEqual(isolationStateUpdate, TestResult.negative)
        XCTAssertEqual(testResultReceivedDay, testDay)
    }
    
    func testEvaluateTestResultsVoid() throws {
        let pollingToken = PollingToken(value: .random())
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        virologyStore.saveTest(pollingToken: pollingToken, diagnosisKeySubmissionToken: submissionToken)
        
        mockServer.response = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "2020-04-23T00:00:00.0000000Z",
            "testResult": "VOID"
        }
        """#))
        
        _ = try manager.evaulateTestResults().await().get()
        XCTAssertNil(notificationManager.notificationType)
        XCTAssertNil(virologyStore.latestUnacknowledgedTestResult)
        let storedTokens = try XCTUnwrap(virologyStore.virologyTestTokens)
        XCTAssertEqual(storedTokens.count, 0)
        XCTAssertNil(isolationStateUpdate)
        XCTAssertNil(testResultReceivedDay)
    }
    
    private class MockHTTPClient: HTTPClient {
        var amountOfCalls = 0
        var response: HTTPResponse?
        
        func perform(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, HTTPRequestError> {
            amountOfCalls += 1
            
            if let response = response {
                return Result.success(response).publisher.eraseToAnyPublisher()
            } else {
                return Empty().eraseToAnyPublisher()
            }
            
        }
    }
}
