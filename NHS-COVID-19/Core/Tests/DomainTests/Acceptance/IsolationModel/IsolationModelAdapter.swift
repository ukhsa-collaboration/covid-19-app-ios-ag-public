//
// Copyright © 2021 DHSC. All rights reserved.
//

import BehaviourModels
import Common
import Foundation
@testable import Domain

struct IsolationModelAdapter {
    var currentDate = UTCHour(year: 2020, month: 10, day: 15, hour: 9)
    var contactCase = ContactCase()
    var indexCase = IndexCase()
    var testCase = TestCase()
    
    struct ContactCase {
        var exposureDay: GregorianDay
        var contactIsolationFromStartOfDay: GregorianDay
        var optedOutForDCTDay: GregorianDay
        var optedOutForDCTDate: Date
        
        var expiredExposureDay: GregorianDay
        var expiredIsolationFromStartOfDay: GregorianDay
        
        var contactIsolationToStartOfDay: GregorianDay
        
        init() {
            exposureDay = GregorianDay(year: 2020, month: 10, day: 10)
            
            contactIsolationFromStartOfDay = GregorianDay(year: 2020, month: 10, day: 11)
            contactIsolationToStartOfDay = GregorianDay(year: 2020, month: 10, day: 24)
            
            optedOutForDCTDay = GregorianDay(year: 2020, month: 10, day: 12)
            optedOutForDCTDate = optedOutForDCTDay.startDate(in: .current)
            
            expiredExposureDay = GregorianDay(year: 2020, month: 9, day: 26)
            expiredIsolationFromStartOfDay = GregorianDay(year: 2020, month: 9, day: 27)
        }
    }
    
    struct IndexCase {
        var selfDiagnosisDay: GregorianDay
        var onsetDay: GregorianDay
        
        var expiredSelfDiagnosisDay: GregorianDay
        
        var indexIsolationUntilStartOfDay: GregorianDay
        
        init() {
            selfDiagnosisDay = GregorianDay(year: 2020, month: 10, day: 11)
            expiredSelfDiagnosisDay = GregorianDay(year: 2020, month: 10, day: 4)
            onsetDay = GregorianDay(year: 2020, month: 10, day: 10)
            indexIsolationUntilStartOfDay = GregorianDay(year: 2020, month: 10, day: 17)
        }
    }
    
    struct TestCase {
        var testEndDay: GregorianDay
        var receivedOnDay: GregorianDay
        
        var expiredTestEndDay: GregorianDay
        var expiredReceivedOnDay: GregorianDay
        
        init() {
            testEndDay = GregorianDay(year: 2020, month: 10, day: 12)
            receivedOnDay = GregorianDay(year: 2020, month: 10, day: 14)
            
            expiredTestEndDay = GregorianDay(year: 2020, month: 10, day: 1)
            expiredReceivedOnDay = GregorianDay(year: 2020, month: 10, day: 3)
        }
    }
    
    var contactCaseIsolation: Isolation {
        Isolation(
            fromDay: LocalDay(gregorianDay: contactCase.contactIsolationFromStartOfDay, timeZone: .current),
            untilStartOfDay: LocalDay(gregorianDay: contactCase.contactIsolationToStartOfDay, timeZone: .current),
            reason: .init(
                indexCaseInfo: nil,
                contactCaseInfo: Isolation.ContactCaseInfo()
            )
        )
    }
    
    var indexCaseIsolation: Isolation {
        Isolation(
            fromDay: LocalDay(gregorianDay: indexCase.selfDiagnosisDay, timeZone: .current),
            untilStartOfDay: LocalDay(gregorianDay: indexCase.indexIsolationUntilStartOfDay, timeZone: .current),
            reason: .init(
                indexCaseInfo: IsolationIndexCaseInfo(
                    hasPositiveTestResult: false,
                    testKitType: nil,
                    isSelfDiagnosed: true,
                    isPendingConfirmation: false
                ),
                contactCaseInfo: nil
            )
        )
    }
    
    private func bothCasesFromDay(isSelfDiagnosed: Bool) -> GregorianDay {
        if isSelfDiagnosed {
            return min(contactCase.contactIsolationFromStartOfDay, indexCase.selfDiagnosisDay)
        } else {
            return min(contactCase.contactIsolationFromStartOfDay, testCase.testEndDay)
        }
    }
    
    func bothCasesIsolation(
        hasPositiveTestResult: Bool = false,
        isPendingConfirmation: Bool = false,
        isSelfDiagnosed: Bool = true
    ) -> Isolation {
        Isolation(
            fromDay: LocalDay(gregorianDay: bothCasesFromDay(isSelfDiagnosed: isSelfDiagnosed), timeZone: .current),
            untilStartOfDay: LocalDay(gregorianDay: contactCase.contactIsolationToStartOfDay, timeZone: .current),
            reason: .init(
                indexCaseInfo: IsolationIndexCaseInfo(
                    hasPositiveTestResult: hasPositiveTestResult,
                    testKitType: nil,
                    isSelfDiagnosed: isSelfDiagnosed,
                    isPendingConfirmation: isPendingConfirmation
                ),
                contactCaseInfo: Isolation.ContactCaseInfo()
            )
        )
    }
    
    func indexCasePositiveTestIsolation(
        isPendingConfirmation: Bool = false,
        isSelfDiagnosed: Bool = false
    ) -> Isolation {
        let fromDay: LocalDay
        let untilStartOfDay: LocalDay
        
        if isSelfDiagnosed {
            fromDay = LocalDay(gregorianDay: indexCase.selfDiagnosisDay, timeZone: .current)
            untilStartOfDay = fromDay.advanced(by: 5)
        } else {
            fromDay = LocalDay(gregorianDay: testCase.testEndDay, timeZone: .current)
            untilStartOfDay = fromDay.advanced(by: 10)
        }
        
        return Isolation(
            fromDay: fromDay,
            untilStartOfDay: untilStartOfDay,
            reason: .init(
                indexCaseInfo: IsolationIndexCaseInfo(
                    hasPositiveTestResult: true,
                    testKitType: nil,
                    isSelfDiagnosed: isSelfDiagnosed,
                    isPendingConfirmation: isPendingConfirmation
                ),
                contactCaseInfo: nil
            )
        )
    }
}
