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
}

private struct TestResultInfo: Codable, DataConvertible {
    var result: TestResult
    var endDate: Date
    var diagnosisKeySubmissionToken: String?
}

public class VirologyTestingStateStore {
    
    @Encrypted private var virologyTestingInfo: VirologyTestingInfo? {
        didSet {
            virologyTestResult = latestUnacknowledgedTestResult
        }
    }
    
    @Published
    private(set) var virologyTestResult: VirologyStateTestResult?
    
    init(store: EncryptedStoring) {
        _virologyTestingInfo = store.encrypted("virology_testing")
        virologyTestResult = latestUnacknowledgedTestResult
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
    
    var latestUnacknowledgedTestResult: VirologyStateTestResult? {
        if let virologyTestingInfo = virologyTestingInfo,
            let unacknowledgedTestResult = virologyTestingInfo.latestUnacknowledgedTestResult {
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
            latestUnacknowledgedTestResult: virologyTestingInfo?.latestUnacknowledgedTestResult
        )
    }
    
    func saveResult(virologyTestResult: VirologyTestResult, diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken?) {
        guard let testResult = try? TestResult(virologyTestResult.testResult) else { return }
        
        var testResultInfo: TestResultInfo
        if let oldTestingInfo = virologyTestingInfo,
            let oldTestingResult = oldTestingInfo.latestUnacknowledgedTestResult {
            if oldTestingResult.endDate < virologyTestResult.endDate {
                testResultInfo = TestResultInfo(
                    result: testResult,
                    endDate: virologyTestResult.endDate,
                    diagnosisKeySubmissionToken: diagnosisKeySubmissionToken?.value
                )
            } else {
                testResultInfo = oldTestingResult
            }
        } else {
            testResultInfo = TestResultInfo(
                result: testResult,
                endDate: virologyTestResult.endDate,
                diagnosisKeySubmissionToken: diagnosisKeySubmissionToken?.value
            )
        }
        
        virologyTestingInfo = VirologyTestingInfo(
            tokensInfo: virologyTestingInfo?.tokensInfo,
            latestUnacknowledgedTestResult: testResultInfo
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
            latestUnacknowledgedTestResult: virologyTestingInfo?.latestUnacknowledgedTestResult
        )
    }
    
    func removeLatestTestResult() {
        virologyTestingInfo = VirologyTestingInfo(
            tokensInfo: virologyTestingInfo?.tokensInfo,
            latestUnacknowledgedTestResult: nil
        )
    }
    
    func delete() {
        virologyTestingInfo = nil
    }
}

private extension TestResult {
    init(_ testResult: VirologyTestResult.TestResult) throws {
        switch testResult {
        case .negative:
            self = .negative
        case .positive:
            self = .positive
        case .void:
            throw TestResultInvalidError()
        }
    }
    
    struct TestResultInvalidError: Error {}
}
