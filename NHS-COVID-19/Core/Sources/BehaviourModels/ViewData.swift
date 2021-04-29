//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

public struct StateCollection: Hashable, Identifiable {
    enum Status {
        case any
        case noIsolation
        case isolationActive
        case isolationFinished
        case isolationFinishedAndHasNegativeTest
    }
    
    struct Condition: Hashable {
        var label: String
        var caption: String = ""
        var status: Status
    }
    
    var contact: Condition
    var symptomatic: Condition
    var positiveTest: Condition
    var counter: Int = 1
    
    public var id: StateCollection {
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

extension IsolationRuleSet {
    
    public static var unreachableStateCollections: [StateCollection] {
        unreachableStatePredicates.flatMap { $0.coveredStates(excludeStates: []) }
    }
    
}

extension IsolationModel.Rule {
    
    func transitions(excludeStates: [IsolationModel.State]) -> [Transition] {
        predicates.flatMap { $0.coveredStates(excludeStates: excludeStates) }.map { initialState in
            Transition(
                from: initialState,
                label: "\(event)",
                to: mutations.update(initialState)
            )
        }
    }
    
}

private extension IsolationModel.StatePredicate {
    
    func coveredStates(excludeStates: [IsolationModel.State]) -> [StateCollection] {
        contact.statuses.flatMap { contact in
            symptomatic.statuses.flatMap { symptomatic in
                positiveTest.statuses
                    .filter { positiveTest in
                        hasOneReachableState(contact: contact, symptomatic: symptomatic, positiveTest: positiveTest, excludeStates: excludeStates)
                    }
                    .map { positiveTest in
                        StateCollection(
                            contact: .init(contact),
                            symptomatic: .init(symptomatic),
                            positiveTest: .init(positiveTest),
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

private extension StateCollection.Condition {
    
    init<T>(_ group: StatusGroup<T>) {
        self.init(label: group.label, caption: group.caption, status: group.status)
    }
    
}

private func hasOneReachableState(
    contact: StatusGroup<IsolationModel.ContactCaseState>,
    symptomatic: StatusGroup<IsolationModel.SymptomaticCaseState>,
    positiveTest: StatusGroup<IsolationModel.PositiveTestCaseState>,
    excludeStates: [IsolationModel.State]
) -> Bool {
    contact.values.contains { contact in
        symptomatic.values.contains { symptomatic in
            positiveTest.values.contains { positiveTest in
                let state = IsolationModel.State(
                    contact: contact,
                    symptomatic: symptomatic,
                    positiveTest: positiveTest
                )
                return !excludeStates.contains(state)
            }
        }
    }
}

private extension IsolationModel.StateMutations {
    
    func update(_ stateCollection: StateCollection) -> StateCollection {
        mutating(stateCollection) {
            $0.counter = 1
            if let contact = contact {
                $0.contact.status = contact.status
                $0.contact.caption = contact.caption
                $0.contact.label = contact.label
            }
            if let symptomatic = symptomatic {
                $0.symptomatic.status = symptomatic.status
                $0.symptomatic.caption = symptomatic.caption
                $0.symptomatic.label = symptomatic.label
            }
            if let positiveTest = positiveTest {
                $0.positiveTest.status = positiveTest.status
                $0.positiveTest.caption = positiveTest.caption
                $0.positiveTest.label = positiveTest.label
            }
        }
    }
    
}

private protocol StateCollectionCollectionConvertible: CaseIterable {
    
    static var defaultLabel: String { get }
    
    var label: String { get }
    
    var caption: String { get }
    
    var status: StateCollection.Status { get }
    
}

extension StateCollectionCollectionConvertible {
    var caption: String { "" }
    var label: String { Self.defaultLabel }
}

private struct StatusGroup<Value> {
    var label: String
    var caption: String
    var values: [Value]
    var status: StateCollection.Status
    var count: Int {
        values.count
    }
}

private extension Set where Element: StateCollectionCollectionConvertible {
    
    var statuses: [StatusGroup<Element>] {
        if self == Set(Element.allCases) {
            return [StatusGroup(label: Element.defaultLabel, caption: "", values: Array(Element.allCases), status: .any)]
        } else {
            // Map over `allCases` instead of `self` to make order deterministic
            return Element.allCases
                .filter(contains)
                .map { StatusGroup(label: $0.label, caption: $0.caption, values: [$0], status: $0.status) }
        }
    }
    
}

extension IsolationModel.ContactCaseState: StateCollectionCollectionConvertible {
    
    static var defaultLabel: String { "C" }
    
    var caption: String {
        switch self {
        case .notIsolatingAndHadRiskyContactIsolationTerminatedDueToDCT:
            return "DCT"
        default:
            return ""
        }
    }
    
    fileprivate var status: StateCollection.Status {
        switch self {
        case .noIsolation:
            return .noIsolation
        case .isolating:
            return .isolationActive
        case .notIsolatingAndHadRiskyContactPreviously:
            return .isolationFinished
        case .notIsolatingAndHadRiskyContactIsolationTerminatedDueToDCT:
            return .isolationFinishedAndHasNegativeTest
        }
    }
    
}

extension IsolationModel.SymptomaticCaseState: StateCollectionCollectionConvertible {
    
    static var defaultLabel: String { "S" }
    
    fileprivate var status: StateCollection.Status {
        switch self {
        case .noIsolation:
            return .noIsolation
        case .isolating:
            return .isolationActive
        case .notIsolatingAndHadSymptomsPreviously:
            return .isolationFinished
        }
    }
    
}

extension IsolationModel.PositiveTestCaseState: StateCollectionCollectionConvertible {
    
    static var defaultLabel: String { "P" }
    
    var label: String {
        switch self {
        case .notIsolatingAndHasNegativeTest:
            return "N"
        default:
            return Self.defaultLabel
        }
    }
    
    var caption: String {
        switch self {
        case .isolatingWithConfirmedTest, .notIsolatingAndHadConfirmedTestPreviously:
            return "Confirmed"
        case .isolatingWithUnconfirmedTest, .notIsolatingAndHadUnconfirmedTestPreviously:
            return "Unconfirmed"
        default:
            return ""
        }
    }
    
    fileprivate var status: StateCollection.Status {
        switch self {
        case .noIsolation:
            return .noIsolation
        case .isolatingWithConfirmedTest, .isolatingWithUnconfirmedTest:
            return .isolationActive
        case .notIsolatingAndHadConfirmedTestPreviously, .notIsolatingAndHadUnconfirmedTestPreviously:
            return .isolationFinished
        case .notIsolatingAndHasNegativeTest:
            return .isolationFinishedAndHasNegativeTest
        }
    }
    
}
