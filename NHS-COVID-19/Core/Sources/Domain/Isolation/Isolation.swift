//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

public struct Isolation: Equatable {
    public enum Reason: Equatable {
        case indexCase(hasPositiveTestResult: Bool, testkitType: TestKitType?, isSelfDiagnosed: Bool)
        case contactCase(ContactCaseTrigger)
        case bothCases(hasPositiveTestResult: Bool, testkitType: TestKitType?, isSelfDiagnosed: Bool)
    }
    
    public var fromDay: LocalDay
    public var untilStartOfDay: LocalDay
    public var reason: Reason
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
    
    public var isIndexCase: Bool {
        switch reason {
        case .indexCase, .bothCases:
            return true
        case .contactCase:
            return false
        }
    }
    
    var isContactCase: Bool {
        switch reason {
        case .indexCase:
            return false
        case .contactCase, .bothCases:
            return true
        }
    }
    
    var isContactCaseOnly: Bool {
        switch reason {
        case .indexCase, .bothCases:
            return false
        case .contactCase:
            return true
        }
    }
    
    var isIndexCaseOnlyWithPositiveTest: Bool {
        if case .indexCase(hasPositiveTestResult: true, testkitType: _, isSelfDiagnosed: _) = reason {
            return true
        }
        return false
    }
}
