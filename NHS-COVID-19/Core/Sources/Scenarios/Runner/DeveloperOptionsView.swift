//
// Copyright © 2021 DHSC. All rights reserved.
//

import SwiftUI

public struct DeveloperOptionsViewEvents {
    let onTap: () -> Void
    let onLongPress: () -> Void

    public init(onTap: @escaping () -> Void, onLongPress: @escaping () -> Void) {
        self.onTap = onTap
        self.onLongPress = onLongPress
    }
}

public struct DeveloperOptionsView: View {
    @Environment(\.colorScheme) var colorScheme
    let viewEvents: DeveloperOptionsViewEvents

    public init(
        viewEvents: DeveloperOptionsViewEvents
    ) {
        self.viewEvents = viewEvents
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(colorScheme == .light ? Color.white.opacity(0.8) : Color.black.opacity(0.8))
            .overlay(
                Image(systemName: "line.horizontal.3.decrease.circle")
                    .resizable()
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.5) : Color.black.opacity(0.5))
                    .padding(7)
            )
            .frame(width: 50, height: 50)
            .shadow(radius: 8)
            .onTapGesture {
                viewEvents.onTap()
            }
            .onLongPressGesture {
                viewEvents.onLongPress()
            }
    }
}
