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
    var indexCaseSinceNPEXDayNoSelfDiagnosis: DayDuration = 10
    
    private enum CodingKeys: String, CodingKey {
        case maxIsolation
        case contactCase
        case indexCaseSinceSelfDiagnosisOnset
        case indexCaseSinceSelfDiagnosisUnknownOnset
        case housekeepingDeletionPeriod
    }
    
    static let `default` = IsolationConfiguration(
        maxIsolation: 21,
        contactCase: 14,
        indexCaseSinceSelfDiagnosisOnset: 10,
        indexCaseSinceSelfDiagnosisUnknownOnset: 8,
        housekeepingDeletionPeriod: 14
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
    
    mutating func set(testResult: TestResult, receivedOn: GregorianDay) {
        if testInfo?.result == .positive { return }
        
        testInfo = TestInfo(result: testResult, receivedOnDay: receivedOn)
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

struct ContactCaseInfo: Codable, Equatable {
    var exposureDay: GregorianDay
    var isolationFromStartOfDay: GregorianDay
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
            _isolation = _Isolation(
                fromDay: min(c.fromDay, i.fromDay),
                untilStartOfDay: max(c.untilStartOfDay, i.untilStartOfDay),
                reason: .bothCases
            )
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

private struct _Isolation {
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
        case (_, .negative, _):
            self.init(
                fromDay: indexCaseInfo.isolationTrigger.startDay,
                untilStartOfDay: indexCaseInfo.testInfo!.receivedOnDay,
                reason: .indexCase(hasPositiveTestResult: false)
            )
        case (.none, _, .selfDiagnosis(let selfDiagnosisDay)):
            self.init(
                fromDay: selfDiagnosisDay,
                untilStartOfDay: selfDiagnosisDay + configuration.indexCaseSinceSelfDiagnosisUnknownOnset,
                reason: .indexCase(hasPositiveTestResult: indexCaseInfo.testInfo?.result == .positive)
            )
        case (.none, _, .manualTestEntry(let npexDay)):
            self.init(
                fromDay: npexDay,
                untilStartOfDay: npexDay + configuration.indexCaseSinceNPEXDayNoSelfDiagnosis,
                reason: .indexCase(hasPositiveTestResult: indexCaseInfo.testInfo?.result == .positive)
            )
        case (.some(let day), _, let isolationTrigger):
            self.init(
                fromDay: isolationTrigger.startDay,
                untilStartOfDay: day + configuration.indexCaseSinceSelfDiagnosisOnset,
                reason: .indexCase(hasPositiveTestResult: indexCaseInfo.testInfo?.result == .positive)
            )
        }
    }
    
    /// Assuming `IndexCaseInfo` is `nil`
    fileprivate init?(contactCaseInfo: ContactCaseInfo, configuration: IsolationConfiguration) {
        self.init(fromDay: contactCaseInfo.isolationFromStartOfDay, untilStartOfDay: contactCaseInfo.exposureDay + configuration.contactCase, reason: .contactCase)
    }
    
}
