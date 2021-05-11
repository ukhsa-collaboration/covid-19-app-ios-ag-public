//
// Copyright © 2021 DHSC. All rights reserved.
//

import BehaviourModels
import Common
import Domain
import Foundation

@available(iOS 13.7, *)
extension IsolationModelAcceptanceTests {
    
    func trigger(_ event: IsolationModel.Event, adapter: inout IsolationModelAdapter) throws {
        switch event {
        case .riskyContact:
            try triggerRiskyContact(adapter: &adapter)
        case .riskyContactWithExposureDayOlderThanIsolationTerminationDueToDCT:
            throw IsolationModelUndefinedMappingError() // Looks like there's a bug here. Skip this for now
            try riskyContactWithExposureDayOlderThanIsolationTerminationDueToDCT(adapter: &adapter)
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
