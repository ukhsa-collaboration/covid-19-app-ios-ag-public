//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest
@testable import Domain

class VirologyTestingStateStoreTests: XCTestCase {
    private var encryptedStore: MockEncryptedStore!
    private var virologyTestingStateStore: VirologyTestingStateStore!
    
    override func setUp() {
        super.setUp()
        
        encryptedStore = MockEncryptedStore()
        virologyTestingStateStore = VirologyTestingStateStore(store: encryptedStore)
    }
    
    func testCanLoadVirologyTestingInfo() throws {
        let pollingToken = String.random()
        let submissionToken = String.random()
        let result = TestResult.positive
        let endDate = Calendar.utc.date(from: DateComponents(year: 2020, month: 5, day: 7, hour: 8))
        
        encryptedStore.stored["virology_testing"] = #"""
        {
            "tokensInfo":[
                {
                    "diagnosisKeySubmissionToken":"\#(submissionToken)",
                    "pollingToken":"\#(pollingToken)"
                }
            ],
            "latestUnacknowledgedTestResult":{
                "result":"\#(result.rawValue)",
                "endDate":610531200,
                "diagnosisKeySubmissionToken":"\#(submissionToken)"
            }
        }
        """# .data(using: .utf8)
        
        let virologyTestTokens = try XCTUnwrap(virologyTestingStateStore.virologyTestTokens)
        let firstTokens = try XCTUnwrap(virologyTestTokens.first)
        XCTAssertEqual(firstTokens.pollingToken.value, pollingToken)
        XCTAssertEqual(firstTokens.diagnosisKeySubmissionToken.value, submissionToken)
        
        let testResult = try XCTUnwrap(virologyTestingStateStore.latestUnacknowledgedTestResult)
        let diagnosisSubmissionToken = try XCTUnwrap(testResult.diagnosisKeySubmissionToken)
        XCTAssertEqual(testResult.endDate, endDate)
        XCTAssertEqual(testResult.testResult, result)
        XCTAssertEqual(diagnosisSubmissionToken.value, submissionToken)
    }
    
    func testCanSaveVirologyTestingInfo() throws {
        let pollingToken = PollingToken(value: .random())
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        virologyTestingStateStore.saveTest(
            pollingToken: pollingToken,
            diagnosisKeySubmissionToken: submissionToken
        )
        
        let virologyTestTokens = try XCTUnwrap(virologyTestingStateStore.virologyTestTokens)
        let firstTokens = try XCTUnwrap(virologyTestTokens.first)
        XCTAssertEqual(firstTokens.pollingToken, pollingToken)
        XCTAssertEqual(firstTokens.diagnosisKeySubmissionToken, submissionToken)
    }
    
    func testCanSaveTestResult() throws {
        let date = Date()
        let virologyTestResult = VirologyTestResult(
            testResult: .positive,
            endDate: date
        )
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        virologyTestingStateStore.saveResult(
            virologyTestResult: virologyTestResult,
            diagnosisKeySubmissionToken: submissionToken
        )
        
        let savedResult = try XCTUnwrap(virologyTestingStateStore.latestUnacknowledgedTestResult)
        let savedSubmissionToken = try XCTUnwrap(savedResult.diagnosisKeySubmissionToken)
        XCTAssertEqual(savedResult.testResult, .positive)
        XCTAssertEqual(savedResult.endDate, date)
        XCTAssertEqual(savedSubmissionToken, submissionToken)
    }
    
    func testWillNotSaveVoidTestResult() throws {
        let date = Date()
        let virologyTestResult = VirologyTestResult(
            testResult: .void,
            endDate: date
        )
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        virologyTestingStateStore.saveResult(
            virologyTestResult: virologyTestResult,
            diagnosisKeySubmissionToken: submissionToken
        )
        
        XCTAssertNil(virologyTestingStateStore.latestUnacknowledgedTestResult)
    }
    
    func testWillSaveNewerTestResult() throws {
        let pastDate = Calendar.utc.date(from: DateComponents(year: 2020, month: 5, day: 7, hour: 8))!
        let alreadySavedTestResult = VirologyTestResult(
            testResult: .negative,
            endDate: pastDate
        )
        let oldSubmissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        virologyTestingStateStore.saveResult(
            virologyTestResult: alreadySavedTestResult,
            diagnosisKeySubmissionToken: oldSubmissionToken
        )
        
        let newDate = Date()
        let newerVirologyTestResult = VirologyTestResult(
            testResult: .positive,
            endDate: newDate
        )
        let newSubmissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        virologyTestingStateStore.saveResult(
            virologyTestResult: newerVirologyTestResult,
            diagnosisKeySubmissionToken: newSubmissionToken
        )
        
        let savedResult = try XCTUnwrap(virologyTestingStateStore.latestUnacknowledgedTestResult)
        let savedSubmissionToken = try XCTUnwrap(savedResult.diagnosisKeySubmissionToken)
        XCTAssertEqual(savedResult.testResult, .positive)
        XCTAssertEqual(savedResult.endDate, newDate)
        XCTAssertEqual(savedSubmissionToken, newSubmissionToken)
    }
    
    func testWillNotSaveOlderTestResult() throws {
        // Save the newer date first
        let newDate = Date()
        let newerVirologyTestResult = VirologyTestResult(
            testResult: .positive,
            endDate: newDate
        )
        let newSubmissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        virologyTestingStateStore.saveResult(
            virologyTestResult: newerVirologyTestResult,
            diagnosisKeySubmissionToken: newSubmissionToken
        )
        
        let pastDate = Calendar.utc.date(from: DateComponents(year: 2020, month: 5, day: 7, hour: 8))!
        let alreadySavedTestResult = VirologyTestResult(
            testResult: .negative,
            endDate: pastDate
        )
        let oldSubmissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        virologyTestingStateStore.saveResult(
            virologyTestResult: alreadySavedTestResult,
            diagnosisKeySubmissionToken: oldSubmissionToken
        )
        
        let savedResult = try XCTUnwrap(virologyTestingStateStore.latestUnacknowledgedTestResult)
        let savedSubmissionToken = try XCTUnwrap(savedResult.diagnosisKeySubmissionToken)
        XCTAssertEqual(savedResult.testResult, .positive)
        XCTAssertEqual(savedResult.endDate, newDate)
        XCTAssertEqual(savedSubmissionToken, newSubmissionToken)
    }
    
    func testLatestTestResultIsPublished() throws {
        let date = Date()
        let virologyTestResult = VirologyTestResult(
            testResult: .positive,
            endDate: date
        )
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        virologyTestingStateStore.saveResult(
            virologyTestResult: virologyTestResult,
            diagnosisKeySubmissionToken: submissionToken
        )
        
        let publishedResult = try virologyTestingStateStore.$virologyTestResult.await().get()
        
        XCTAssertEqual(publishedResult?.testResult, .positive)
        XCTAssertEqual(publishedResult?.endDate, date)
        XCTAssertEqual(publishedResult?.diagnosisKeySubmissionToken, submissionToken)
    }
    
    func testCanDeleteVirologyTestingTokens() throws {
        let removePollingToken = PollingToken(value: .random())
        let removeSubmissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        let keepPollingToken = PollingToken(value: .random())
        let keepSubmissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        virologyTestingStateStore.saveTest(pollingToken: removePollingToken, diagnosisKeySubmissionToken: removeSubmissionToken)
        virologyTestingStateStore.saveTest(pollingToken: keepPollingToken, diagnosisKeySubmissionToken: keepSubmissionToken)
        
        let tokens = VirologyTestTokens(
            pollingToken: removePollingToken,
            diagnosisKeySubmissionToken: removeSubmissionToken
        )
        virologyTestingStateStore.removeTestTokens(tokens)
        
        let virologyTestTokens = try XCTUnwrap(virologyTestingStateStore.virologyTestTokens)
        XCTAssertEqual(1, virologyTestTokens.count)
        let savedTokens = try XCTUnwrap(virologyTestTokens.first)
        XCTAssertEqual(savedTokens.diagnosisKeySubmissionToken, keepSubmissionToken)
        XCTAssertEqual(savedTokens.pollingToken, keepPollingToken)
    }
    
    func testCanDeleteLastVirologyTestingTokens() throws {
        let pollingToken = PollingToken(value: .random())
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        virologyTestingStateStore.saveTest(pollingToken: pollingToken, diagnosisKeySubmissionToken: submissionToken)
        
        let tokens = VirologyTestTokens(
            pollingToken: pollingToken,
            diagnosisKeySubmissionToken: submissionToken
        )
        virologyTestingStateStore.removeTestTokens(tokens)
        
        let virologyTestTokens = try XCTUnwrap(virologyTestingStateStore.virologyTestTokens)
        XCTAssertEqual(0, virologyTestTokens.count)
    }
    
    func testCanDeleteVirologyTestResult() throws {
        let pollingToken = PollingToken(value: .random())
        let submissionToken = DiagnosisKeySubmissionToken(value: .random())
        
        virologyTestingStateStore.saveTest(pollingToken: pollingToken, diagnosisKeySubmissionToken: submissionToken)
        
        let virologyTestResult = VirologyTestResult(
            testResult: .positive,
            endDate: Date()
        )
        
        virologyTestingStateStore.saveResult(
            virologyTestResult: virologyTestResult,
            diagnosisKeySubmissionToken: submissionToken
        )
        
        virologyTestingStateStore.removeLatestTestResult()
        
        XCTAssertNil(virologyTestingStateStore.virologyTestResult)
        let virologyTestTokens = try XCTUnwrap(virologyTestingStateStore.virologyTestTokens)
        XCTAssertEqual(1, virologyTestTokens.count)
    }
    
    func testCanDeleteVirologyTestingInfo() throws {
        let pollingToken = String.random()
        let submissionToken = String.random()
        let result = TestResult.positive
        
        encryptedStore.stored["virology_testing"] = #"""
        {
            "tokensInfo":[
                {
                    "diagnosisKeySubmissionToken":"\#(submissionToken)",
                    "pollingToken":"\#(pollingToken)"
                }
            ],
            "latestUnacknowledgedTestResult":{
                "result":"\#(result.rawValue)",
                "endDate":610531200,
                "diagnosisKeySubmissionToken":"\#(submissionToken)"
            }
        }
        """# .data(using: .utf8)
        
        virologyTestingStateStore.delete()
        XCTAssertNil(virologyTestingStateStore.virologyTestTokens)
    }
}
