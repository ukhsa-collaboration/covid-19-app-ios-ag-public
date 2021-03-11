//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

public struct IsolationModel {
    
    public enum ContactCaseState: Equatable, CaseIterable {
        case noIsolation
        
        case isolating
        
        case notIsolatingAndHadRiskyContactPreviously
        
        case notIsolatingAndHadRiskyContactIsolationTerminatedDueToDCT
    }
    
    public enum SymptomaticCaseState: Equatable, CaseIterable {
        case noIsolation
        
        case isolating
        
        case notIsolatingAndHadSymptomsPreviously
    }
    
    /// Isolation cases involving a case
    ///
    /// Consider renaming this as this isn't _alway_ involve a positive test (could be a negative test).
    public enum PositiveTestCaseState: Equatable, CaseIterable {
        case noIsolation
        
        case isolatingWithConfirmedTest
        case isolatingWithUnconfirmedTest
        
        case notIsolatingAndHadConfirmedTestPreviously
        case notIsolatingAndHadUnconfirmedTestPreviously
        
        /// This could be due to a positive test that was then overridden OR you actually never had a positive test, and this is the first test you enter.
        ///
        /// Consider breaking this into two separate cases for when we do and do not have a previous P isolation. Do not do this until we have a
        /// more advanced model that captures expected data stored on disk to verify whether indeed we want to be able to represent these separately.
        case notIsolatingAndHasNegativeTest
    }
    
    public struct State: Hashable, CaseIterable {
        var contact: ContactCaseState
        var symptomatic: SymptomaticCaseState
        var positiveTest: PositiveTestCaseState
    }
    
    public enum Event: Equatable, CaseIterable {
        // External:
        case riskyContact
        case riskyContactWithExposureDayOlderThanIsolationTerminationDueToDCT
        
        case selfDiagnosedSymptomatic
        
        case terminateRiskyContactDueToDCT
        
        case receivedConfirmedPositiveTest
        case receivedConfirmedPositiveTestWithEndDateOlderThanRememberedNegativeTestEndDate
        case receivedConfirmedPositiveTestWithEndDateOlderThanAssumedSymptomOnsetDate
        case receivedConfirmedPositiveTestWithIsolationPeriodOlderThanAssumedSymptomOnsetDate
        
        case receivedUnconfirmedPositiveTest
        case receivedUnconfirmedPositiveTestWithEndDateOlderThanRememberedNegativeTestEndDate
        case receivedUnconfirmedPositiveTestWithEndDateOlderThanAssumedSymptomOnsetDate
        case receivedUnconfirmedPositiveTestWithIsolationPeriodOlderThanAssumedSymptomOnsetDate
        
        case receivedNegativeTest
        case receivedNegativeTestWithEndDateOlderThanRememberedUnconfirmedTestEndDate
        case receivedNegativeTestWithEndDateOlderThanAssumedSymptomOnsetDate
        
        case receivedVoidTest
        
        // Time-based:
        case contactIsolationEnded
        case indexIsolationEnded
        
        case retentionPeriodEnded
    }
    
    public struct StatePredicate {
        var contact = Set(ContactCaseState.allCases)
        var symptomatic = Set(SymptomaticCaseState.allCases)
        var positiveTest = Set(PositiveTestCaseState.allCases)
    }
    
    struct StateMutations {
        var contact: ContactCaseState?
        var symptomatic: SymptomaticCaseState?
        var positiveTest: PositiveTestCaseState?
    }
    
    public struct Rule {
        public var description: String
        
        var predicates: [StatePredicate]
        var event: Event
        var mutations: IsolationModel.StateMutations
    }
}

public protocol IsolationRuleSet {
    
    typealias StatePredicate = IsolationModel.StatePredicate
    typealias Rule = IsolationModel.Rule
    typealias Event = IsolationModel.Event
    typealias State = IsolationModel.State
    
    static var unreachableStatePredicates: [StatePredicate] { get }
    
    static var rulesRespondingToExternalEvents: [Rule] { get }
    static var rulesAutomaticallyTriggeredOverTime: [Rule] { get }
    static var fillerRules: [Rule] { get }
}

extension IsolationRuleSet {
    
    public static var realRules: [Rule] { rulesRespondingToExternalEvents + rulesAutomaticallyTriggeredOverTime }
    
    public static var allRules: [Rule] { realRules + fillerRules }
    
    public static func rules(matching state: State, for event: Event, includeFiller: Bool = true) -> [Rule] {
        (includeFiller ? allRules : realRules)
            .filter { $0.event == event }
            .filter { $0.predicates.contains { $0.matches(state) } }
    }
    
    public static var reachableStates: [IsolationModel.State] {
        State.allCases
            .filter { !unreachableStates.contains($0) }
    }
    
    public static var unreachableStates: [IsolationModel.State] {
        var visitedCases = Set<IsolationModel.State>()
        return unreachableStatePredicates
            .flatMap { $0.allMatchedCases }
            .filter { visitedCases.insert($0).inserted }
    }
    
}

extension IsolationModel.State {
    
    public static let allCases: [IsolationModel.State] = {
        IsolationModel.ContactCaseState.allCases.flatMap { contact in
            IsolationModel.SymptomaticCaseState.allCases.flatMap { symptomatic in
                IsolationModel.PositiveTestCaseState.allCases.map { positiveTest in
                    IsolationModel.State(contact: contact, symptomatic: symptomatic, positiveTest: positiveTest)
                }
            }
        }
    }()
    
}

extension Set where Element: CaseIterable {
    
    static func all(except exceptions: Element...) -> Set<Element> {
        Set(Element.allCases).symmetricDifference(exceptions)
    }
    
}

extension IsolationModel.StatePredicate {
    
    public func matches(_ state: IsolationModel.State) -> Bool {
        contact.contains(state.contact)
            && symptomatic.contains(state.symptomatic)
            && positiveTest.contains(state.positiveTest)
    }
    
    var allMatchedCases: [IsolationModel.State] {
        contact.flatMap { contact in
            symptomatic.flatMap { symptomatic in
                positiveTest.map { positiveTest in
                    IsolationModel.State(
                        contact: contact,
                        symptomatic: symptomatic,
                        positiveTest: positiveTest
                    )
                }
            }
        }
    }
    
}

private extension IsolationModel.StateMutations {
    
    func update(_ state: inout IsolationModel.State) {
        if let contact = contact {
            state.contact = contact
        }
        if let symptomatic = symptomatic {
            state.symptomatic = symptomatic
        }
        if let positiveTest = positiveTest {
            state.positiveTest = positiveTest
        }
    }
    
}

extension IsolationModel.Rule {
    
    public func apply(to state: IsolationModel.State) -> IsolationModel.State {
        mutating(state, with: mutations.update)
    }
    
}

extension IsolationModel.Rule {
    
    init(
        filler description: String,
        predicate: IsolationModel.StatePredicate,
        event: IsolationModel.Event
    ) {
        self.init(
            filler: description,
            predicates: [predicate],
            event: event
        )
    }
    
    init(
        filler description: String,
        predicates: [IsolationModel.StatePredicate],
        event: IsolationModel.Event
    ) {
        self.init(
            description: "Filler Rule: \(description)",
            predicates: predicates,
            event: event,
            mutations: IsolationModel.StateMutations()
        )
    }
    
    init(
        _ description: String,
        predicate: IsolationModel.StatePredicate,
        event: IsolationModel.Event,
        update: IsolationModel.StateMutations
    ) {
        self.init(
            description: description,
            predicates: [predicate],
            event: event,
            mutations: update
        )
    }
    
    init(
        _ description: String,
        predicates: [IsolationModel.StatePredicate],
        event: IsolationModel.Event,
        update: IsolationModel.StateMutations
    ) {
        self.init(
            description: description,
            predicates: predicates,
            event: event,
            mutations: update
        )
    }
    
}
