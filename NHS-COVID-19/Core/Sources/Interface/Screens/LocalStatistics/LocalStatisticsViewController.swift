//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import SwiftUI
import UIKit

public protocol LocalStatisticsInteracting {
    func didTapdashboardLinkButton()
}

extension LocalStatisticsViewController {

    struct Content {
        var views: [StackViewContentProvider]

        init(interactor: Interacting, localStats: InterfaceLocalCovidStatsDaily) {

            var heightConstraint: NSLayoutConstraint?
            let dataController = UIHostingController(
                rootView: SizingView(
                    view: LocalCovidStatsDataView(localCovidStats: localStats),
                    updateSizeHandler: { size in
                        guard size.height > 0 else { return }
                        heightConstraint?.constant = size.height
                        heightConstraint?.isActive = true
                    }
                ))
            dataController.view.backgroundColor = .clear
            dataController.view.translatesAutoresizingMaskIntoConstraints = false
            heightConstraint = dataController.view.heightAnchor.constraint(equalToConstant: 0)

            views = [
                BaseLabel()
                    .styleAsPageHeader()
                    .set(text: localize(.local_statistics_main_screen_title)),
                BaseLabel()
                    .styleAsBody()
                    .set(text: localize(.local_statistics_main_screen_info)),
                SpacerView(),
                dataController.view,
                BaseLabel()
                    .styleAsBody()
                    .set(text: localize(.local_statistics_main_screen_more_info)),
                LinkButton(
                    title: localize(.local_statistics_main_screen_dashboard_link_title),
                    accessoryImage: UIImage(.externalLink),
                    externalLink: true,
                    action: interactor.didTapdashboardLinkButton
                ),
                BaseLabel()
                    .styleAsBody()
                    .set(text: localize(.local_statistics_main_screen_last_updated(date: localStats.lastFetch))),
            ]
        }
    }
}

public class LocalStatisticsViewController: ScrollingContentViewController {
    public typealias Interacting = LocalStatisticsInteracting
    private let interactor: Interacting

    public init(interactor: Interacting, covidStats: InterfaceLocalCovidStatsDaily) {
        self.interactor = interactor

        super.init(views: Content(interactor: interactor, localStats: covidStats).views)
        title = localize(.local_statistics_main_screen_navigation_title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
