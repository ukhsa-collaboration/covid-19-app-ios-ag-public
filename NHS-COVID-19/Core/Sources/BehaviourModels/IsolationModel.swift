//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

public struct IsolationModel {
    
    public enum ContactCaseState: Equatable, CaseIterable {
        case noIsolation
        case isolationActive
        case isolationFinished
    }
    
    public enum SymptomaticCaseState: Equatable, CaseIterable {
        case noIsolation
        case isolationActive
        case isolationFinished
        
        /// Only possible if started isolation as symptomatic and then received a negative result.
        case isolationFinishedAndHasNegativeTest
    }
    
    public enum PositiveTestCaseState: Equatable, CaseIterable {
        case noIsolation
        case isolationActive
        case isolationFinished
        
        /// This could be due to a positive test that was then overridden OR you actually never had a positive test, and this is the first test you enter
        case isolationFinishedAndHasNegativeTest
    }
    
    public struct State: Hashable, CaseIterable {
        var contact: ContactCaseState
        var symptomatic: SymptomaticCaseState
        var positiveTest: PositiveTestCaseState
    }
    
    public enum Event: Equatable, CaseIterable {
        // External:
        case riskyContact
        case selfDiagnosedSymptomatic
        case receivedPositiveTest
        case receivedNegativeTest
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
    
    public static let unreachableStatePredicates: [StatePredicate] = [
        StatePredicate(
            symptomatic: [.isolationFinished, .isolationFinishedAndHasNegativeTest],
            positiveTest: [.isolationActive]
        ),
        StatePredicate(
            symptomatic: [.isolationActive],
            positiveTest: [.isolationFinished, .isolationFinishedAndHasNegativeTest]
        ),
        StatePredicate(
            symptomatic: [.isolationFinished],
            positiveTest: [.isolationFinishedAndHasNegativeTest]
        ),
        StatePredicate(
            symptomatic: [.isolationFinishedAndHasNegativeTest],
            positiveTest: [.isolationFinished]
        ),
        StatePredicate(
            symptomatic: [.isolationFinishedAndHasNegativeTest],
            positiveTest: [.isolationFinishedAndHasNegativeTest]
        ),
    ]
    
    public static let rulesRespondingToExternalEvents: [Rule] = [
        Rule(
            """
            A risky contact will start a contact isolation.
            Risky contacts are only considered when the user is not already in contact or positive isolation
            """,
            predicate: StatePredicate(
                contact: [.noIsolation, .isolationFinished],
                positiveTest: [.noIsolation, .isolationFinished, .isolationFinishedAndHasNegativeTest]
            ),
            event: .riskyContact,
            update: .init(contact: .isolationActive)
        ),
        
        Rule(
            """
            A symptomatic isolation will start on a symptomatic self-diagnosis.
            Symptom entry is only allowed if not already isolating as symptomatic or positive.
            """,
            predicate: StatePredicate(
                symptomatic: [.noIsolation, .isolationFinished, .isolationFinishedAndHasNegativeTest],
                positiveTest: [.noIsolation, .isolationFinished, .isolationFinishedAndHasNegativeTest]
            ),
            event: .selfDiagnosedSymptomatic,
            update: .init(
                symptomatic: .isolationActive,
                positiveTest: .noIsolation
            )
        ),
        
        Rule(
            """
            A positive test isolation will start on a positive test.
            """,
            predicate: StatePredicate(
                symptomatic: [.noIsolation],
                positiveTest: [.noIsolation]
            ),
            event: .receivedPositiveTest,
            update: .init(
                positiveTest: .isolationActive
            )
        ),
        
        Rule(
            """
            A positive test will not start a new isolation if a positive test isolation is expired.
            The positive test will be stored is there is not one.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.isolationFinished],
                    positiveTest: [.isolationFinished, .noIsolation]
                ),
                StatePredicate(
                    symptomatic: [.noIsolation],
                    positiveTest: [.isolationFinished]
                ),
            ],
            event: .receivedPositiveTest,
            update: .init()
        ),
        
        Rule(
            """
            A positive test will start a new isolation if previous symptomatic or positive test isolation ended and has negative test.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.isolationFinishedAndHasNegativeTest],
                    positiveTest: [.noIsolation]
                ),
                StatePredicate(
                    symptomatic: [.noIsolation],
                    positiveTest: [.isolationFinishedAndHasNegativeTest]
                ),
            ],
            event: .receivedPositiveTest,
            update: .init(
                symptomatic: .noIsolation,
                positiveTest: .isolationActive
            )
        ),
        
        Rule(
            """
            A symptomatic or positive test isolation will continue on a new positive test.
            The positive test will be stored is there is not one.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.noIsolation],
                    positiveTest: [.isolationActive]
                ),
                StatePredicate(
                    symptomatic: [.isolationActive],
                    positiveTest: [.noIsolation]
                ),
                StatePredicate(
                    symptomatic: [.isolationActive],
                    positiveTest: [.isolationActive]
                ),
            ],
            event: .receivedPositiveTest,
            update: .init(positiveTest: .isolationActive)
        ),
        
        Rule(
            """
            A negative test will not override a positive isolation (active or finished).
            """,
            predicate: StatePredicate(
                positiveTest: [.isolationActive, .isolationFinished, .isolationFinishedAndHasNegativeTest]
            ),
            event: .receivedNegativeTest,
            update: .init()
        ),
        
        Rule(
            """
            A negative test when has no in symptomatic or positive isolation state will be stored.
            """,
            predicate: StatePredicate(
                symptomatic: [.noIsolation],
                positiveTest: [.noIsolation]
            ),
            event: .receivedNegativeTest,
            update: .init(positiveTest: .isolationFinishedAndHasNegativeTest)
        ),
        
        Rule(
            """
            A negative test when symptomatic isolation is finished will be stored if there isn’t one.
            """,
            predicate: StatePredicate(
                symptomatic: [.isolationFinished, .isolationFinishedAndHasNegativeTest],
                positiveTest: [.noIsolation]
            ),
            event: .receivedNegativeTest,
            update: .init(symptomatic: .isolationFinishedAndHasNegativeTest)
        ),
        
        Rule(
            """
            A negative test will end symptomatic isolation if not also positive.
            The test result will be stored.
            """,
            predicate: StatePredicate(
                symptomatic: [.isolationActive],
                positiveTest: [.noIsolation]
            ),
            event: .receivedNegativeTest,
            update: .init(symptomatic: .isolationFinishedAndHasNegativeTest)
        ),
        
        Rule(
            """
            A void test will never change isolation state.
            """,
            predicate: StatePredicate(),
            event: .receivedVoidTest,
            update: .init()
        ),
    ]
    
    public static let rulesAutomaticallyTriggeredOverTime: [Rule] = [
        
        Rule(
            """
            A contact isolation will end.
            """,
            predicate: StatePredicate(contact: [.isolationActive]),
            event: .contactIsolationEnded,
            update: .init(contact: .isolationFinished)
        ),
        
        Rule(
            """
            A positive test isolation will end.
            """,
            predicate: StatePredicate(
                symptomatic: [.noIsolation],
                positiveTest: [.isolationActive]
            ),
            event: .indexIsolationEnded,
            update: .init(positiveTest: .isolationFinished)
        ),
        
        Rule(
            """
            A symptomatic isolation will end.
            """,
            predicate: StatePredicate(
                symptomatic: [.isolationActive],
                positiveTest: [.noIsolation]
            ),
            event: .indexIsolationEnded,
            update: .init(symptomatic: .isolationFinished)
        ),
        
        Rule(
            """
            A combined symptomatic and positive test isolation will end together.
            """,
            predicate: StatePredicate(
                symptomatic: [.isolationActive],
                positiveTest: [.isolationActive]
            ),
            event: .indexIsolationEnded,
            update: .init(
                symptomatic: .isolationFinished,
                positiveTest: .isolationFinished
            )
        ),
        
        Rule(
            """
            After retention period ends all isolation is deleted.
            """,
            predicate: StatePredicate(
                contact: [.noIsolation, .isolationFinished],
                symptomatic: [.noIsolation, .isolationFinished, .isolationFinishedAndHasNegativeTest],
                positiveTest: [.noIsolation, .isolationFinished, .isolationFinishedAndHasNegativeTest]
            ),
            event: .retentionPeriodEnded,
            update: .init(
                contact: .noIsolation,
                symptomatic: .noIsolation,
                positiveTest: .noIsolation
            )
        ),
    ]
    
    public static let realRules: [Rule] = rulesRespondingToExternalEvents + rulesAutomaticallyTriggeredOverTime
    
    /// Rules that are defined for completeness of the state machine, but we don't expect them as should be "impossible" for reasons not captured in state machine.
    public static let fillerRules: [Rule] = [
        Rule(
            filler: """
            We block risky contacts events during an existing contact or positive isolation.
            """,
            predicates: [
                StatePredicate(
                    contact: [.isolationActive]
                ),
                StatePredicate(
                    contact: [.noIsolation, .isolationFinished],
                    positiveTest: [.isolationActive]
                ),
            ],
            event: .riskyContact
        ),
        
        Rule(
            filler: """
            If not in contact isolation, then the event to end it is meaningless.
            """,
            predicate: StatePredicate(contact: [.noIsolation, .isolationFinished]),
            event: .contactIsolationEnded
        ),
        
        Rule(
            filler: """
            We do not allow new self-diagnosis during an active symptomatic or positive isolation.
            """,
            predicates: [
                StatePredicate(
                    symptomatic: [.isolationActive],
                    positiveTest: [.noIsolation]
                ),
                StatePredicate(
                    symptomatic: [.noIsolation],
                    positiveTest: [.isolationActive]
                ),
                StatePredicate(
                    symptomatic: [.isolationActive],
                    positiveTest: [.isolationActive]
                ),
            ],
            event: .selfDiagnosedSymptomatic
        ),
        
        Rule(
            filler: """
            If not in symptomatic or positive test isolation, then the event to finish it is meaningless.
            """,
            predicate: StatePredicate(
                symptomatic: [.noIsolation, .isolationFinished, .isolationFinishedAndHasNegativeTest],
                positiveTest: [.noIsolation, .isolationFinished, .isolationFinishedAndHasNegativeTest]
            ),
            event: .indexIsolationEnded
        ),
        
        Rule(
            filler: """
            Retention period should not end if we have an active isolation.
            """,
            predicates: [
                StatePredicate(
                    contact: [.isolationActive],
                    symptomatic: [.noIsolation, .isolationFinished, .isolationFinishedAndHasNegativeTest],
                    positiveTest: [.noIsolation, .isolationFinished, .isolationFinishedAndHasNegativeTest]
                ),
                StatePredicate(
                    contact: [.noIsolation, .isolationFinished],
                    symptomatic: [.isolationActive],
                    positiveTest: [.noIsolation, .isolationFinished, .isolationFinishedAndHasNegativeTest]
                ),
                StatePredicate(
                    contact: [.noIsolation, .isolationFinished],
                    symptomatic: [.noIsolation, .isolationFinished, .isolationFinishedAndHasNegativeTest],
                    positiveTest: [.isolationActive]
                ),
                StatePredicate(
                    contact: [.isolationActive],
                    symptomatic: [.isolationActive],
                    positiveTest: [.noIsolation, .isolationFinished, .isolationFinishedAndHasNegativeTest]
                ),
                StatePredicate(
                    contact: [.noIsolation, .isolationFinished],
                    symptomatic: [.isolationActive],
                    positiveTest: [.isolationActive]
                ),
                StatePredicate(
                    contact: [.isolationActive],
                    symptomatic: [.noIsolation, .isolationFinished, .isolationFinishedAndHasNegativeTest],
                    positiveTest: [.isolationActive]
                ),
                StatePredicate(
                    contact: [.isolationActive],
                    symptomatic: [.isolationActive],
                    positiveTest: [.isolationActive]
                ),
            ],
            event: .retentionPeriodEnded
        ),
    ]
    
    public static let allRules = realRules + fillerRules
    
    public static func rules(matching state: State, for event: Event, includeFiller: Bool = true) -> [Rule] {
        (includeFiller ? allRules : realRules)
            .filter { $0.event == event }
            .filter { $0.predicates.contains { $0.matches(state) } }
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
    
    public static let reachableCases: [IsolationModel.State] = {
        allCases
            .filter { !unreachableCases.contains($0) }
    }()
    
    public static let unreachableCases: [IsolationModel.State] = {
        var visitedCases = Set<IsolationModel.State>()
        return IsolationModel.unreachableStatePredicates
            .flatMap { $0.allMatchedCases }
            .filter { visitedCases.insert($0).inserted }
    }()
    
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

extension IsolationModel.Rule {
    
    public func apply(to state: IsolationModel.State) -> IsolationModel.State {
        mutating(state, with: update)
    }
    
    func update(_ state: inout IsolationModel.State) {
        if let contact = mutations.contact {
            state.contact = contact
        }
        if let symptomatic = mutations.symptomatic {
            state.symptomatic = symptomatic
        }
        if let positiveTest = mutations.positiveTest {
            state.positiveTest = positiveTest
        }
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
