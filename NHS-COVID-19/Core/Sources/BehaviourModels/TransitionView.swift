//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import SwiftUI

struct TransitionView: View {
    
    var transition: Transition
    
    var body: some View {
        HStack {
            StateView(collection: transition.from)
            VStack(spacing: 8) {
                Text(transition.label)
                    .font(.caption)
                Image(systemName: "arrow.forward")
            }
            .frame(width: 200)
            StateView(collection: transition.to)
        }
    }
    
}

struct TransitionViewPreviews: PreviewProvider {
    
    static var previews: some View {
        TransitionView(transition: .sample)
            .padding()
            .previewLayout(.sizeThatFits)
    }
    
}

private extension Transition {
    
    static let sample = Transition(
        from: StateCollection(
            contact: .noIsolation,
            symptomatic: .any,
            positiveTest: .any,
            counter: 10
        ),
        label: "Risky contact",
        to: StateCollection(
            contact: .isolationActive,
            symptomatic: .any,
            positiveTest: .any
        )
    )
    
}
