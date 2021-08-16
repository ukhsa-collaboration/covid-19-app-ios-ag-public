//
// Copyright © 2021 DHSC. All rights reserved.
//

import SwiftUI

extension ForEach where Content: View, Data == [String], ID == String {
    
    public static func fromStrings(_ strings: Data, spacing: CGFloat, @ViewBuilder content: @escaping (Data.Element) -> Content) -> some View {
        VStack(alignment: .leading, spacing: spacing) {
            ForEach(strings, id: \.description, content: content)
        }
    }
    
}
