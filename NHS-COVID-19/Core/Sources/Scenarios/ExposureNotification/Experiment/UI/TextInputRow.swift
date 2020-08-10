//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import SwiftUI

struct TextInputRow: View {
    var title: String
    var text: Binding<String>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(title)")
                .font(.caption)
            TextField("", text: text)
        }
    }
}
