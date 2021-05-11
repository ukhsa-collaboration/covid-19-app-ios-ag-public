//
// Copyright © 2021 DHSC. All rights reserved.
//

import BehaviourModels
import Combine
import Common
import Domain
import TestSupport
import XCTest
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
    
    func setUpInstance(with adapter: IsolationModelAdapter) {
        currentDateProvider.setDate(adapter.currentDate.date)
    }
    
    /// Tests that after storing each reachable state, we can verify the app is in that state
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
                    setUpInstance(with: adapter)
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
    
    /// Tests that after storing each reachable state, and triggering each possible event for that state, the app reaches the correct state.
    func testAppHasCorrectTransitions() throws {
        let adapter = IsolationModelAdapter()
        
        let validTransitions = IsolationModelCurrentRuleSet.validTransitions
        
        var skippedTransitions: [IsolationModel.Transition] = []
        
        for transition in validTransitions {
            do {
                let storeRepresentations = try adapter.storeRepresentations(for: transition.initialState)
                guard !storeRepresentations.isEmpty else {
                    throw TestError("`storeRepresentations` must not be empty. Throw an appropriate error to indicate why this is empty.")
                }
                
                for storeRepresentation in storeRepresentations {
                    var caseAdapter = adapter
                    resetInstance()
                    setUpInstance(with: adapter)
                    
                    $instance.exposureNotificationManager = MockWindowsExposureNotificationManager()
                    $instance.encryptedStore.stored["isolation_state_info"] = Data(storeRepresentation.utf8)
                    
                    try completeRunning()
                    try trigger(transition.event, adapter: &caseAdapter)
                    print(transition.initialState)
                    print(transition.event)
                    print(transition.finalState)
                    let context = try self.context()
                    try caseAdapter.verify(context, isIn: transition.finalState)
                }
            } catch is IsolationModelUndefinedMappingError {
                skippedTransitions.append(transition)
            }
        }
        
        try XCTSkipIf(!skippedTransitions.isEmpty, "Skipped \(skippedTransitions.count) out of \(validTransitions.count) valid transitions")
    }
    
    /// Tests that after storing each reachable state, the test does not believe we’re in any other state.
    ///
    /// This measures the quality of our tests: If the `verify` function is empty, `testAppLoadsInitialIsolationStateCorrectly` would always pass,
    /// but it’s not actually testing anything
    func testEachStateIsIdentifiedCorrectly() throws {
        struct StatePair {
            var first: IsolationModel.State
            var second: IsolationModel.State
        }
        
        let adapter = IsolationModelAdapter()
        
        let reachableStatePairs = IsolationModelCurrentRuleSet.reachableStates
            .flatMap { first in
                IsolationModelCurrentRuleSet.reachableStates
                    .filter { first != $0 }
                    .map { second in
                        StatePair(first: first, second: second)
                    }
            }
        
        var skippedStatePairs: [StatePair] = []
        
        for pair in reachableStatePairs {
            do {
                guard adapter.canDistinguish(pair.first, from: pair.second) else {
                    throw IsolationModelUndefinedMappingError()
                }
                
                let storeRepresentations = try adapter.storeRepresentations(for: pair.first)
                guard !storeRepresentations.isEmpty else {
                    throw TestError("`storeRepresentations` must not be empty. Throw an appropriate error to indicate why this is empty.")
                }
                
                for storeRepresentation in storeRepresentations {
                    resetInstance()
                    setUpInstance(with: adapter)
                    $instance.encryptedStore.stored["isolation_state_info"] = Data(storeRepresentation.utf8)
                    
                    try completeRunning()
                    let context = try self.context()
                    
                    let result = Result { try adapter.verify(context, isIn: pair.second) }
                    switch result {
                    case .success:
                        throw TestError("""
                        Test incorrectly verified states.
                        Stored: \(pair.first)
                        Verified: \(pair.second)
                        """)
                    case .failure(let error) where error is IsolationModelUndefinedMappingError:
                        throw error
                    case .failure:
                        // We expected a throw here. All good.
                        break
                    }
                }
            } catch is IsolationModelUndefinedMappingError {
                skippedStatePairs.append(pair)
            }
        }
        
        try XCTSkipIf(!skippedStatePairs.isEmpty, "Skipped \(skippedStatePairs.count) out of \(reachableStatePairs.count) reachable state pairs.")
    }
    
}

private struct TestError: Error, CustomStringConvertible {
    var description: String
    
    init(_ description: String) {
        self.description = description
    }
}
