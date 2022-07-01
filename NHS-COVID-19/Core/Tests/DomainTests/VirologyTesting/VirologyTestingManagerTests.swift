//
// Copyright © 2021 DHSC. All rights reserved.
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
        virologyStore = VirologyTestingStateStore(
            store: MockEncryptedStore(),
            dateProvider: MockDateProvider()
        )
        notificationManager = MockUserNotificationsManager()
        validator = MockCTATokenValidator()
        manager = VirologyTestingManager(
            httpClient: mockServer,
            virologyTestingStateCoordinator: VirologyTestingStateCoordinator(
                virologyTestingStateStore: virologyStore,
                userNotificationsManager: notificationManager,
                isInterestedInAskingForSymptomsOnsetDay: { false },
                setRequiresOnsetDay: {},
                country: { .england }
            ),
            ctaTokenValidator: validator,
            country: { .england }
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
            "testResult": "POSITIVE",
            "testKit": "LAB_RESULT",
            "diagnosisKeySubmissionSupported": true,
            "requiresConfirmatoryTest": false,
            "shouldOfferFollowUpTest": false
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
            "testResult": "POSITIVE",
            "testKit": "LAB_RESULT",
            "diagnosisKeySubmissionSupported": true,
            "requiresConfirmatoryTest": false,
            "shouldOfferFollowUpTest": false
        }
        """#))

        _ = try manager.evaulateTestResults().await().get()
        XCTAssertEqual(notificationManager.notificationType, UserNotificationType.testResultReceived)
        let storedResult = try XCTUnwrap(virologyStore.virologyTestResult.currentValue)
        XCTAssertEqual(storedResult.testResult, .positive)
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
            "testResult": "NEGATIVE",
            "testKit": "LAB_RESULT",
            "diagnosisKeySubmissionSupported": true,
            "requiresConfirmatoryTest": false,
            "shouldOfferFollowUpTest": false
        }
        """#))

        _ = try manager.evaulateTestResults().await().get()
        XCTAssertEqual(notificationManager.notificationType, UserNotificationType.testResultReceived)
        let storedResult = try XCTUnwrap(virologyStore.virologyTestResult.currentValue)
        XCTAssertEqual(storedResult.testResult, .negative)
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
            "testResult": "VOID",
            "testKit": "LAB_RESULT",
            "diagnosisKeySubmissionSupported": true,
            "requiresConfirmatoryTest": false,
            "shouldOfferFollowUpTest": false
        }
        """#))

        _ = try manager.evaulateTestResults().await().get()
        XCTAssertEqual(notificationManager.notificationType, UserNotificationType.testResultReceived)
        let storedResult = try XCTUnwrap(virologyStore.virologyTestResult.currentValue)
        XCTAssertEqual(storedResult.testResult, .void)
        XCTAssertNil(storedResult.diagnosisKeySubmissionToken)
        let storedTokens = try XCTUnwrap(virologyStore.virologyTestTokens)
        XCTAssertEqual(storedTokens.count, 0)
    }

    func testEvaluateTestResultsUnknown() throws {
        let pollingToken = PollingToken(value: .random())
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())

        virologyStore.saveTest(pollingToken: pollingToken, diagnosisKeySubmissionToken: submissionToken)

        mockServer.response = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "2020-04-23T00:00:00.0000000Z",
            "testResult": "UNKNOWN_TEST_RESULT_TYPE",
            "testKit": "LAB_RESULT",
            "diagnosisKeySubmissionSupported": true,
            "requiresConfirmatoryTest": false,
            "shouldOfferFollowUpTest": false
        }
        """#))

        _ = try manager.evaulateTestResults().await().get()

        // expecting a notification but no change in test results
        XCTAssertEqual(notificationManager.notificationType, UserNotificationType.testResultReceived)
        XCTAssertNil(virologyStore.virologyTestResult.currentValue)

        // expecting this to be set as the result couldn't be parsed
        XCTAssertTrue(virologyStore.didReceiveUnknownTestResult)

        // expect the tokens to be removed
        XCTAssertTrue((virologyStore.virologyTestTokens ?? []).isEmpty)
    }

    func testEvaluateLinkTestResultsUnknown() throws {
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        let ctaToken = String.random()

        mockServer.response = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "2020-04-23T00:00:00.0000000Z",
            "diagnosisKeySubmissionSupported": true,
            "requiresConfirmatoryTest": false,
            "shouldOfferFollowUpTest": false,
            "testKit": "LAB_RESULT",
            "testResult": "UNKNOWN_TEST_RESULT_TYPE",
            "diagnosisKeySubmissionToken": "\#(submissionToken.value)"
        }
        """#))

        // decoding should fail since test result is unkown
        XCTAssertThrowsError(try manager.linkExternalTestResult(with: ctaToken).await().get(), "Decoding error") { error in
            XCTAssertEqual(error as? LinkTestResultError, LinkTestResultError.decodeFailed)
        }

        // notification should not be triggered and there should be no change in test results
        XCTAssertNil(notificationManager.notificationType)
        XCTAssertNil(virologyStore.virologyTestResult.currentValue)

        // expecting this to be set as the result couldn't be parsed
        XCTAssertTrue(virologyStore.didReceiveUnknownTestResult)

        // expect the tokens to be removed
        XCTAssertTrue((virologyStore.virologyTestTokens ?? []).isEmpty)
    }

    func testEvaluateLinkTestResultsPositive() throws {
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        let ctaToken = String.random()

        mockServer.response = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "2020-04-23T00:00:00.0000000Z",
            "diagnosisKeySubmissionSupported": true,
            "requiresConfirmatoryTest": false,
            "shouldOfferFollowUpTest": false,
            "testKit": "LAB_RESULT",
            "testResult": "POSITIVE",
            "diagnosisKeySubmissionToken": "\#(submissionToken.value)"
        }
        """#))

        _ = try manager.linkExternalTestResult(with: ctaToken).await().get()
        XCTAssertNil(notificationManager.notificationType)
        let storedResult = try XCTUnwrap(virologyStore.virologyTestResult.currentValue)
        XCTAssertEqual(storedResult.testResult, .positive)
        XCTAssertEqual(storedResult.diagnosisKeySubmissionToken, submissionToken)
    }

    func testEvaluateLinkTestResultsNegative() throws {
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        let ctaToken = String.random()

        mockServer.response = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "2020-04-23T00:00:00.0000000Z",
            "testResult": "NEGATIVE",
            "diagnosisKeySubmissionSupported": false,
            "requiresConfirmatoryTest": false,
            "shouldOfferFollowUpTest": false,
            "testKit": "LAB_RESULT",
            "diagnosisKeySubmissionToken": "\#(submissionToken.value)"
        }
        """#))

        _ = try manager.linkExternalTestResult(with: ctaToken).await().get()
        XCTAssertNil(notificationManager.notificationType)
        let storedResult = try XCTUnwrap(virologyStore.virologyTestResult.currentValue)
        XCTAssertEqual(storedResult.testResult, .negative)
        XCTAssertNil(storedResult.diagnosisKeySubmissionToken)
    }

    func testEvaluateLinkTestResultsVoid() throws {
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        let ctaToken = String.random()

        mockServer.response = HTTPResponse.ok(with: .json(#"""
        {
            "testEndDate": "2020-04-23T00:00:00.0000000Z",
            "testResult": "VOID",
            "diagnosisKeySubmissionSupported": false,
            "requiresConfirmatoryTest": false,
            "shouldOfferFollowUpTest": false,
            "testKit": "LAB_RESULT",
            "diagnosisKeySubmissionToken": "\#(submissionToken.value)"
        }
        """#))

        _ = try manager.linkExternalTestResult(with: ctaToken).await().get()
        XCTAssertNil(notificationManager.notificationType)
        let storedResult = try XCTUnwrap(virologyStore.virologyTestResult.currentValue)
        XCTAssertEqual(storedResult.testResult, .void)
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
