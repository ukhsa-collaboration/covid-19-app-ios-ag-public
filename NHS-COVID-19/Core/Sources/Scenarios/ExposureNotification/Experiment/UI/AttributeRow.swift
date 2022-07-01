//
// Copyright © 2020 NHSX. All rights reserved.
//

import SwiftUI

struct AttributeRow: View {
    var title: String
    var value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
        }
    }

}
