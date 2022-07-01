//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

public class ScrollingContentViewController: StickyFooterScrollingContentViewController {
    init(views: [StackViewContentProvider]) {
        super.init(
            content: BasicStickyFooterScrollingContent(
                scrollingViews: views,
                footerViews: nil
            )
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
