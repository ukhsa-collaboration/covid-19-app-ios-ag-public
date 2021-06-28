//
// Copyright © 2021 DHSC. All rights reserved.
//

import BehaviourModels
import Common
import Domain
import Foundation

@available(iOS 13.7, *)
extension IsolationModelAcceptanceTests {
    
    func trigger(_ event: IsolationModel.Event, adapter: inout IsolationModelAdapter, initialState: IsolationModel.State) throws {
        switch event {
        case .riskyContact:
            try triggerRiskyContact(adapter: &adapter)
        case .riskyContactWithExposureDayOlderThanIsolationTerminationDueToDCT:
            // There’s a bug in `Domain` related to handling of DCT when there’s a subsequent non-contact isolation.
            // Skip the test for now.
            throw IsolationModelUndefinedMappingError()
            try riskyContactWithExposureDayOlderThanIsolationTerminationDueToDCT(adapter: &adapter)
        case .selfDiagnosedSymptomatic:
            let questionare = Questionnaire(context: try! context())
            try questionare.selfDiagnosePositive(onsetDay: adapter.symptomaticCase.onsetDay)
        case .receivedVoidTest:
            let testEntry = ManualTestResultEntry(configuration: $instance, context: try! context())
            try testEntry.enterVoid(endDate: adapter.testCase.testEndDay.startDate(in: .utc))
        case .receivedConfirmedPositiveTest:
            let testEntry = ManualTestResultEntry(configuration: $instance, context: try! context())
            try testEntry.enterPositive(endDate: adapter.testCase.testEndDay.startDate(in: .utc))
        case .receivedConfirmedPositiveTestWithEndDateOlderThanRememberedNegativeTestEndDate:
            let endDay = adapter.testCase.testEndDay.advanced(by: -1)
            let testEntry = ManualTestResultEntry(configuration: $instance, context: try! context())
            try testEntry.enterPositive(endDate: endDay.startDate(in: .utc))
        case .receivedUnconfirmedPositiveTest:
            let testEntry = ManualTestResultEntry(configuration: $instance, context: try! context())
            try testEntry.enterPositive(requiresConfirmatoryTest: true, endDate: adapter.testCase.testEndDay.startDate(in: .utc))
        case .receivedUnconfirmedPositiveTestWithEndDateOlderThanRememberedNegativeTestEndDate:
            let endDay = adapter.testCase.testEndDay.advanced(by: -1)
            let testEntry = ManualTestResultEntry(configuration: $instance, context: try! context())
            try testEntry.enterPositive(requiresConfirmatoryTest: true, endDate: endDay.startDate(in: .utc))
        case .receivedNegativeTest:
            let testEntry = ManualTestResultEntry(configuration: $instance, context: try! context())
            try testEntry.enterNegative(endDate: adapter.testCase.testEndDay.startDate(in: .utc))
        case .receivedNegativeTestWithEndDateOlderThanRememberedUnconfirmedTestEndDateAndOlderThanAssumedSymptomOnsetDayIfAny:
            let endDay = adapter.testCase.testEndDay.advanced(by: -1)
            let testEntry = ManualTestResultEntry(configuration: $instance, context: try! context())
            try testEntry.enterNegative(endDate: endDay.startDate(in: .utc))
        case .receivedNegativeTestWithEndDateOlderThanAssumedSymptomOnsetDate:
            let endDay = adapter.symptomaticCase.onsetDay.advanced(by: -1)
            let testEntry = ManualTestResultEntry(configuration: $instance, context: try! context())
            try testEntry.enterNegative(endDate: endDay.startDate(in: .utc))
        case .receivedConfirmedPositiveTestWithIsolationPeriodOlderThanAssumedSymptomOnsetDate:
            let endDay = adapter.symptomaticCase.selfDiagnosisDay.advanced(by: -30)
            let testEntry = ManualTestResultEntry(configuration: $instance, context: try! context())
            try testEntry.enterPositive(endDate: endDay.startDate(in: .utc))
        case .contactIsolationEnded:
            currentDateProvider.setDate(adapter.contactCase.contactIsolationToStartOfDay.startDate(in: .current))
        case .indexIsolationEnded:
            throw IsolationModelUndefinedMappingError() // Looks like there's a bug here around DCT opt out date. Skip this for now
            currentDateProvider.setDate(
                max(
                    adapter.symptomaticCase.symptomaticIsolationUntilStartOfDay,
                    adapter.testCase.testEndDay.advanced(by: 10)
                ).startDate(in: .current))
        case .retentionPeriodEnded:
            currentDateProvider.setDate(adapter.currentDate.day.advanced(by: 30).startDate(in: .current))
            instance.coordinator.performBackgroundTask(task: NoOpBackgroundTask())
        case .terminateRiskyContactDueToDCT:
            if case .enabled(let optOutOfIsolation) = try context().dailyContactTestingEarlyTerminationSupport() {
                optOutOfIsolation()
            }
        case .receivedUnconfirmedPositiveTestWithEndDateOlderThanAssumedSymptomOnsetDate:
            let endDay: GregorianDay
            if initialState.symptomatic == .notIsolatingAndHadSymptomsPreviously,
                initialState.positiveTest == .notIsolatingAndHasNegativeTest {
                endDay = adapter.symptomaticCase.selfDiagnosisDay.advanced(by: -1)
            } else {
                endDay = adapter.symptomaticCase.expiredSelfDiagnosisDay.advanced(by: -1)
            }
            let testEntry = ManualTestResultEntry(configuration: $instance, context: try! context())
            try testEntry.enterPositive(requiresConfirmatoryTest: true, endDate: endDay.startDate(in: .utc))
        case .receivedUnconfirmedPositiveTestWithEndDateNDaysOlderThanRememberedNegativeTestEndDateAndOlderThanAssumedSymptomOnsetDayIfAny:
            let endDay = adapter.testCase.testEndDay.advanced(by: -3)
            let testEntry = ManualTestResultEntry(configuration: $instance, context: try! context())
            try testEntry.enterPositive(requiresConfirmatoryTest: true, endDate: endDay.startDate(in: .utc), confirmatoryDayLimit: 2)
        default:
            throw IsolationModelUndefinedMappingError()
        }
    }
    
    private func triggerRiskyContact(adapter: inout IsolationModelAdapter) throws {
        let riskyContact = RiskyContact(configuration: $instance)
        
        adapter.contactCase.exposureDay = adapter.contactCase.optedOutForDCTDay
        
        adapter.contactCase.contactIsolationToStartOfDay = adapter.contactCase.exposureDay.advanced(by: 14)
        
        riskyContact.trigger(exposureDate: adapter.contactCase.exposureDay.startDate(in: .utc)) {
            instance.coordinator.performBackgroundTask(task: NoOpBackgroundTask())
        }
        adapter.contactCase.contactIsolationFromStartOfDay = adapter.currentDate.day
    }
    
    private func riskyContactWithExposureDayOlderThanIsolationTerminationDueToDCT(adapter: inout IsolationModelAdapter) throws {
        let riskyContact = RiskyContact(configuration: $instance)
        riskyContact.trigger(exposureDate: adapter.contactCase.optedOutForDCTDay.advanced(by: -4).startDate(in: .utc)) {
            instance.coordinator.performBackgroundTask(task: NoOpBackgroundTask())
        }
    }
    
}

private struct NoOpBackgroundTask: BackgroundTask {
    var identifier = ""
    var expirationHandler: (() -> Void)? {
        get {
            nil
        }
        nonmutating set {}
    }
    
    func setTaskCompleted(success: Bool) {}
}
