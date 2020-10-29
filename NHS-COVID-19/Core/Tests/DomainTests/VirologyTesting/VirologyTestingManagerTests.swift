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
    private var validator: MockCTATokenValidator!
    
    override func setUp() {
        mockServer = MockHTTPClient()
        virologyStore = VirologyTestingStateStore(store: MockEncryptedStore())
        notificationManager = MockUserNotificationsManager()
        validator = MockCTATokenValidator()
        manager = VirologyTestingManager(
            httpClient: mockServer,
            virologyTestingStateCoordinator: VirologyTestingStateCoordinator(
                virologyTestingStateStore: virologyStore,
                userNotificationsManager: notificationManager
            ),
            ctaTokenValidator: validator
        )
    }
    
    func testOrderTestkit() throws {
        _ = manager.provideTestOrderInfo()
        XCTAssertEqual(mockServer.amountOfCalls, 1)
    }
    
    func testSaveOrderTestkitResponse() throws {
        let testOrderWebsite = URL.random()
        let referenceCode = ReferenceCode(value: .random())
        let pollingToken = PollingToken(value: .random())
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        let expectedResponse = OrderTestkitResponse(
            testOrderWebsite: testOrderWebsite,
            referenceCode: referenceCode,
            testResultPollingToken: pollingToken,
            diagnosisKeySubmissionToken: submissionToken
        )
        
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "websiteUrlWithQuery": "\#(expectedResponse.testOrderWebsite.absoluteString)",
            "tokenParameterValue": "\#(expectedResponse.referenceCode.value)",
            "testResultPollingToken" : "\#(expectedResponse.testResultPollingToken.value)",
            "diagnosisKeySubmissionToken": "\#(expectedResponse.diagnosisKeySubmissionToken.value)"
        }
        """#))
        
        mockServer.response = response
        
        _ = try manager.provideTestOrderInfo().await().get()
        
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
        
        mockServer.response = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "2020-04-23T00:00:00.0000000Z",
            "testResult": "POSITIVE"
        }
        """#))
        
        _ = try manager.evaulateTestResults().await().get()
        XCTAssertEqual(notificationManager.notificationType, UserNotificationType.testResultReceived)
        let storedResult = try XCTUnwrap(virologyStore.relevantUnacknowledgedTestResult)
        XCTAssertEqual(storedResult.testResult, TestResult.positive)
        XCTAssertEqual(storedResult.diagnosisKeySubmissionToken, submissionToken)
        let storedTokens = try XCTUnwrap(virologyStore.virologyTestTokens)
        XCTAssertEqual(storedTokens.count, 0)
    }
    
    func testEvaluateTestResultsNegative() throws {
        let pollingToken = PollingToken(value: .random())
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        virologyStore.saveTest(pollingToken: pollingToken, diagnosisKeySubmissionToken: submissionToken)
        
        mockServer.response = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "2020-04-23T00:00:00.0000000Z",
            "testResult": "NEGATIVE"
        }
        """#))
        
        _ = try manager.evaulateTestResults().await().get()
        XCTAssertEqual(notificationManager.notificationType, UserNotificationType.testResultReceived)
        let storedResult = try XCTUnwrap(virologyStore.relevantUnacknowledgedTestResult)
        XCTAssertEqual(storedResult.testResult, TestResult.negative)
        XCTAssertNil(storedResult.diagnosisKeySubmissionToken)
        let storedTokens = try XCTUnwrap(virologyStore.virologyTestTokens)
        XCTAssertEqual(storedTokens.count, 0)
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
        XCTAssertEqual(notificationManager.notificationType, UserNotificationType.testResultReceived)
        let storedResult = try XCTUnwrap(virologyStore.relevantUnacknowledgedTestResult)
        XCTAssertEqual(storedResult.testResult, TestResult.void)
        XCTAssertNil(storedResult.diagnosisKeySubmissionToken)
        let storedTokens = try XCTUnwrap(virologyStore.virologyTestTokens)
        XCTAssertEqual(storedTokens.count, 0)
    }
    
    func testEvaluateLinkTestResultsPositive() throws {
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        let ctaToken = String.random()
        
        mockServer.response = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "2020-04-23T00:00:00.0000000Z",
            "testResult": "POSITIVE",
            "diagnosisKeySubmissionToken": "\#(submissionToken.value)",
        }
        """#))
        
        _ = try manager.linkExternalTestResult(with: ctaToken).await().get()
        XCTAssertNil(notificationManager.notificationType)
        let storedResult = try XCTUnwrap(virologyStore.relevantUnacknowledgedTestResult)
        XCTAssertEqual(storedResult.testResult, TestResult.positive)
        XCTAssertEqual(storedResult.diagnosisKeySubmissionToken, submissionToken)
    }
    
    func testEvaluateLinkTestResultsNegative() throws {
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        let ctaToken = String.random()
        
        mockServer.response = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "2020-04-23T00:00:00.0000000Z",
            "testResult": "NEGATIVE",
            "diagnosisKeySubmissionToken": "\#(submissionToken.value)",
        }
        """#))
        
        _ = try manager.linkExternalTestResult(with: ctaToken).await().get()
        XCTAssertNil(notificationManager.notificationType)
        let storedResult = try XCTUnwrap(virologyStore.relevantUnacknowledgedTestResult)
        XCTAssertEqual(storedResult.testResult, TestResult.negative)
        XCTAssertNil(storedResult.diagnosisKeySubmissionToken)
    }
    
    func testEvaluateLinkTestResultsVoid() throws {
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        let ctaToken = String.random()
        
        mockServer.response = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "2020-04-23T00:00:00.0000000Z",
            "testResult": "VOID",
            "diagnosisKeySubmissionToken": "\#(submissionToken.value)",
        }
        """#))
        
        _ = try manager.linkExternalTestResult(with: ctaToken).await().get()
        XCTAssertNil(notificationManager.notificationType)
        let storedResult = try XCTUnwrap(virologyStore.relevantUnacknowledgedTestResult)
        XCTAssertEqual(storedResult.testResult, TestResult.void)
        XCTAssertNil(storedResult.diagnosisKeySubmissionToken)
    }
    
    func testEvaluateLinkTestResultsInvalidToken() throws {
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        let ctaToken = String.random()
        
        validator.shouldFail = true
        
        mockServer.response = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "2020-04-23T00:00:00.0000000Z",
            "testResult": "VOID",
            "diagnosisKeySubmissionToken": "\#(submissionToken.value)",
        }
        """#))
        
        let error = try manager.linkExternalTestResult(with: ctaToken).await()
        XCTAssertNil(notificationManager.notificationType)
        
        if case .failure(.invalidCode) = error { } else {
            XCTFail()
        }
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
    
    private class MockCTATokenValidator: CTATokenValidating {
        var shouldFail: Bool = false
        
        func validate(_ token: String) -> Bool {
            return !shouldFail
        }
    }
}
