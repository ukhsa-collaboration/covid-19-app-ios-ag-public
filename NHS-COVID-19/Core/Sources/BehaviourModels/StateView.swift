//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import SwiftUI

public struct StateView: View {
    
    var collection: StateCollection
    
    public init(collection: StateCollection) {
        self.collection = collection
    }
    
    public var body: some View {
        VStack(alignment: .trailing) {
            HStack {
                CaseStateView(condition: collection.contact)
                CaseStateView(condition: collection.symptomatic)
                CaseStateView(condition: collection.positiveTest)
            }
            .padding()
            .border(Color.primary, width: 1)
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
    
    var condition: StateCollection.Condition
    
    var body: some View {
        VStack {
            Text("")
                .font(.caption)
            Text(condition.label)
                .font(.body)
            Text(condition.caption)
                .font(.caption)
        }
        .frame(width: 90, height: 30)
        .padding(.vertical, 30)
        .background(fillColor.brightness(0.1))
        .border(Color.black, width: 1)
    }
    
    var fillColor: Color {
        switch condition.status {
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
                contact: .init(label: "C", status: .any),
                symptomatic: .init(label: "S", status: .isolationActive),
                positiveTest: .init(label: "P", caption: "Unconfirmed", status: .isolationFinished),
                counter: 2
            )
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
    
}
