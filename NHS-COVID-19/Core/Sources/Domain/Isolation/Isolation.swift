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
        var optOutOfIsolationDay: GregorianDay?
    }
    
    public struct Reason: Equatable {
        var indexCaseInfo: IsolationIndexCaseInfo?
        var contactCaseInfo: Isolation.ContactCaseInfo?
    }
    
    public var fromDay: LocalDay
    public var untilStartOfDay: LocalDay
    public var reason: Isolation.Reason
    
    init(fromDay: LocalDay, untilStartOfDay: LocalDay, reason: Isolation.Reason) {
        self.fromDay = fromDay
        self.untilStartOfDay = untilStartOfDay
        self.reason = reason
    }
}

extension Isolation {
    public var endDate: Date {
        untilStartOfDay.startOfDay
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
