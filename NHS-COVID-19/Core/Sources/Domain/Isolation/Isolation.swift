//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

// TODO: remove this in a non-functional PR later
typealias IsolationIndexCaseInfo = Isolation.IndexCaseInfo

public struct Isolation: Equatable {
    struct IndexCaseInfo: Equatable {
        var hasPositiveTestResult: Bool
        var testKitType: TestKitType?
        var isSelfDiagnosed: Bool
        var isPendingConfirmation: Bool
    }

    struct ContactCaseInfo: Equatable {
        var exposureDay: GregorianDay
    }

    public struct Reason: Equatable {
        var indexCaseInfo: IsolationIndexCaseInfo?
        var contactCaseInfo: Isolation.ContactCaseInfo?
    }

    public struct OptOutOfContactIsolationInfo: Equatable {
        var optOutDay: GregorianDay
        // This day would've been the potential end day for the contact isolation
        var untilStartOfDay: LocalDay
    }

    public var fromDay: LocalDay
    public var untilStartOfDay: LocalDay
    public var reason: Isolation.Reason

    public var optOutOfContactIsolationInfo: OptOutOfContactIsolationInfo?

    init(fromDay: LocalDay, untilStartOfDay: LocalDay, reason: Isolation.Reason, optOutOfContactIsolationInfo: OptOutOfContactIsolationInfo?) {
        self.fromDay = fromDay
        self.untilStartOfDay = untilStartOfDay
        self.reason = reason
        self.optOutOfContactIsolationInfo = optOutOfContactIsolationInfo
    }
}

extension Isolation {
    public var endDate: Date {
        untilStartOfDay.startOfDay
    }

    public var vaccineThresholdDate: Date? {
        reason.contactCaseInfo?.exposureDay.advanced(by: -15).startDate(in: .current)
    }

    public func birthThresholdDate(country: Country) -> Date? {
        switch country {
        case .england: return reason.contactCaseInfo?.exposureDay.advanced(by: -183).startDate(in: .current)
        case .wales: return reason.contactCaseInfo?.exposureDay.startDate(in: .current)
        }
    }

    public var exposureDate: Date? {
        reason.contactCaseInfo?.exposureDay.startDate(in: .current)
    }

    public func secondTestAdvice(dateProvider: DateProviding, country: Country) -> Date? {
        switch country {
        case .england: return nil
        case .wales:
            if let exposureDay = reason.contactCaseInfo?.exposureDay, dateProvider.currentGregorianDay(timeZone: .current) < exposureDay.advanced(by: 6) {
                return exposureDay.advanced(by: 8).startDate(in: .current)
            } else {
                return nil
            }
        }
    }
}

extension Isolation {
    public var canFillQuestionnaire: Bool {
        !isSelfDiagnosed
    }

    public var hasConfirmedPositiveTestResult: Bool {
        guard let indexCaseInfo = reason.indexCaseInfo else { return false }
        return indexCaseInfo.hasPositiveTestResult && !indexCaseInfo.isPendingConfirmation
    }

    public var isIndexCase: Bool {
        return reason.indexCaseInfo != nil
    }

    var isContactCase: Bool {
        return reason.contactCaseInfo != nil
    }

    var isContactCaseOnly: Bool {
        return isContactCase && !isIndexCase
    }

    public var hasPositiveTestResult: Bool {
        return reason.indexCaseInfo?.hasPositiveTestResult ?? false
    }

    var isSelfDiagnosed: Bool {
        return reason.indexCaseInfo?.isSelfDiagnosed ?? false
    }
}
