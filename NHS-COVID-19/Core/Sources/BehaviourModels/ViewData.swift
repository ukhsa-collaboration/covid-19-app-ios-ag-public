//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct StateCollection: Hashable, Identifiable {
    enum Status {
        case any
        case noIsolation
        case isolationActive
        case isolationFinished
        case isolationFinishedAndHasNegativeTest
    }
    
    var contact: Status
    var symptomatic: Status
    var positiveTest: Status
    var counter: Int = 1
    
    var id: StateCollection {
        self
    }
}

struct Transition: Hashable, Identifiable {
    var from: StateCollection
    var label: String
    var to: StateCollection
    
    var id: Transition {
        self
    }
}

extension StateCollection {
    
    static let unreachableStateCollections: [StateCollection] = {
        IsolationModel.unreachableStatePredicates.flatMap { $0.coveredStates(includeUnreachableStates: true) }
    }()
    
}

extension IsolationModel.Rule {
    
    var transitions: [Transition] {
        predicates.flatMap { $0.coveredStates() }.map { initialState in
            Transition(
                from: initialState,
                label: "\(event)",
                to: mutations.update(initialState)
            )
        }
    }
    
}

private extension IsolationModel.StatePredicate {
    
    func coveredStates(includeUnreachableStates: Bool = false) -> [StateCollection] {
        contact.statuses.flatMap { contact in
            symptomatic.statuses.flatMap { symptomatic in
                positiveTest.statuses
                    .filter { positiveTest in
                        let representsAtLeastOneReachableState =
                            contact.values.contains { contact in
                                symptomatic.values.contains { symptomatic in
                                    positiveTest.values.contains { positiveTest in
                                        let state = IsolationModel.State(
                                            contact: contact,
                                            symptomatic: symptomatic,
                                            positiveTest: positiveTest
                                        )
                                        return IsolationModel.State.reachableCases.contains(state)
                                    }
                                }
                            }
                        return representsAtLeastOneReachableState || includeUnreachableStates
                    }
                    .map { positiveTest in
                        StateCollection(
                            contact: contact.status,
                            symptomatic: symptomatic.status,
                            positiveTest: positiveTest.status,
                            counter: [
                                contact.count,
                                symptomatic.count,
                                positiveTest.count,
                            ].reduce(1, *)
                        )
                    }
            }
        }
    }
    
}

private extension IsolationModel.StateMutations {
    
    func update(_ stateCollection: StateCollection) -> StateCollection {
        mutating(stateCollection) {
            $0.counter = 1
            if let contact = contact {
                $0.contact = contact.status
            }
            if let symptomatic = symptomatic {
                $0.symptomatic = symptomatic.status
            }
            if let positiveTest = positiveTest {
                $0.positiveTest = positiveTest.status
            }
        }
    }
    
}

private protocol StateCollectionStatusConvertible: CaseIterable {
    
    var status: StateCollection.Status { get }
    
}

private struct StatusGroup<Value> {
    var values: [Value]
    var status: StateCollection.Status
    var count: Int {
        values.count
    }
}

private extension Set where Element: StateCollectionStatusConvertible {
    
    var statuses: [StatusGroup<Element>] {
        if self == Set(Element.allCases) {
            return [StatusGroup(values: Array(Element.allCases), status: .any)]
        } else {
            // Map over `allCases` instead of `self` to make order deterministic
            return Element.allCases
                .filter(contains)
                .map { StatusGroup(values: [$0], status: $0.status) }
        }
    }
    
}

extension IsolationModel.ContactCaseState: StateCollectionStatusConvertible {
    
    fileprivate var status: StateCollection.Status {
        switch self {
        case .noIsolation:
            return .noIsolation
        case .isolationActive:
            return .isolationActive
        case .isolationFinished:
            return .isolationFinished
        }
    }
    
}

extension IsolationModel.SymptomaticCaseState: StateCollectionStatusConvertible {
    
    fileprivate var status: StateCollection.Status {
        switch self {
        case .noIsolation:
            return .noIsolation
        case .isolationActive:
            return .isolationActive
        case .isolationFinished:
            return .isolationFinished
        case .isolationFinishedAndHasNegativeTest:
            return .isolationFinishedAndHasNegativeTest
        }
    }
    
}

extension IsolationModel.PositiveTestCaseState: StateCollectionStatusConvertible {
    
    fileprivate var status: StateCollection.Status {
        switch self {
        case .noIsolation:
            return .noIsolation
        case .isolationActive:
            return .isolationActive
        case .isolationFinished:
            return .isolationFinished
        case .isolationFinishedAndHasNegativeTest:
            return .isolationFinishedAndHasNegativeTest
        }
    }
    
}
