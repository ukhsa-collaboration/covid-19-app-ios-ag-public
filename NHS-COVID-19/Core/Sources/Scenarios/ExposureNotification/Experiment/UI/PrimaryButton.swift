//
// Copyright © 2020 NHSX. All rights reserved.
//

import Interface
import SwiftUI

struct PrimaryButton: View {
    
    var title: String
    var action: () -> Void
    
    @Environment(\.isEnabled)
    var isEnabled: Bool
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color(.white))
                .frame(maxWidth: .infinity, minHeight: .buttonMinimumHeight)
                .background(isEnabled ? Color(.nhsButtonGreen) : Color(.systemGray3))
                .cornerRadius(.buttonCornerRadius)
        }
        .padding([.leading, .trailing], .standardSpacing)
    }
    
}
