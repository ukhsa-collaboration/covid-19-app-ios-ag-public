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
        public var result: TestResult
        public var testKitType: TestKitType?
        public var receivedOnDay: GregorianDay
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
    
    mutating func set(testResult: TestResult, testKitType: TestKitType?, receivedOn: GregorianDay) {
        if testInfo?.result == .positive { return }
        
        testInfo = TestInfo(result: testResult, testKitType: testKitType, receivedOnDay: receivedOn)
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
    var trigger: ContactCaseTrigger
    
    private enum CodingKeys: String, CodingKey {
        case exposureDay
        case isolationFromStartOfDay
        case trigger
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        exposureDay = try container.decode(GregorianDay.self, forKey: .exposureDay)
        isolationFromStartOfDay = try container.decode(GregorianDay.self, forKey: .isolationFromStartOfDay)
        trigger = try container.decodeIfPresent(ContactCaseTrigger.self, forKey: .trigger) ?? .exposureDetection
    }
}

extension ContactCaseInfo {
    init(exposureDay: GregorianDay, isolationFromStartOfDay: GregorianDay, trigger: ContactCaseTrigger) {
        self.exposureDay = exposureDay
        self.isolationFromStartOfDay = isolationFromStartOfDay
        self.trigger = trigger
    }
}

public enum ContactCaseTrigger: String, Codable, Equatable {
    case exposureDetection
    case riskyVenue
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
            if case .indexCase(let hasPositiveTestResult, let testKitType, let hasSelfDiagnosed) = i.reason {
                positiveTestResult = hasPositiveTestResult
                selfDiagnosed = hasSelfDiagnosed
                testType = testKitType
            }
            
            if i.untilStartOfDay <= today.gregorianDay && c.untilStartOfDay > today.gregorianDay {
                _isolation = c
            } else if c.untilStartOfDay <= today.gregorianDay && i.untilStartOfDay > today.gregorianDay {
                _isolation = i
            } else {
                _isolation = _Isolation(
                    fromDay: min(c.fromDay, i.fromDay),
                    untilStartOfDay: max(c.untilStartOfDay, i.untilStartOfDay),
                    reason: .bothCases(hasPositiveTestResult: positiveTestResult, testkitType: testType, isSelfDiagnosed: selfDiagnosed)
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
        switch activeIsolation.reason {
        case .indexCase: return false
        case .contactCase: return true
        case .bothCases(let hasPositiveTestResult, _, _):
            return !hasPositiveTestResult
        }
    }
    
    var interestedInExposureNotifications: Bool {
        guard let activeIsolation = activeIsolation else { return true }
        switch activeIsolation.reason {
        case .bothCases, .contactCase:
            return false
        case .indexCase(let hasPositiveTestResult, _, _):
            return !hasPositiveTestResult
        }
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
        switch (indexCaseInfo.onsetDay, indexCaseInfo.testInfo?.result, indexCaseInfo.isolationTrigger) {
        case (_, .negative, .manualTestEntry):
            return nil
        case (_, .void, .manualTestEntry):
            return nil
        case (_, .negative, .selfDiagnosis(_)):
            self.init(
                fromDay: indexCaseInfo.isolationTrigger.startDay,
                untilStartOfDay: indexCaseInfo.testInfo!.receivedOnDay,
                reason: .indexCase(hasPositiveTestResult: false, testkitType: indexCaseInfo.testInfo?.testKitType, isSelfDiagnosed: true)
            )
        case (.none, _, .selfDiagnosis(let selfDiagnosisDay)):
            self.init(
                fromDay: selfDiagnosisDay,
                untilStartOfDay: selfDiagnosisDay + configuration.indexCaseSinceSelfDiagnosisUnknownOnset,
                reason: .indexCase(hasPositiveTestResult: indexCaseInfo.testInfo?.result == .positive, testkitType: indexCaseInfo.testInfo?.testKitType, isSelfDiagnosed: true)
            )
        case (.none, _, .manualTestEntry(let npexDay)):
            self.init(
                fromDay: npexDay,
                untilStartOfDay: npexDay + configuration.indexCaseSinceNPEXDayNoSelfDiagnosis,
                reason: .indexCase(hasPositiveTestResult: indexCaseInfo.testInfo?.result == .positive, testkitType: indexCaseInfo.testInfo?.testKitType, isSelfDiagnosed: false)
            )
        case (.some(let day), _, .manualTestEntry(npexDay: _)):
            self.init(
                fromDay: indexCaseInfo.isolationTrigger.startDay,
                untilStartOfDay: day + configuration.indexCaseSinceSelfDiagnosisOnset,
                reason: .indexCase(hasPositiveTestResult: indexCaseInfo.testInfo?.result == .positive, testkitType: indexCaseInfo.testInfo?.testKitType, isSelfDiagnosed: false)
            )
        case (.some(let day), _, .selfDiagnosis(_)):
            self.init(
                fromDay: indexCaseInfo.isolationTrigger.startDay,
                untilStartOfDay: day + configuration.indexCaseSinceSelfDiagnosisOnset,
                reason: .indexCase(hasPositiveTestResult: indexCaseInfo.testInfo?.result == .positive, testkitType: indexCaseInfo.testInfo?.testKitType, isSelfDiagnosed: true)
            )
        }
    }
    
    /// Assuming `IndexCaseInfo` is `nil`
    init(contactCaseInfo: ContactCaseInfo, configuration: IsolationConfiguration) {
        self.init(
            fromDay: contactCaseInfo.isolationFromStartOfDay,
            untilStartOfDay: contactCaseInfo.exposureDay + configuration.contactCase,
            reason: .contactCase(contactCaseInfo.trigger)
        )
    }
    
}
