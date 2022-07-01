//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import SwiftUI

private typealias PreviewedRules = IsolationModelCurrentRuleSet

public struct RuleView: View {

    public init(rule: IsolationModel.Rule) {
        self.rule = rule
    }

    var rule: IsolationModel.Rule

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(rule.description)
                .frame(minHeight: 100, alignment: .bottom)
            ForEach(rule.transitions(excludeStates: PreviewedRules.unreachableStates)) {
                TransitionView(transition: $0)
            }
        }
    }
}

struct IsolationModelRulesRespondingToExternalEventsPreviews: PreviewProvider {

    static var previews: some View {
        ForEach(PreviewedRules.rulesRespondingToExternalEvents, id: \.description) { rule in
            RuleView(rule: rule)
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }

}

struct IsolationModelRulesAutomaticallyTriggeredOverTimePreviews: PreviewProvider {

    static var previews: some View {
        ForEach(PreviewedRules.rulesAutomaticallyTriggeredOverTime, id: \.description) { rule in
            RuleView(rule: rule)
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }

}

struct IsolationModelFillerRulesPreviews: PreviewProvider {

    static var previews: some View {
        ForEach(PreviewedRules.fillerRules, id: \.description) { rule in
            RuleView(rule: rule)
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }

}

struct IsolationModelUnreachableStatesPreviews: PreviewProvider {

    static var previews: some View {
        ForEach(PreviewedRules.unreachableStateCollections) { collection in
            StateView(collection: collection)
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }

}
