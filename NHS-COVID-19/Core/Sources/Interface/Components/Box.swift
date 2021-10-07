//
// Copyright © 2021 DHSC. All rights reserved.
//

import SwiftUI

public struct Box<Content>: View where Content: View {
    var views: Content
    
    public init(@ViewBuilder content: () -> Content) {
        views = content()
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            views
        }
        .padding()
        .background(Color(.surface))
        .cornerRadius(.buttonCornerRadius)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Box {}
    }
}
