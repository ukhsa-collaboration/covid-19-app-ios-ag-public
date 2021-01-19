//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import TestSupport
import XCTest

class IsolationModelTests: XCTestCase {
    
    func testThereIsExactlyOneRuleForEachStateAndEvent() {
        let failures = allTransitions.compactMap { state, event -> String? in
            let matchedRules = IsolationModel.rules(matching: state, for: event)
            switch matchedRules.count {
            case 1:
                return nil
                
            case 0:
                return """
                No rules found.
                State: \(state)
                Event: \(event)
                """
                
            default:
                return """
                Multiple rules found.
                State: \(state)
                Event: \(event)
                Matched Rules: \(summary(of: matchedRules))
                """
            }
        }
        
        XCTAssert(failures.isEmpty, """
        Number of violations: \(failures.count)
        \(failures.joined(separator: "\n\n"))
        """)
    }
    
    func testAllStatesAreReachable() {
        let visitedStates = Set(allTransitions.compactMap { state, event in
            IsolationModel.rules(matching: state, for: event).first?.apply(to: state)
        })
        
        // Not converting this type into a set so the output order is deterministic
        let unvisitedStates = mutating(IsolationModel.State.allCases) {
            $0.removeAll(where: visitedStates.contains)
        }
        
        XCTAssert(unvisitedStates.isEmpty, """
        Number of unvisited states: \(unvisitedStates.count)
        \(TS.description(for: unvisitedStates))
        """)
    }
    
    private var allTransitions: [(IsolationModel.State, IsolationModel.Event)] {
        IsolationModel.State.allCases.flatMap { state in
            IsolationModel.Event.allCases.map { event in
                (state, event)
            }
        }
    }
    
    private func summary(of rules: [IsolationModel.Rule]) -> String {
        TS.description(for: rules.map { $0.description })
    }
    
}
