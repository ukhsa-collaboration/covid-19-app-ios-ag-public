//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import SwiftUI
import UIKit

private struct ContactTracingAdviceView: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .standardSpacing) {
                Text(.contact_tracing_should_not_pause_heading).styleAsHeading()
                BulletItems(
                    rows: localizeAndSplit(.contact_tracing_should_not_pause_bullet_points)
                )
                Text(.contact_tracing_should_not_pause_footnote).styleAsBody()
            }
            .padding(.all, .bigSpacing)
        }
    }
}

public final class ContactTracingAdviceViewController: RootViewController {
    public init() {
        super.init(nibName: nil, bundle: nil)

        title = localize(.contact_tracing_should_not_pause_title)

        let contentView = ContactTracingAdviceView()
        let contentViewController = UIHostingController(rootView: contentView)
        addFilling(contentViewController)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
