//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

private struct VirologyTokensInfo: Codable, DataConvertible, Equatable {
    var pollingToken: String
    var diagnosisKeySubmissionToken: String
}

private struct VirologyTestingInfo: Codable, DataConvertible {
    var tokensInfo: [VirologyTokensInfo]?
    var latestUnacknowledgedTestResult: TestResultInfo?
    var unacknowledgedTestResults: [TestResultInfo]?
}

private struct TestResultInfo: Codable, DataConvertible {
    var result: TestResult
    var endDate: Date // Date test result arrives at NPEx
    var diagnosisKeySubmissionToken: String?
}

public class VirologyTestingStateStore {
    
    @Encrypted private var virologyTestingInfo: VirologyTestingInfo? {
        didSet {
            virologyTestResult = relevantUnacknowledgedTestResult
        }
    }
    
    @Published
    private(set) var virologyTestResult: VirologyStateTestResult?
    
    init(store: EncryptedStoring) {
        _virologyTestingInfo = store.encrypted("virology_testing")
        virologyTestResult = relevantUnacknowledgedTestResult
        
        migrate()
    }
    
    #warning("Delete this migration code one month after a force update")
    private func migrate() {
        if let latestUnacknowledgedTestResult = virologyTestingInfo?.latestUnacknowledgedTestResult {
            let newList: [TestResultInfo] = (virologyTestingInfo?.unacknowledgedTestResults ?? []) + [latestUnacknowledgedTestResult]
            virologyTestingInfo = mutating(virologyTestingInfo) {
                $0?.latestUnacknowledgedTestResult = nil
                $0?.unacknowledgedTestResults = newList
            }
        }
    }
    
    var virologyTestTokens: [VirologyTestTokens]? {
        if let virologyTestingInfo = virologyTestingInfo,
            let tokensInfo = virologyTestingInfo.tokensInfo {
            return tokensInfo.map { testInfo in
                VirologyTestTokens(
                    pollingToken: PollingToken(value: testInfo.pollingToken),
                    diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: testInfo.diagnosisKeySubmissionToken)
                )
            }
        } else {
            return nil
        }
    }
    
    var relevantUnacknowledgedTestResult: VirologyStateTestResult? {
        if let unacknowledgedTestResult = getRelevantTestResult() {
            let diagnosisSubmissionToken: DiagnosisKeySubmissionToken?
            if let submissionToken = unacknowledgedTestResult.diagnosisKeySubmissionToken {
                diagnosisSubmissionToken = DiagnosisKeySubmissionToken(value: submissionToken)
            } else {
                diagnosisSubmissionToken = nil
            }
            return VirologyStateTestResult(
                testResult: unacknowledgedTestResult.result,
                endDate: unacknowledgedTestResult.endDate,
                diagnosisKeySubmissionToken: diagnosisSubmissionToken
            )
        } else {
            return nil
        }
    }
    
    func saveTest(
        pollingToken: PollingToken,
        diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken
    ) {
        let virologyTokens = VirologyTokensInfo(
            pollingToken: pollingToken.value,
            diagnosisKeySubmissionToken: diagnosisKeySubmissionToken.value
        )
        var newList: [VirologyTokensInfo] = virologyTestingInfo?.tokensInfo ?? []
        newList.append(virologyTokens)
        
        virologyTestingInfo = VirologyTestingInfo(
            tokensInfo: newList,
            unacknowledgedTestResults: virologyTestingInfo?.unacknowledgedTestResults
        )
    }
    
    func saveResult(virologyTestResult: VirologyTestResult, diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken?) {
        let testResultInfo = TestResultInfo(
            result: TestResult(virologyTestResult.testResult),
            endDate: virologyTestResult.endDate,
            diagnosisKeySubmissionToken: diagnosisKeySubmissionToken?.value
        )
        
        let newList: [TestResultInfo] = (virologyTestingInfo?.unacknowledgedTestResults ?? []) + [testResultInfo]
        
        virologyTestingInfo = VirologyTestingInfo(
            tokensInfo: virologyTestingInfo?.tokensInfo,
            unacknowledgedTestResults: newList
        )
    }
    
    func removeTestTokens(_ tokens: VirologyTestTokens) {
        let virologyTokensInfo = VirologyTokensInfo(
            pollingToken: tokens.pollingToken.value,
            diagnosisKeySubmissionToken: tokens.diagnosisKeySubmissionToken.value
        )
        
        var newList: [VirologyTokensInfo] = virologyTestingInfo?.tokensInfo ?? []
        newList = newList.filter { $0 != virologyTokensInfo }
        
        virologyTestingInfo = VirologyTestingInfo(
            tokensInfo: newList,
            unacknowledgedTestResults: virologyTestingInfo?.unacknowledgedTestResults
        )
    }
    
    func remove(testResult: VirologyStateTestResult) {
        if let unacknowledgedTestResults = virologyTestingInfo?.unacknowledgedTestResults {
            let newList = unacknowledgedTestResults.filter { !testEquality(savedResult: $0, testResult: testResult) }
            
            virologyTestingInfo = VirologyTestingInfo(
                tokensInfo: virologyTestingInfo?.tokensInfo,
                unacknowledgedTestResults: newList
            )
        }
    }
    
    private func testEquality(savedResult: TestResultInfo, testResult: VirologyStateTestResult) -> Bool {
        return savedResult.result == testResult.testResult &&
            savedResult.endDate == testResult.endDate &&
            savedResult.diagnosisKeySubmissionToken == testResult.diagnosisKeySubmissionToken?.value
    }
    
    func delete() {
        virologyTestingInfo = nil
    }
    
    private func getRelevantTestResult() -> TestResultInfo? {
        if let virologyTestingInfo = virologyTestingInfo,
            let unacknowledgedTestResults = virologyTestingInfo.unacknowledgedTestResults {
            if let positive = unacknowledgedTestResults.filter({ $0.result == .positive }).first {
                return positive
            } else if let negative = unacknowledgedTestResults.filter({ $0.result == .negative }).first {
                return negative
            } else if let void = unacknowledgedTestResults.filter({ $0.result == .void }).first {
                return void
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
