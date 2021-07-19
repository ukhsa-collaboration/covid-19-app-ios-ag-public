//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

struct IsolationStatePayload: Equatable, DataConvertible {
    var isolationStateInfo: IsolationStateInfo
}

extension IsolationStatePayload: Codable {
    
    private struct Metadata: Codable {
        var version: Int
        
        static let v1 = Metadata(version: 1)
        static let v2 = Metadata(version: 2)
    }
    
    init(from decoder: Decoder) throws {
        let metadata = (try? Metadata(from: decoder)) ?? .v1
        
        guard metadata.version >= Metadata.v2.version else {
            let payload = try PayloadV1(from: decoder)
            isolationStateInfo = IsolationStateInfo(
                isolationInfo: IsolationInfo(payload.isolationInfo),
                configuration: payload.configuration
            )
            return
        }
        
        let payload = try PayloadV2(from: decoder)
        isolationStateInfo = IsolationStateInfo(
            isolationInfo: IsolationInfo(payload: payload),
            configuration: payload.configuration
        )
    }
    
    func encode(to encoder: Encoder) throws {
        let info = isolationStateInfo.isolationInfo
        let stateInfo = PayloadV2(
            version: 2,
            configuration: isolationStateInfo.configuration,
            contact: PayloadV2.ContactCaseInfo(info.contactCaseInfo, hasAcknowledgedStartOfIsolation: info.hasAcknowledgedStartOfIsolation),
            test: PayloadV2.TestCaseInfo(info.indexCaseInfo?.testInfo),
            symptomatic: PayloadV2.SymptomaticCaseInfo(info.indexCaseInfo?.symptomaticInfo),
            hasAcknowledgedEndOfIsolation: isolationStateInfo.isolationInfo.hasAcknowledgedEndOfIsolation
        )
        
        try stateInfo.encode(to: encoder)
    }
    
}

// MARK: - V2

/// /// Data format used on or after v4.10
private struct PayloadV2: Codable {
    struct ContactCaseInfo: Codable {
        var exposureDay: GregorianDay
        var notificationDay: GregorianDay
        var dailyContactTestingOptInDay: GregorianDay?
        var hasAcknowledgedStartOfIsolation: Bool // iOS only
    }
    
    struct TestCaseInfo: Codable {
        enum TestResult: String, Codable {
            case positive
            case negative
        }
        
        enum ConfirmatoryTestCompletionStatus: String, Codable {
            case completed
            case completedAndConfirmed
        }
        
        enum TestKitType: String, Codable {
            case labResult
            case rapidResult
            case rapidSelfReported
        }
        
        var testResult: TestResult
        var testKitType: TestKitType?
        var acknowledgedDay: GregorianDay
        
        var requiresConfirmatoryTest: Bool
        var confirmatoryDayLimit: Int?
        // This is either `confirmedDay` or `completedDay`. Keeping the name because of codable store backwards compatibility.
        var confirmedDay: GregorianDay?
        var confirmatoryTestCompletionStatus: ConfirmatoryTestCompletionStatus?
        var testEndDay: GregorianDay?
    }
    
    struct SymptomaticCaseInfo: Codable {
        var selfDiagnosisDay: GregorianDay
        var onsetDay: GregorianDay?
    }
    
    var version: Int
    var configuration: IsolationConfiguration
    var contact: ContactCaseInfo?
    var test: TestCaseInfo?
    var symptomatic: SymptomaticCaseInfo?
    var hasAcknowledgedEndOfIsolation: Bool
}

private extension IsolationInfo {
    
    init(payload: PayloadV2) {
        self.init(
            hasAcknowledgedEndOfIsolation: payload.hasAcknowledgedEndOfIsolation,
            hasAcknowledgedStartOfIsolation: payload.contact?.hasAcknowledgedStartOfIsolation ?? false,
            indexCaseInfo: IndexCaseInfo(symptomatic: payload.symptomatic, test: payload.test),
            contactCaseInfo: ContactCaseInfo(contact: payload.contact)
        )
    }
    
}

private extension ContactCaseInfo {
    
    init?(contact: PayloadV2.ContactCaseInfo?) {
        guard let contact = contact else { return nil }
        self.init(
            exposureDay: contact.exposureDay,
            isolationFromStartOfDay: contact.notificationDay,
            optOutOfIsolationDay: contact.dailyContactTestingOptInDay
        )
    }
    
}

private extension IndexCaseInfo {
    
    init?(symptomatic: PayloadV2.SymptomaticCaseInfo?, test: PayloadV2.TestCaseInfo?) {
        guard symptomatic != nil || test != nil else { return nil }
        let symptomaticInfo = symptomatic.map {
            SymptomaticInfo(
                selfDiagnosisDay: $0.selfDiagnosisDay,
                onsetDay: $0.onsetDay
            )
        }
        
        // Historically we will have always completed and confirm when there is a confirmedOnDay present.
        let isCompletedAndConfirmed = test?.confirmatoryTestCompletionStatus != .completed
        
        let testInfo = test.map {
            TestInfo(
                result: TestResult($0.testResult),
                testKitType: TestKitType($0.testKitType),
                requiresConfirmatoryTest: $0.requiresConfirmatoryTest,
                confirmatoryDayLimit: $0.confirmatoryDayLimit,
                receivedOnDay: $0.acknowledgedDay,
                confirmedOnDay: isCompletedAndConfirmed ? $0.confirmedDay : nil,
                completedOnDay: $0.confirmedDay,
                testEndDay: $0.testEndDay
            )
        }
        self.init(
            symptomaticInfo: symptomaticInfo,
            testInfo: testInfo
        )
    }
    
}

private extension TestResult {
    
    init(_ result: PayloadV2.TestCaseInfo.TestResult) {
        switch result {
        case .positive:
            self = .positive
        case .negative:
            self = .negative
        }
    }
    
}

private extension TestKitType {
    
    init?(_ result: PayloadV2.TestCaseInfo.TestKitType?) {
        guard let result = result else { return nil }
        switch result {
        case .labResult:
            self = .labResult
        case .rapidResult:
            self = .rapidResult
        case .rapidSelfReported:
            self = .rapidSelfReported
        }
    }
    
}

private extension PayloadV2.ContactCaseInfo {
    
    init?(_ contactCaseInfo: ContactCaseInfo?, hasAcknowledgedStartOfIsolation: Bool) {
        guard let contactCaseInfo = contactCaseInfo else { return nil }
        self.init(
            exposureDay: contactCaseInfo.exposureDay,
            notificationDay: contactCaseInfo.isolationFromStartOfDay,
            dailyContactTestingOptInDay: contactCaseInfo.optOutOfIsolationDay,
            hasAcknowledgedStartOfIsolation: hasAcknowledgedStartOfIsolation
        )
    }
    
}

private extension PayloadV2.SymptomaticCaseInfo {
    
    init?(_ symptomaticInfo: IndexCaseInfo.SymptomaticInfo?) {
        guard let symptomaticInfo = symptomaticInfo else { return nil }
        self.init(
            selfDiagnosisDay: symptomaticInfo.selfDiagnosisDay,
            onsetDay: symptomaticInfo.onsetDay
        )
    }
    
}

private extension PayloadV2.TestCaseInfo {
    
    init?(_ testInfo: IndexCaseInfo.TestInfo?) {
        guard
            let testInfo = testInfo,
            let testResult = TestResult(testInfo.result) else {
            return nil
        }
        
        let confirmatoryTestCompletionStatus: ConfirmatoryTestCompletionStatus? = {
            switch (testInfo.completedOnDay, testInfo.confirmedOnDay) {
            case (.none, _): return nil
            case (.some, .none): return .completed
            case (.some, .some): return .completedAndConfirmed
            }
        }()
        
        self.init(
            testResult: testResult,
            testKitType: PayloadV2.TestCaseInfo.TestKitType(testInfo.testKitType),
            acknowledgedDay: testInfo.receivedOnDay,
            requiresConfirmatoryTest: testInfo.requiresConfirmatoryTest,
            confirmatoryDayLimit: testInfo.confirmatoryDayLimit,
            confirmedDay: testInfo.completedOnDay,
            confirmatoryTestCompletionStatus: confirmatoryTestCompletionStatus,
            testEndDay: testInfo.testEndDay
        )
    }
    
}

private extension PayloadV2.TestCaseInfo.TestResult {
    
    init?(_ result: TestResult) {
        switch result {
        case .positive:
            self = .positive
        case .negative:
            self = .negative
        }
    }
    
}

private extension PayloadV2.TestCaseInfo.TestKitType {
    
    init?(_ result: TestKitType?) {
        guard let result = result else { return nil }
        switch result {
        case .labResult:
            self = .labResult
        case .rapidResult:
            self = .rapidResult
        case .rapidSelfReported:
            self = .rapidSelfReported
        }
    }
    
}

// MARK: - V1

/// Data format used on or before v4.9
private struct PayloadV1: Decodable {
    struct ContactCaseInfo: Decodable {
        var exposureDay: GregorianDay
        var isolationFromStartOfDay: GregorianDay
        var optOutOfIsolationDay: GregorianDay?
    }
    
    struct IndexCaseInfo: Decodable {
        enum TestResult: String, Codable {
            case positive
            case negative
            case void
        }
        
        enum TestKitType: String, Codable {
            case labResult
            case rapidResult
            case rapidSelfReported
        }
        
        struct TestInfo: Decodable {
            var result: TestResult
            var testKitType: TestKitType?
            var requiresConfirmatoryTest: Bool?
            var receivedOnDay: GregorianDay
            var confirmedOnDay: GregorianDay?
        }
        
        var selfDiagnosisDay: GregorianDay?
        var onsetDay: GregorianDay?
        var npexDay: GregorianDay?
        var testInfo: TestInfo?
    }
    
    struct IsolationInfo: Decodable {
        var hasAcknowledgedEndOfIsolation: Bool?
        var hasAcknowledgedStartOfIsolation: Bool?
        var indexCaseInfo: IndexCaseInfo?
        var contactCaseInfo: ContactCaseInfo?
    }
    
    var isolationInfo: IsolationInfo
    var configuration: IsolationConfiguration
}

private extension IsolationInfo {
    
    init(_ payload: PayloadV1.IsolationInfo) {
        self.init(
            hasAcknowledgedEndOfIsolation: payload.hasAcknowledgedEndOfIsolation ?? false,
            hasAcknowledgedStartOfIsolation: payload.hasAcknowledgedStartOfIsolation ?? false,
            indexCaseInfo: payload.indexCaseInfo.flatMap(IndexCaseInfo.init),
            contactCaseInfo: payload.contactCaseInfo.map(ContactCaseInfo.init)
        )
    }
    
}

private extension ContactCaseInfo {
    
    init(_ payload: PayloadV1.ContactCaseInfo) {
        self.init(
            exposureDay: payload.exposureDay,
            isolationFromStartOfDay: payload.isolationFromStartOfDay,
            optOutOfIsolationDay: payload.optOutOfIsolationDay
        )
    }
    
}

private extension IndexCaseInfo {
    
    init?(_ payload: PayloadV1.IndexCaseInfo) {
        self.init(
            symptomaticInfo: payload.selfDiagnosisDay.map { SymptomaticInfo(selfDiagnosisDay: $0, onsetDay: payload.onsetDay) },
            testInfo: payload.testInfo.flatMap { IndexCaseInfo.TestInfo($0, testEndDay: payload.npexDay) }
        )
    }
    
}

private extension IndexCaseInfo.TestInfo {
    
    init?(_ testInfo: PayloadV1.IndexCaseInfo.TestInfo, testEndDay: GregorianDay?) {
        guard let result = TestResult(testInfo.result) else { return nil }
        self.init(
            result: result,
            testKitType: TestKitType(testInfo.testKitType),
            requiresConfirmatoryTest: testInfo.requiresConfirmatoryTest ?? false,
            confirmatoryDayLimit: nil,
            receivedOnDay: testInfo.receivedOnDay,
            confirmedOnDay: testInfo.confirmedOnDay,
            completedOnDay: testInfo.confirmedOnDay,
            testEndDay: testEndDay
        )
    }
    
}

private extension TestResult {
    
    init?(_ result: PayloadV1.IndexCaseInfo.TestResult) {
        switch result {
        case .positive:
            self = .positive
        case .negative:
            self = .negative
        case .void:
            // `void` was only stored in very early versions of the app.
            // We keep the `enum` "just in case"; for the edge cases that this is stored somewhere and we don’t want
            // decoding of the whole object to fail for this.
            // but if somehow it does exist, it does not affect isolation logic, so we don’t need to pass it up.
            return nil
        }
    }
    
}

private extension TestKitType {
    
    init?(_ result: PayloadV1.IndexCaseInfo.TestKitType?) {
        guard let result = result else { return nil }
        switch result {
        case .labResult:
            self = .labResult
        case .rapidResult:
            self = .rapidResult
        case .rapidSelfReported:
            self = .rapidSelfReported
        }
    }
    
}
