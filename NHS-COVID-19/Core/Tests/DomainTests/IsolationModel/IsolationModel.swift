//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation
import TestSupport

struct IsolationModel {
    
    enum ContactCaseState: Equatable, CaseIterable {
        case notIsolating
        case isolating
    }
    
    struct State: Hashable, CaseIterable {
        var contact: ContactCaseState
        
        static let allCases: [State] = {
            ContactCaseState.allCases
                .map(State.init)
        }()
    }
    
    enum Event: Equatable, CaseIterable {
        case riskyContact
        case contactIsolationFinished
    }
    
    struct StatePredicate {
        var contact: Set<ContactCaseState>
    }
    
    struct Rule {
        var description: String
        var predicate: StatePredicate
        var event: Event
        var update: (inout State) -> Void
    }
    
    static let realRules: [Rule] = [
        Rule(
            description: """
            A risky contact will start a contact-case isolation.
            """,
            predicate: StatePredicate(contact: [.notIsolating]),
            event: .riskyContact,
            update: { $0.contact = .isolating }
        ),
        
        Rule(
            description: """
            A contact-case isolation will eventually finish.
            """,
            predicate: StatePredicate(contact: [.isolating]),
            event: .contactIsolationFinished,
            update: { $0.contact = .notIsolating }
        ),
    ]
    
    static let fillerRules: [Rule] = [
        Rule(
            description: """
            We block risky contacts events during an existing contact-case isolation.
            However, for completeness, as a rule, this should still result in an isolation.
            """,
            predicate: StatePredicate(contact: [.isolating]),
            event: .riskyContact,
            update: { _ in }
        ),
        
        Rule(
            description: """
            Filler rule: If not in contact isolation, then the event to finish it is meaningless
            """,
            predicate: StatePredicate(contact: [.notIsolating]),
            event: .contactIsolationFinished,
            update: { _ in }
        ),
    ]
    
    static let allRules = realRules + fillerRules
    
    static func rules(matching state: State, for event: Event) -> [Rule] {
        allRules.filter { $0.event == event && $0.predicate.matches(state) }
    }
    
}

extension IsolationModel.State: CustomStringConvertible {
    
    var description: String {
        TS.description(for: self)
    }
}

extension IsolationModel.StatePredicate {
    
    func matches(_ state: IsolationModel.State) -> Bool {
        contact.contains(state.contact)
    }
    
}

extension IsolationModel.Rule {
    
    func apply(to state: IsolationModel.State) -> IsolationModel.State {
        mutating(state, with: update)
    }
    
}
