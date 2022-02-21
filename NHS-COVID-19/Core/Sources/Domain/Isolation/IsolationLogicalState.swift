//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation

struct IsolationInfo: Equatable {
    var hasAcknowledgedEndOfIsolation: Bool = false
    var hasAcknowledgedStartOfContactIsolation: Bool = false
    var indexCaseInfo: IndexCaseInfo?
    var contactCaseInfo: ContactCaseInfo?
    
    var isolationStartDay: GregorianDay? {
        switch (indexCaseInfo?.isolationStartDay, contactCaseInfo?.exposureDay) {
        case (.none, .none): return nil
        case (.some(let indexIsolationStartDay), .some(let exposureDay)): return min(indexIsolationStartDay, exposureDay)
        case (.some(let indexIsolationStartDay), .none): return indexIsolationStartDay
        case (.none, .some(let exposureDay)): return exposureDay
        }
    }
}

public struct IndexCaseInfo: Equatable {
    enum IsolationTrigger: Equatable {
        case selfDiagnosis(GregorianDay)
        #warning("Remove npexDay parameter from here as we are now storing testEndDay in TestInfo.")
        case manualTestEntry(npexDay: GregorianDay)
    }
    
    public struct TestInfo: Equatable {
        
        public enum ConfirmationStatus: Equatable {
            case pending
            case confirmed(onDay: GregorianDay)
            case notRequired
        }
        
        public enum CompletionStatus: Equatable {
            case pending
            case completed(onDay: GregorianDay)
            case notRequired
        }
        
        public var result: TestResult
        public var testKitType: TestKitType?
        public var requiresConfirmatoryTest: Bool
        public var shouldOfferFollowUpTest: Bool
        public var confirmatoryDayLimit: Int?
        public var receivedOnDay: GregorianDay
        public var confirmedOnDay: GregorianDay?
        #warning("completed on day would be same as confirmed on day when not nil. Refactor to make it comiler safe.")
        public var completedOnDay: GregorianDay?
        public var testEndDay: GregorianDay?
        
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
        
        public var completionStatus: CompletionStatus {
            if !shouldOfferFollowUpTest {
                return .notRequired
            } else if requiresConfirmatoryTest {
                if let completedOnDay = completedOnDay {
                    return .completed(onDay: completedOnDay)
                } else {
                    return .pending
                }
            } else {
                return .notRequired
            }
        }
        
        public init(
            result: TestResult,
            testKitType: TestKitType? = nil,
            requiresConfirmatoryTest: Bool,
            shouldOfferFollowUpTest: Bool,
            confirmatoryDayLimit: Int? = nil,
            receivedOnDay: GregorianDay,
            confirmedOnDay: GregorianDay? = nil,
            completedOnDay: GregorianDay? = nil,
            testEndDay: GregorianDay?
        ) {
            self.result = result
            self.testKitType = testKitType
            self.requiresConfirmatoryTest = requiresConfirmatoryTest
            self.shouldOfferFollowUpTest = shouldOfferFollowUpTest
            self.confirmatoryDayLimit = confirmatoryDayLimit
            self.receivedOnDay = receivedOnDay
            self.confirmedOnDay = confirmedOnDay
            self.completedOnDay = completedOnDay
            self.testEndDay = testEndDay
        }
    }
    
    public struct SymptomaticInfo: Equatable {
        private static let assumedDaysFromOnsetToSelfDiagnosis = -2
        
        var selfDiagnosisDay: GregorianDay
        var onsetDay: GregorianDay?
        
        var assumedOnsetDay: GregorianDay {
            if let onsetDay = onsetDay {
                return onsetDay
            } else {
                return selfDiagnosisDay.advanced(by: Self.assumedDaysFromOnsetToSelfDiagnosis)
            }
        }
    }
    
    // **Important**: These properties must be `let` to preserve invariants.
    // Any changes should go through `init`.
    let isolationTrigger: IsolationTrigger
    let symptomaticInfo: SymptomaticInfo?
    let testInfo: TestInfo?
    
    #warning("Refine this collection of init methods")
    // When creating `IndexCaseInfo`, at least one of `symptomaticInfo` or `testInfo` must not be nil.
    // Instead of considering that a precondition, we enforce this by requiring at least one of these no be non-optional.
    // Otherwise, we’ll return an optional response.
    //
    // This improves type-safety for now whilst we refactor other parts of the app. We should revisit this when we
    // change this type, e.g. to remove `IsolationTrigger` or even the whole `IndexCaseInfo` type.
    init?(
        symptomaticInfo: SymptomaticInfo?,
        testInfo: IndexCaseInfo.TestInfo?
    ) {
        if let symptomaticInfo = symptomaticInfo {
            isolationTrigger = .selfDiagnosis(symptomaticInfo.selfDiagnosisDay)
        } else if let testEndDay = testInfo?.testEndDay {
            isolationTrigger = .manualTestEntry(npexDay: testEndDay)
        } else {
            return nil
        }
        self.symptomaticInfo = symptomaticInfo
        self.testInfo = testInfo
    }
    
    init(
        symptomaticInfo: SymptomaticInfo,
        testInfo: IndexCaseInfo.TestInfo?
    ) {
        self.init(symptomaticInfo: symptomaticInfo as SymptomaticInfo?, testInfo: testInfo as IndexCaseInfo.TestInfo?)!
    }
    
    init(
        symptomaticInfo: SymptomaticInfo?,
        testInfo: IndexCaseInfo.TestInfo
    ) {
        self.init(symptomaticInfo: symptomaticInfo as SymptomaticInfo?, testInfo: testInfo as IndexCaseInfo.TestInfo?)!
    }
    
    init(
        symptomaticInfo: SymptomaticInfo,
        testInfo: IndexCaseInfo.TestInfo
    ) {
        self.init(symptomaticInfo: symptomaticInfo as SymptomaticInfo?, testInfo: testInfo as IndexCaseInfo.TestInfo?)!
    }
}

extension IndexCaseInfo {
    
    var startDay: GregorianDay {
        switch isolationTrigger {
        case .selfDiagnosis(let day):
            return day
        case .manualTestEntry(let npexDay):
            return npexDay
        }
    }
    
    var isolationStartDay: GregorianDay? {
        switch isolationTrigger {
        case .selfDiagnosis(let day):
            return day
        case .manualTestEntry(let npexDay):
            return testInfo?.result == .positive ? npexDay : nil
        }
    }
}

extension IndexCaseInfo {
    
    var assumedOnsetDayForExposureKeys: GregorianDay {
        if let onsetDay = symptomaticInfo?.assumedOnsetDay {
            if let testEndDay = testInfo?.testEndDay, testEndDay < onsetDay {
                return testEndDay
            } else {
                return onsetDay
            }
        } else {
            #warning("This is very risky. There's no indication that from the two parameters passed one must be non-null")
            return testInfo!.testEndDay!
        }
    }
    
    var assumedTestEndDay: GregorianDay? {
        switch isolationTrigger {
        case .selfDiagnosis:
            return testInfo?.testEndDay ?? testInfo?.receivedOnDay
        case .manualTestEntry(let npexDay):
            return npexDay
        }
    }
    
    var isConsideredSymptomatic: Bool {
        if case .selfDiagnosis = isolationTrigger, testInfo?.result != .negative {
            return true
        } else {
            return false
        }
    }
    
    var hasBecomeSymptomaticAfterPositive: Bool {
        if let assumedOnsetDay = symptomaticInfo?.assumedOnsetDay,
            testInfo?.result == .positive,
            let testEndDay = assumedTestEndDay,
            assumedOnsetDay > testEndDay {
            return true
        } else {
            return false
        }
    }
    
    var isInterestedInAskingForSymptomsOnsetDay: Bool {
        if isConsideredSymptomatic || testInfo?.result == .positive {
            return false
        } else {
            return true
        }
    }
    
    mutating func confirmTest(confirmationDay: GregorianDay) {
        updateExistingTestInfo {
            $0.confirmedOnDay = confirmationDay
            $0.completedOnDay = confirmationDay
        }
    }
    
    mutating func completeTest(completedOnDay: GregorianDay) {
        updateExistingTestInfo {
            $0.completedOnDay = completedOnDay
        }
    }
    
    private mutating func updateExistingTestInfo(with mutator: (inout TestInfo) -> Void) {
        guard let testInfo = testInfo else { return }
        self = IndexCaseInfo(
            symptomaticInfo: symptomaticInfo,
            testInfo: mutating(testInfo, with: mutator)
        )
    }
}

struct ContactCaseInfo: Equatable {
    var exposureDay: GregorianDay
    var isolationFromStartOfDay: GregorianDay
    var optOutOfIsolationDay: GregorianDay?
}

// After experimenting with how best to deal with calendar related types, it feels like the right balance for this
// feature is to use `GregorianDay` to persistence (e.g. as part of `ContactCaseInfo`) but bring in time zone info
// any time we use this in memory.
//
// Based on that, we only use `_IsolationLogicalState` as an implementation detail since it makes testing more
// convenient.
enum IsolationLogicalState: Equatable {
    case notIsolating(finishedIsolationThatWeHaveNotDeletedYet: Isolation?)
    case isolating(Isolation, endAcknowledged: Bool, startOfContactIsolationAcknowledged: Bool)
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
                        contactCaseInfo: c.reason.contactCaseInfo
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
        
        let contactCaseOptOutInfo: Isolation.OptOutOfContactIsolationInfo? = info.contactCaseInfo.flatMap { contactCaseInfo in
            guard let optOutDay = contactCaseInfo.optOutOfIsolationDay else { return nil }
            let untilStartOfDay = _Isolation.calculateContactCaseEndDay(exposureDay: contactCaseInfo.exposureDay, contactCaseDuration: configuration.contactCase)
            return Isolation.OptOutOfContactIsolationInfo(
                optOutDay: optOutDay,
                untilStartOfDay: LocalDay(gregorianDay: untilStartOfDay, timeZone: today.timeZone)
            )
        }
        
        let isolation = Isolation(
            fromDay: LocalDay(gregorianDay: _isolation.fromDay, timeZone: today.timeZone),
            untilStartOfDay: LocalDay(gregorianDay: _isolation.untilStartOfDay, timeZone: today.timeZone),
            reason: _isolation.reason,
            optOutOfContactIsolationInfo: contactCaseOptOutInfo
        )
        
        if _isolation.untilStartOfDay > today.gregorianDay {
            self = .isolating(
                isolation,
                endAcknowledged: info.hasAcknowledgedEndOfIsolation,
                startOfContactIsolationAcknowledged: info.hasAcknowledgedStartOfContactIsolation
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
        switch exposureNotificationProcessingBehaviour {
        case .allExposures, .onlyProcessExposuresOnOrAfter:
            return true
        case .doNotProcessExposures:
            return false
        }
    }
    
    var exposureNotificationProcessingBehaviour: ExposureNotificationProcessingBehaviour {
        if let activeIsolation = activeIsolation {
            if activeIsolation.isContactCase || activeIsolation.hasConfirmedPositiveTestResult {
                return .doNotProcessExposures
            }
        }
        if let optOutDay = isolation?.optOutOfContactIsolationInfo?.optOutDay {
            return .onlyProcessExposuresOnOrAfter(optOutDay)
        }
        return .allExposures
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

public enum ExposureNotificationProcessingBehaviour: Equatable {
    case allExposures
    case onlyProcessExposuresOnOrAfter(GregorianDay)
    case doNotProcessExposures
    
    func shouldNotifyForExposure(on exposureDay: GregorianDay,
                                 currentDateProvider: DateProviding,
                                 isolationLength: DayDuration) -> Bool {
        // Don't notify for exposures where the resultant isolation is already finished.
        let today = currentDateProvider.currentGregorianDay(timeZone: .current)
        guard today - isolationLength < exposureDay else {
            return false
        }
        
        switch self {
        case .allExposures:
            return true
        case .onlyProcessExposuresOnOrAfter(let contactCaseOptOutDate):
            return exposureDay > contactCaseOptOutDate
        case .doNotProcessExposures:
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
        switch (indexCaseInfo.symptomaticInfo?.onsetDay, indexCaseInfo.testInfo?.result, indexCaseInfo.isolationTrigger) {
        case (_, .negative, .manualTestEntry):
            return nil
        case (_, .negative, .selfDiagnosis(_)):
            self.init(
                fromDay: indexCaseInfo.startDay,
                untilStartOfDay: indexCaseInfo.testInfo!.receivedOnDay,
                reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: indexCaseInfo.testInfo?.result == .positive, testKitType: indexCaseInfo.testInfo?.testKitType, isSelfDiagnosed: true, isPendingConfirmation: isPendingConfirmation), contactCaseInfo: nil)
            )
        case (.none, _, .selfDiagnosis(let selfDiagnosisDay)):
            self.init(
                fromDay: selfDiagnosisDay,
                untilStartOfDay: selfDiagnosisDay + configuration.indexCaseSinceSelfDiagnosisUnknownOnset,
                reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: indexCaseInfo.testInfo?.result == .positive, testKitType: indexCaseInfo.testInfo?.testKitType, isSelfDiagnosed: true, isPendingConfirmation: isPendingConfirmation), contactCaseInfo: nil)
            )
        case (.none, _, .manualTestEntry(let npexDay)):
            self.init(
                fromDay: npexDay,
                untilStartOfDay: npexDay + configuration.indexCaseSinceNPEXDayNoSelfDiagnosis,
                reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: indexCaseInfo.testInfo?.result == .positive, testKitType: indexCaseInfo.testInfo?.testKitType, isSelfDiagnosed: false, isPendingConfirmation: isPendingConfirmation), contactCaseInfo: nil)
            )
        case (.some(let day), _, .manualTestEntry(npexDay: _)):
            self.init(
                fromDay: indexCaseInfo.startDay,
                untilStartOfDay: day + configuration.indexCaseSinceSelfDiagnosisOnset,
                reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: indexCaseInfo.testInfo?.result == .positive, testKitType: indexCaseInfo.testInfo?.testKitType, isSelfDiagnosed: false, isPendingConfirmation: isPendingConfirmation), contactCaseInfo: nil)
            )
        case (.some(let day), _, .selfDiagnosis(_)):
            self.init(
                fromDay: indexCaseInfo.startDay,
                untilStartOfDay: day + configuration.indexCaseSinceSelfDiagnosisOnset,
                reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: indexCaseInfo.testInfo?.result == .positive, testKitType: indexCaseInfo.testInfo?.testKitType, isSelfDiagnosed: true, isPendingConfirmation: isPendingConfirmation), contactCaseInfo: nil)
            )
        }
    }
    
    /// Assuming `IndexCaseInfo` is `nil`
    init(contactCaseInfo: ContactCaseInfo, configuration: IsolationConfiguration) {
        let isolationContactCaseInfo = Isolation.ContactCaseInfo(exposureDay: contactCaseInfo.exposureDay)
        if let optOutOfIsolationDay = contactCaseInfo.optOutOfIsolationDay {
            self.init(
                fromDay: contactCaseInfo.isolationFromStartOfDay,
                untilStartOfDay: optOutOfIsolationDay,
                reason: Isolation.Reason(indexCaseInfo: nil, contactCaseInfo: isolationContactCaseInfo)
            )
        } else {
            self.init(
                fromDay: contactCaseInfo.isolationFromStartOfDay,
                untilStartOfDay: Self.calculateContactCaseEndDay(exposureDay: contactCaseInfo.exposureDay, contactCaseDuration: configuration.contactCase),
                reason: Isolation.Reason(indexCaseInfo: nil, contactCaseInfo: isolationContactCaseInfo)
            )
        }
    }
    
    static func calculateContactCaseEndDay(exposureDay: GregorianDay, contactCaseDuration: DayDuration) -> GregorianDay {
        return exposureDay + contactCaseDuration
    }
    
}
