//
// Copyright © 2021 DHSC. All rights reserved.
//

import SwiftUI

public struct ExternalLinkButton: View {
    
    private let title: String
    private let action: () -> Void
    
    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(Color(.nhsBlue))
                    .font(.headline)
                    .underline()
                Image(.externalLink)
                    .foregroundColor(Color(.nhsBlue))
            }
        }
        .linkify(title)
    }
    
}
