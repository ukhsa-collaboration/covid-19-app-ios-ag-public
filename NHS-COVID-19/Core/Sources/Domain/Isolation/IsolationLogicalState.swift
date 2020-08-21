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
    
    static let `default` = IsolationConfiguration(
        maxIsolation: 21,
        contactCase: 14,
        indexCaseSinceSelfDiagnosisOnset: 10,
        indexCaseSinceSelfDiagnosisUnknownOnset: 8,
        housekeepingDeletionPeriod: 14
    )
}

public struct IndexCaseInfo: Codable, Equatable {
    public struct TestInfo: Codable, Equatable {
        public var result: TestResult
        public var receivedOnDay: GregorianDay
    }
    
    var selfDiagnosisDay: GregorianDay
    var onsetDay: GregorianDay?
    var testInfo: TestInfo?
}

public enum TestResult: String, Codable, Equatable {
    case positive
    case negative
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
        switch (indexCaseInfo.onsetDay, indexCaseInfo.testInfo?.result) {
        case (_, .negative):
            self.init(fromDay: indexCaseInfo.selfDiagnosisDay, untilStartOfDay: indexCaseInfo.testInfo!.receivedOnDay, reason: .indexCase(hasPositiveTestResult: false))
        case (.none, _):
            self.init(fromDay: indexCaseInfo.selfDiagnosisDay, untilStartOfDay: indexCaseInfo.selfDiagnosisDay + configuration.indexCaseSinceSelfDiagnosisUnknownOnset, reason: .indexCase(hasPositiveTestResult: indexCaseInfo.testInfo?.result == .positive))
        case (.some(let day), _):
            self.init(fromDay: indexCaseInfo.selfDiagnosisDay, untilStartOfDay: day + configuration.indexCaseSinceSelfDiagnosisOnset, reason: .indexCase(hasPositiveTestResult: indexCaseInfo.testInfo?.result == .positive))
        }
    }
    
    /// Assuming `IndexCaseInfo` is `nil`
    fileprivate init?(contactCaseInfo: ContactCaseInfo, configuration: IsolationConfiguration) {
        self.init(fromDay: contactCaseInfo.isolationFromStartOfDay, untilStartOfDay: contactCaseInfo.exposureDay + configuration.contactCase, reason: .contactCase)
    }
    
}
