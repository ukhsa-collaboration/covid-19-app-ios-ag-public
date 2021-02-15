//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct IsolationIndexCaseInfo: Equatable {
    var hasPositiveTestResult: Bool
    var testKitType: TestKitType?
    var isSelfDiagnosed: Bool
    var isPendingConfirmation: Bool
}

public struct Isolation: Equatable {
    struct Reason: Equatable {
        var indexCaseInfo: IsolationIndexCaseInfo?
        var isContactCase: Bool
    }
    
    public var fromDay: LocalDay
    public var untilStartOfDay: LocalDay
    var reason: Isolation.Reason
    
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
    public var canBookTest: Bool {
        isIndexCase
    }
    
    public var canFillQuestionnaire: Bool {
        !isIndexCase
    }
    
    public var hasConfirmedPositiveTestResult: Bool {
        guard let indexCaseInfo = reason.indexCaseInfo else { return false }
        return indexCaseInfo.hasPositiveTestResult && !indexCaseInfo.isPendingConfirmation
    }
    
    public var isIndexCase: Bool {
        return reason.indexCaseInfo != nil
    }
    
    var isContactCase: Bool {
        return reason.isContactCase
    }
    
    var isContactCaseOnly: Bool {
        return isContactCase && !isIndexCase
    }
    
    var hasPositiveTestResult: Bool {
        return reason.indexCaseInfo?.hasPositiveTestResult ?? false
    }
}
