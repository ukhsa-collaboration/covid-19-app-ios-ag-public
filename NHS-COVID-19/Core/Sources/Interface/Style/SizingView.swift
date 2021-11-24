//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import SwiftUI

public class SelfSizingHostingController<Content>: UIHostingController<Content> where Content: View {
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.invalidateIntrinsicContentSize()
    }
}

struct SizingView<T: View>: View {
    let view: T
    let updateSizeHandler: (_ size: CGSize) -> Void
    
    init(view: T, updateSizeHandler: @escaping (_ size: CGSize) -> Void) {
        self.view = view
        self.updateSizeHandler = updateSizeHandler
    }
    
    var body: some View {
        view.background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: proxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self) { preferences in
            updateSizeHandler(preferences)
        }
    }
}

struct SizePreferenceKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue: Value = .zero
    
    static func reduce(value _: inout Value, nextValue: () -> Value) {
        _ = nextValue()
    }
}
