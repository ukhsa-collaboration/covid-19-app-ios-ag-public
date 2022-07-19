//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

public struct IsolationModel {

    public enum ContactCaseState: String, Codable, Equatable, CaseIterable {
        case noIsolation

        case isolating

        case notIsolatingAndHadRiskyContactPreviously

        case notIsolatingAndHadRiskyContactIsolationTerminatedEarly
    }

    public enum SymptomaticCaseState: String, Codable, Equatable, CaseIterable {
        case noIsolation

        case isolating

        case notIsolatingAndHadSymptomsPreviously
    }

    /// Isolation cases involving a case
    ///
    /// Consider renaming this as this isn't _alway_ involve a positive test (could be a negative test).
    public enum PositiveTestCaseState: String, Codable, Equatable, CaseIterable {
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

    public struct State: Codable, Hashable, CaseIterable {
        public var contact: ContactCaseState
        public var symptomatic: SymptomaticCaseState
        public var positiveTest: PositiveTestCaseState

        public init(
            contact: IsolationModel.ContactCaseState,
            symptomatic: IsolationModel.SymptomaticCaseState,
            positiveTest: IsolationModel.PositiveTestCaseState
        ) {
            self.contact = contact
            self.symptomatic = symptomatic
            self.positiveTest = positiveTest
        }
    }

    public enum Event: String, Codable, Equatable, CaseIterable {
        // External:
        case riskyContact
        case riskyContactWithExposureDayOlderThanEarlyIsolationTermination

        case selfDiagnosedSymptomatic
        case selfDiagnosedSymptomaticWithAssumedOnsetDateOlderThanPositiveTestEndDate

        case terminatedRiskyContactEarly

        case receivedConfirmedPositiveTest
        case receivedConfirmedPositiveTestWithEndDateOlderThanExpiredIndexIsolationEndDate
        case receivedConfirmedPositiveTestWithEndDateOlderThanRememberedNegativeTestEndDate
        case receivedConfirmedPositiveTestWithIsolationPeriodOlderThanAssumedIsolationStartDate

        case receivedUnconfirmedPositiveTest
        // In this case it's assumed that the unconfirmed positive is newer than any assumed symptom onset
        case receivedUnconfirmedPositiveTestWithEndDateOlderThanRememberedNegativeTestEndDate
        case receivedUnconfirmedPositiveTestWithEndDateNDaysOlderThanRememberedNegativeTestEndDateAndOlderThanAssumedSymptomOnsetDayIfAny
        case receivedUnconfirmedPositiveTestWithEndDateOlderThanAssumedSymptomOnsetDate
        case receivedUnconfirmedPositiveTestWithIsolationPeriodOlderThanAssumedIsolationStartDate

        // Note 1:
        // Based on the current rule set, there’s an invariant when we have both an unconfirmed test and symptoms:
        // The assumed symptom onset day > test end date.
        // This assumption currently can’t be captured in the state yet, so we need to be careful in the definition of
        // these events.

        // Note 2:
        // If not explicitly constrained, it’s assumed received negative test not before and within N days of any
        // unconfirmed test result

        // Note 3:
        // If not explicitly constrained, it’s assumed received negative test is not older than assumed symptom onset

        case receivedNegativeTest
        case receivedNegativeTestWithEndDateOlderThanAssumedSymptomOnsetDate

        // This is addressing a very specific case:
        // * User has confirmed positive test and symptoms
        // * assumed symptoms > positive test end date
        // * negative test end date > positive.
        case receivedNegativeTestWithEndDateNewerThanAssumedSymptomOnsetDateAndAssumedSymptomOnsetDateNewerThanPositiveTestEndDate

        case receivedNegativeTestWithEndDateOlderThanRememberedUnconfirmedTestEndDateAndOlderThanAssumedSymptomOnsetDayIfAny
        // Based on note 1, the following is not possible:
        // case receivedNegativeTestWithEndDateNDaysNewerThanRememberedUnconfirmedTestEndDate

        case receivedNegativeTestWithEndDateNDaysNewerThanRememberedUnconfirmedTestEndDateButOlderThanAssumedSymptomOnsetDayIfAny
        case receivedNegativeTestWithEndDateNDaysNewerThanRememberedUnconfirmedTestEndDate

        case receivedVoidTest

        // Time-based:
        case contactIsolationEnded
        case indexIsolationEnded

        case retentionPeriodEnded
    }

    public struct Reference: Codable {
        public static let basePath = "NHS-COVID-19/Core/Sources"

        public var file: String
        public var line: Int
    }

    public struct Transition: Codable {
        public var reference: Reference
        public var initialState: State
        public var event: Event
        public var finalState: State
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
        public var reference: Reference

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

    public static var validTransitions: [IsolationModel.Transition] {
        reachableStates.flatMap { state in
            IsolationModel.Event.allCases.compactMap { event in
                guard let rule = rules(matching: state, for: event, includeFiller: false).first else { return nil }
                return IsolationModel.Transition(
                    reference: rule.reference,
                    initialState: state,
                    event: event,
                    finalState: rule.apply(to: state)
                )
            }
        }
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
        file: String = #fileID,
        line: Int = #line,
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
        file: String = #fileID, line: Int = #line,
        filler description: String,
        predicates: [IsolationModel.StatePredicate],
        event: IsolationModel.Event
    ) {
        self.init(
            reference: .init(file: file, line: line),
            description: "Filler Rule: \(description)",
            predicates: predicates,
            event: event,
            mutations: IsolationModel.StateMutations()
        )
    }

    init(
        file: String = #fileID, line: Int = #line,
        _ description: String,
        predicate: IsolationModel.StatePredicate,
        event: IsolationModel.Event,
        update: IsolationModel.StateMutations
    ) {
        self.init(
            reference: .init(file: file, line: line),
            description: description,
            predicates: [predicate],
            event: event,
            mutations: update
        )
    }

    init(
        file: String = #fileID, line: Int = #line,
        _ description: String,
        predicates: [IsolationModel.StatePredicate],
        event: IsolationModel.Event,
        update: IsolationModel.StateMutations
    ) {
        self.init(
            reference: .init(file: file, line: line),
            description: description,
            predicates: predicates,
            event: event,
            mutations: update
        )
    }

}
