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
                #if targetEnvironment(macCatalyst)
                Image("arrow.forward")
                #else
                Image(systemName: "arrow.forward")
                #endif
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
            contact: .init(label: "C", status: .noIsolation),
            symptomatic: .init(label: "S", status: .any),
            positiveTest: .init(label: "P", status: .any),
            counter: 10
        ),
        label: "Risky contact",
        to: StateCollection(
            contact: .init(label: "C", status: .isolationActive),
            symptomatic: .init(label: "S", status: .any),
            positiveTest: .init(label: "P", status: .any)
        )
    )
    
}
