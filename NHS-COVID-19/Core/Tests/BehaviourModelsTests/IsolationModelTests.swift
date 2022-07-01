//
// Copyright © 2021 DHSC. All rights reserved.
//

import BehaviourModels
import Common
import TestSupport
import XCTest
import Foundation

class IsolationModelRuleSetTests: XCTestCase {

    fileprivate var ruleSet: IsolationRuleSet.Type { IsolationModelCurrentRuleSet.self }

    func testThereIsExactlyOneRuleForEachStateAndEvent() {
        let failures = allTransitions.compactMap { state, event -> String? in
            let matchedRules = ruleSet.rules(matching: state, for: event)
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

    func testAllPossibleStatesAreReachableWithRealRules() {
        let visitedStates = Set(allTransitions.compactMap { state, event in
            ruleSet.rules(matching: state, for: event, includeFiller: false).first?.apply(to: state)
        })

        // Not converting this type into a set so the output order is deterministic
        let unvisitedStates = mutating(ruleSet.reachableStates) {
            $0.removeAll(where: visitedStates.contains)
        }

        XCTAssert(unvisitedStates.isEmpty, """
        Number of unexpectedly unvisited states: \(unvisitedStates.count)
        \(TS.description(for: unvisitedStates))
        """)
    }

    func testForbiddenStatesAreNotReachable() {
        let visitedStates = Set(allTransitions.compactMap { state, event in
            ruleSet.rules(matching: state, for: event).first?.apply(to: state)
        })

        // Not converting this type into a set so the output order is deterministic
        let visitedUnreachableStates = mutating(ruleSet.unreachableStates) {
            $0.removeAll { !visitedStates.contains($0) }
        }

        XCTAssert(visitedUnreachableStates.isEmpty, """
        Number of unexpectedly visited states: \(visitedUnreachableStates.count)
        \(TS.description(for: visitedUnreachableStates))
        """)
    }

    private var allTransitions: [(IsolationModel.State, IsolationModel.Event)] {
        ruleSet.reachableStates.flatMap { state in
            IsolationModel.Event.allCases.map { event in
                (state, event)
            }
        }
    }

    private func summary(of rules: [IsolationModel.Rule]) -> String {
        TS.description(for: rules.map { $0.description })
    }

}
