//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import SwiftUI

struct RuleView: View {
    var rule: IsolationModel.Rule
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(rule.description)
            ForEach(rule.transitions) {
                TransitionView(transition: $0)
            }
        }
    }
}

struct IsolationModelRulesRespondingToExternalEventsPreviews: PreviewProvider {
    
    static var previews: some View {
        ForEach(IsolationModel.rulesRespondingToExternalEvents, id: \.description) { rule in
            RuleView(rule: rule)
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
    
}

struct IsolationModelRulesAutomaticallyTriggeredOverTimePreviews: PreviewProvider {
    
    static var previews: some View {
        ForEach(IsolationModel.rulesAutomaticallyTriggeredOverTime, id: \.description) { rule in
            RuleView(rule: rule)
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
    
}

struct IsolationModelFillerRulesPreviews: PreviewProvider {
    
    static var previews: some View {
        ForEach(IsolationModel.fillerRules, id: \.description) { rule in
            RuleView(rule: rule)
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
    
}

struct IsolationModelUnreachableStatesPreviews: PreviewProvider {
    
    static var previews: some View {
        ForEach(StateCollection.unreachableStateCollections) { collection in
            StateView(collection: collection)
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
    
}
