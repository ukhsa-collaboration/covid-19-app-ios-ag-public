//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import SwiftUI

struct StateView: View {
    
    var collection: StateCollection
    
    var body: some View {
        VStack(alignment: .trailing) {
            HStack {
                CaseStateView(label: "C", status: collection.contact)
                CaseStateView(label: "S", status: collection.symptomatic)
                CaseStateView(label: "P", status: collection.positiveTest)
            }
            .padding()
            .border(Color.black, width: 1)
            Text(counterText)
        }
    }
    
    var counterText: String {
        switch collection.counter {
        case 1:
            return " "
        default:
            return "⨉ \(collection.counter)"
        }
    }
    
}

private struct CaseStateView: View {
    
    var label: String
    var status: StateCollection.Status
    
    var body: some View {
        Text(label)
            .frame(width: 15, height: 30)
            .padding()
            .background(fillColor.brightness(0.1))
            .border(Color.black, width: 1)
    }
    
    var fillColor: Color {
        switch status {
        case .any:
            return Color(UIColor.systemGray2)
        case .noIsolation:
            return Color(UIColor.systemGreen)
        case .isolationActive:
            return Color(UIColor.systemRed)
        case .isolationFinished:
            return Color(UIColor.systemOrange)
        case .isolationFinishedAndHasNegativeTest:
            return Color(UIColor.systemBlue)
        }
    }
}

struct StateViewPreviews: PreviewProvider {
    
    static var previews: some View {
        StateView(
            collection: StateCollection(
                contact: .any,
                symptomatic: .isolationActive,
                positiveTest: .isolationFinished,
                counter: 2
            )
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
    
}
