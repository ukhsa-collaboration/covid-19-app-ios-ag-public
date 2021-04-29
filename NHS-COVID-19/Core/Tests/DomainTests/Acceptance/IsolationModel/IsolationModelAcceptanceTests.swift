//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import TestSupport
import XCTest
import Domain
import BehaviourModels
@testable import Scenarios

@available(iOS 13.7, *)
/// Tests to ensure the app behaviour matches isolation model behaviour.
///
/// Each test in this class runs multiple scenarios based on valid states and transitions in the state model.
/// * The test will “pass” if all generated scenarios successfully run.
/// * The test will “fail” if even one scenario fails.
/// * The test will “skip” if at least one scenario is “not implemented”, but all “implemented” scenarios pass.
///
/// A scenario is considered  “not implemented” if failure is due to throwing an `IsolationModelUndefinedMappingError`.
class IsolationModelAcceptanceTests: AcceptanceTestCase {
    
    func testAppLoadsInitialIsolationStateCorrectly() throws {
        let adapter = IsolationModelAdapter()
        
        let reachableStates = IsolationModelCurrentRuleSet.reachableStates
        
        var skippedStates: [IsolationModel.State] = []
        
        for state in reachableStates {
            do {
                let storeRepresentations = try adapter.storeRepresentations(for: state)
                guard !storeRepresentations.isEmpty else {
                    throw TestError("`storeRepresentations` must not be empty. Throw an appropriate error to indicate why this is empty.")
                }
                
                for storeRepresentation in storeRepresentations {
                    resetInstance()
                    $instance.encryptedStore.stored["isolation_state_info"] = Data(storeRepresentation.utf8)
                    
                    try completeRunning()
                    
                    let context = try self.context()
                    try adapter.verify(context, isIn: state)
                }
            } catch is IsolationModelUndefinedMappingError {
                skippedStates.append(state)
            }
        }
        
        try XCTSkipIf(!skippedStates.isEmpty, "Skipped \(skippedStates.count) out of \(reachableStates.count) reachable states")
    }
}

private struct TestError: Error, CustomStringConvertible {
    var description: String
    
    init(_ description: String) {
        self.description = description
    }
}
