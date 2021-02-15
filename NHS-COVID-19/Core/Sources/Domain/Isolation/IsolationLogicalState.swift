//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation

struct IsolationInfo: Codable, Equatable, DataConvertible {
    var hasAcknowledgedEndOfIsolation: Bool = false
    var hasAcknowledgedStartOfIsolation: Bool = false
    var indexCaseInfo: IndexCaseInfo?
    var contactCaseInfo: ContactCaseInfo?
    
    init(
        hasAcknowledgedEndOfIsolation: Bool = false,
        hasAcknowledgedStartOfIsolation: Bool = false,
        indexCaseInfo: IndexCaseInfo? = nil,
        contactCaseInfo: ContactCaseInfo? = nil
    ) {
        self.hasAcknowledgedEndOfIsolation = hasAcknowledgedEndOfIsolation
        self.hasAcknowledgedStartOfIsolation = hasAcknowledgedStartOfIsolation
        self.indexCaseInfo = indexCaseInfo
        self.contactCaseInfo = contactCaseInfo
    }
    
    static let empty = IsolationInfo(indexCaseInfo: nil, contactCaseInfo: nil)
}

struct IsolationConfiguration: Codable, Equatable {
    var maxIsolation: DayDuration
    var contactCase: DayDuration
    var indexCaseSinceSelfDiagnosisOnset: DayDuration
    var indexCaseSinceSelfDiagnosisUnknownOnset: DayDuration
    var housekeepingDeletionPeriod: DayDuration
    var indexCaseSinceNPEXDayNoSelfDiagnosis: DayDuration
    
    private enum CodingKeys: String, CodingKey {
        case maxIsolation
        case contactCase
        case indexCaseSinceSelfDiagnosisOnset
        case indexCaseSinceSelfDiagnosisUnknownOnset
        case housekeepingDeletionPeriod
        case indexCaseSinceNPEXDayNoSelfDiagnosis
    }
}

extension IsolationConfiguration {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        maxIsolation = try container.decode(DayDuration.self, forKey: .maxIsolation)
        contactCase = try container.decode(DayDuration.self, forKey: .contactCase)
        indexCaseSinceSelfDiagnosisOnset = try container.decode(DayDuration.self, forKey: .indexCaseSinceSelfDiagnosisOnset)
        indexCaseSinceSelfDiagnosisUnknownOnset = try container.decode(DayDuration.self, forKey: .indexCaseSinceSelfDiagnosisUnknownOnset)
        housekeepingDeletionPeriod = try container.decode(DayDuration.self, forKey: .housekeepingDeletionPeriod)
        
        // value of the "10" is the historical default value before we were persisting this field.
        indexCaseSinceNPEXDayNoSelfDiagnosis = try container.decodeIfPresent(DayDuration.self, forKey: .indexCaseSinceNPEXDayNoSelfDiagnosis) ?? 10
        
    }
    
    static let `default` = IsolationConfiguration(
        maxIsolation: 21,
        contactCase: 11,
        indexCaseSinceSelfDiagnosisOnset: 11,
        indexCaseSinceSelfDiagnosisUnknownOnset: 9,
        housekeepingDeletionPeriod: 14,
        indexCaseSinceNPEXDayNoSelfDiagnosis: 11
    )
}

public struct IndexCaseInfo: Equatable {
    enum IsolationTrigger: Equatable {
        case selfDiagnosis(GregorianDay)
        case manualTestEntry(npexDay: GregorianDay)
        
        var startDay: GregorianDay {
            switch self {
            case .selfDiagnosis(let day):
                return day
            case .manualTestEntry(let npexDay):
                return npexDay
            }
        }
    }
    
    public struct TestInfo: Codable, Equatable {
        public enum ConfirmationStatus: Equatable {
            case pending
            case confirmed(onDay: GregorianDay)
            case notRequired
        }
        
        public var result: TestResult
        public var testKitType: TestKitType?
        public var requiresConfirmatoryTest: Bool
        public var receivedOnDay: GregorianDay
        public var confirmedOnDay: GregorianDay?
        
        public var confirmationStatus: ConfirmationStatus {
            if requiresConfirmatoryTest {
                if let confirmedOnDay = confirmedOnDay {
                    return .confirmed(onDay: confirmedOnDay)
                }
                return .pending
            } else {
                return .notRequired
            }
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            result = try container.decode(TestResult.self, forKey: .result)
            testKitType = try container.decodeIfPresent(TestKitType.self, forKey: .testKitType)
            requiresConfirmatoryTest = try container.decodeIfPresent(Bool.self, forKey: .requiresConfirmatoryTest) ?? false
            receivedOnDay = try container.decode(GregorianDay.self, forKey: .receivedOnDay)
            confirmedOnDay = try container.decodeIfPresent(GregorianDay.self, forKey: .confirmedOnDay)
        }
        
        public init(result: TestResult, testKitType: TestKitType? = nil, requiresConfirmatoryTest: Bool, receivedOnDay: GregorianDay, confirmedOnDay: GregorianDay? = nil) {
            self.result = result
            self.testKitType = testKitType
            self.requiresConfirmatoryTest = requiresConfirmatoryTest
            self.receivedOnDay = receivedOnDay
            self.confirmedOnDay = confirmedOnDay
        }
    }
    
    var isolationTrigger: IsolationTrigger
    var onsetDay: GregorianDay?
    var testInfo: TestInfo?
}

extension IndexCaseInfo: Codable {
    enum CodingKeys: String, CodingKey {
        case npexDay
        case selfDiagnosisDay
        case onsetDay
        case testInfo
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let onsetDay = try container.decodeIfPresent(GregorianDay.self, forKey: .onsetDay)
        let testInfo = try container.decodeIfPresent(TestInfo.self, forKey: .testInfo)
        
        if let day = try container.decodeIfPresent(GregorianDay.self, forKey: .npexDay) {
            self.init(isolationTrigger: .manualTestEntry(npexDay: day), onsetDay: onsetDay, testInfo: testInfo)
            return
        }
        if let day = try container.decodeIfPresent(GregorianDay.self, forKey: .selfDiagnosisDay) {
            self.init(isolationTrigger: .selfDiagnosis(day), onsetDay: onsetDay, testInfo: testInfo)
            return
        }
        
        throw DecodingError.keyNotFound(
            CodingKeys.selfDiagnosisDay,
            DecodingError.Context(codingPath: container.codingPath, debugDescription: "Could not find self diagnosis day or npex day")
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(onsetDay, forKey: .onsetDay)
        try container.encodeIfPresent(testInfo, forKey: .testInfo)
        
        switch isolationTrigger {
        case .selfDiagnosis(let day):
            try container.encode(day, forKey: .selfDiagnosisDay)
        case .manualTestEntry(let npexDay):
            try container.encode(npexDay, forKey: .npexDay)
        }
    }
}

extension IndexCaseInfo {
    private static let assumedDaysFromOnsetToSelfDiagnosis = -2
    private static let assumedDaysFromOnsetToTestResult = -3
    
    var assumedOnsetDay: GregorianDay {
        if let onsetDay = onsetDay {
            return onsetDay
        } else {
            switch isolationTrigger {
            case .selfDiagnosis(let selfDiagnosisDay):
                return selfDiagnosisDay.advanced(by: Self.assumedDaysFromOnsetToSelfDiagnosis)
            case .manualTestEntry(let npexDay):
                return npexDay.advanced(by: Self.assumedDaysFromOnsetToTestResult)
            }
        }
    }
    
    mutating func set(testResult: TestResult, testKitType: TestKitType?, requiresConfirmatoryTest: Bool, receivedOn: GregorianDay) {
        testInfo = TestInfo(result: testResult, testKitType: testKitType, requiresConfirmatoryTest: requiresConfirmatoryTest, receivedOnDay: receivedOn)
    }
    
    mutating func confirmTest(confirmationDay: GregorianDay) {
        testInfo?.confirmedOnDay = confirmationDay
    }
}

public enum TestResult: String, Codable, Equatable {
    case positive
    case negative
    case void
    
    init(_ virologyTestResult: VirologyTestResult.TestResult) {
        switch virologyTestResult {
        case .positive:
            self = .positive
        case .negative:
            self = .negative
        case .void:
            self = .void
        }
    }
}

public enum TestKitType: String, Codable, Equatable {
    case labResult
    case rapidResult
    case rapidSelfReported
    
    init(_ virologyTestKit: VirologyTestResult.TestKitType) {
        switch virologyTestKit {
        case .labResult:
            self = .labResult
        case .rapidResult:
            self = .rapidResult
        case .rapidSelfReported:
            self = .rapidSelfReported
        }
    }
}

struct ContactCaseInfo: Codable, Equatable {
    var exposureDay: GregorianDay
    var isolationFromStartOfDay: GregorianDay
    
    private enum CodingKeys: String, CodingKey {
        case exposureDay
        case isolationFromStartOfDay
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        exposureDay = try container.decode(GregorianDay.self, forKey: .exposureDay)
        isolationFromStartOfDay = try container.decode(GregorianDay.self, forKey: .isolationFromStartOfDay)
    }
}

extension ContactCaseInfo {
    init(exposureDay: GregorianDay, isolationFromStartOfDay: GregorianDay) {
        self.exposureDay = exposureDay
        self.isolationFromStartOfDay = isolationFromStartOfDay
    }
}

// After experimenting with how best to deal with calendar related types, it feels like the right balance for this
// feature is to use `GregorianDay` to persistence (e.g. as part of `ContactCaseInfo`) but bring in time zone info
// any time we use this in memory.
//
// Based on that, we only use `_IsolationLogicalState` as an implementation detail since it makes testing more
// convenient.
enum IsolationLogicalState: Equatable {
    case notIsolating(finishedIsolationThatWeHaveNotDeletedYet: Isolation?)
    case isolating(Isolation, endAcknowledged: Bool, startAcknowledged: Bool)
    case isolationFinishedButNotAcknowledged(Isolation)
    
    init(today: LocalDay, info: IsolationInfo, configuration: IsolationConfiguration) {
        
        // Per-case isolations, range not truncated
        let _contactIsolation = info.contactCaseInfo.flatMap {
            _Isolation(contactCaseInfo: $0, configuration: configuration)
        }
        
        let _indexIsolation = info.indexCaseInfo.flatMap {
            _Isolation(indexCaseInfo: $0, configuration: configuration)
        }
        
        // overall isolation, range not truncated
        var _isolation: _Isolation
        switch (_contactIsolation, _indexIsolation) {
        case (.some(let c), .some(let i)):
            var positiveTestResult = false
            var selfDiagnosed = false
            var testType: TestKitType?
            var isPendingConfirmation = false
            if let indexCaseInfo = i.reason.indexCaseInfo {
                positiveTestResult = indexCaseInfo.hasPositiveTestResult
                selfDiagnosed = indexCaseInfo.isSelfDiagnosed
                testType = indexCaseInfo.testKitType
                isPendingConfirmation = indexCaseInfo.isPendingConfirmation
            }
            
            if i.untilStartOfDay <= today.gregorianDay && c.untilStartOfDay > today.gregorianDay {
                _isolation = c
            } else if c.untilStartOfDay <= today.gregorianDay && i.untilStartOfDay > today.gregorianDay {
                _isolation = i
            } else {
                _isolation = _Isolation(
                    fromDay: min(c.fromDay, i.fromDay),
                    untilStartOfDay: max(c.untilStartOfDay, i.untilStartOfDay),
                    reason: Isolation.Reason(
                        indexCaseInfo: IsolationIndexCaseInfo(
                            hasPositiveTestResult: positiveTestResult,
                            testKitType: testType,
                            isSelfDiagnosed: selfDiagnosed,
                            isPendingConfirmation: isPendingConfirmation
                        ),
                        isContactCase: true
                    )
                )
            }
            
        case (.some(let s), nil), (nil, .some(let s)):
            _isolation = s
        case (nil, nil):
            self = .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil)
            return
        }
        
        // reduce how long we can isolate
        _isolation.untilStartOfDay = min(_isolation.untilStartOfDay, _isolation.fromDay + configuration.maxIsolation)
        
        let isolation = Isolation(
            fromDay: LocalDay(gregorianDay: _isolation.fromDay, timeZone: today.timeZone),
            untilStartOfDay: LocalDay(gregorianDay: _isolation.untilStartOfDay, timeZone: today.timeZone),
            reason: _isolation.reason
        )
        
        if _isolation.untilStartOfDay > today.gregorianDay {
            self = .isolating(
                isolation,
                endAcknowledged: info.hasAcknowledgedEndOfIsolation,
                startAcknowledged: info.hasAcknowledgedStartOfIsolation
            )
        } else if info.hasAcknowledgedEndOfIsolation {
            self = .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: isolation)
        } else {
            self = .isolationFinishedButNotAcknowledged(isolation)
        }
    }
    
    init(stateInfo: IsolationStateInfo?, day: LocalDay) {
        guard let stateInfo = stateInfo else {
            self = .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil)
            return
        }
        
        self.init(
            today: day,
            info: stateInfo.isolationInfo,
            configuration: stateInfo.configuration
        )
    }
    
    var activeIsolation: Isolation? {
        switch self {
        case .notIsolating:
            return nil
        case .isolating(let isolation, _, _):
            return isolation
        case .isolationFinishedButNotAcknowledged:
            return nil
        }
    }
    
    var isInCorrectIsolationStateToApplyForFinancialSupport: Bool {
        guard let activeIsolation = activeIsolation else { return false }
        return activeIsolation.isContactCase && !activeIsolation.hasPositiveTestResult
    }
    
    var interestedInExposureNotifications: Bool {
        guard let activeIsolation = activeIsolation else { return true }
        return !activeIsolation.isContactCase && !activeIsolation.hasConfirmedPositiveTestResult
    }
    
    var isolation: Isolation? {
        switch self {
        case .notIsolating(let finishedIsolationThatWeHaveNotDeletedYet):
            return finishedIsolationThatWeHaveNotDeletedYet
        case .isolating(let isolation, _, _):
            return isolation
        case .isolationFinishedButNotAcknowledged(let isolation):
            return isolation
            
        }
    }
    
    var hasPendingTasks: Bool {
        switch self {
        case .notIsolating:
            return false
        case .isolating:
            return true
        case .isolationFinishedButNotAcknowledged:
            return true
        }
    }
    
    var isIsolating: Bool {
        switch self {
        case .isolating:
            return true
        case .notIsolating, .isolationFinishedButNotAcknowledged:
            return false
        }
    }
}

#warning("Consider a longer term solution that avoids making this type public")
struct _Isolation {
    var fromDay: GregorianDay
    var untilStartOfDay: GregorianDay
    var reason: Isolation.Reason
}

extension _Isolation {
    
    fileprivate init?(indexCaseInfo: IndexCaseInfo, configuration: IsolationConfiguration) {
        let isPendingConfirmation = indexCaseInfo.testInfo?.confirmationStatus == .pending
        switch (indexCaseInfo.onsetDay, indexCaseInfo.testInfo?.result, indexCaseInfo.isolationTrigger) {
        case (_, .negative, .manualTestEntry):
            return nil
        case (_, .void, .manualTestEntry):
            return nil
        case (_, .negative, .selfDiagnosis(_)):
            self.init(
                fromDay: indexCaseInfo.isolationTrigger.startDay,
                untilStartOfDay: indexCaseInfo.testInfo!.receivedOnDay,
                reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: indexCaseInfo.testInfo?.result == .positive, testKitType: indexCaseInfo.testInfo?.testKitType, isSelfDiagnosed: true, isPendingConfirmation: isPendingConfirmation), isContactCase: false)
            )
        case (.none, _, .selfDiagnosis(let selfDiagnosisDay)):
            self.init(
                fromDay: selfDiagnosisDay,
                untilStartOfDay: selfDiagnosisDay + configuration.indexCaseSinceSelfDiagnosisUnknownOnset,
                reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: indexCaseInfo.testInfo?.result == .positive, testKitType: indexCaseInfo.testInfo?.testKitType, isSelfDiagnosed: true, isPendingConfirmation: isPendingConfirmation), isContactCase: false)
            )
        case (.none, _, .manualTestEntry(let npexDay)):
            self.init(
                fromDay: npexDay,
                untilStartOfDay: npexDay + configuration.indexCaseSinceNPEXDayNoSelfDiagnosis,
                reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: indexCaseInfo.testInfo?.result == .positive, testKitType: indexCaseInfo.testInfo?.testKitType, isSelfDiagnosed: false, isPendingConfirmation: isPendingConfirmation), isContactCase: false)
            )
        case (.some(let day), _, .manualTestEntry(npexDay: _)):
            self.init(
                fromDay: indexCaseInfo.isolationTrigger.startDay,
                untilStartOfDay: day + configuration.indexCaseSinceSelfDiagnosisOnset,
                reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: indexCaseInfo.testInfo?.result == .positive, testKitType: indexCaseInfo.testInfo?.testKitType, isSelfDiagnosed: false, isPendingConfirmation: isPendingConfirmation), isContactCase: false)
            )
        case (.some(let day), _, .selfDiagnosis(_)):
            self.init(
                fromDay: indexCaseInfo.isolationTrigger.startDay,
                untilStartOfDay: day + configuration.indexCaseSinceSelfDiagnosisOnset,
                reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: indexCaseInfo.testInfo?.result == .positive, testKitType: indexCaseInfo.testInfo?.testKitType, isSelfDiagnosed: true, isPendingConfirmation: isPendingConfirmation), isContactCase: false)
            )
        }
    }
    
    /// Assuming `IndexCaseInfo` is `nil`
    init(contactCaseInfo: ContactCaseInfo, configuration: IsolationConfiguration) {
        self.init(
            fromDay: contactCaseInfo.isolationFromStartOfDay,
            untilStartOfDay: contactCaseInfo.exposureDay + configuration.contactCase,
            reason: Isolation.Reason(isContactCase: true)
        )
    }
    
}
