//
// Copyright © 2021 DHSC. All rights reserved.
//

import SwiftUI

private struct OnSizeChangedModifier: ViewModifier {
    let onSizeChanged: (CGSize) -> Void

    func body(content: Content) -> some View {
        content
            .overlay(GeometryReader { geometry in
                triggerSizeChange(of: geometry)
            })
    }

    private func triggerSizeChange(of geometry: GeometryProxy) -> some View {
        onSizeChanged(geometry.size)
        return Text("").accessibility(hidden: true) // EmptyView() doesn't work here
    }
}

extension View {
    public func onSizeChanged(_ perform: @escaping (CGSize) -> Void) -> some View {
        modifier(OnSizeChangedModifier(onSizeChanged: perform))
    }
}
