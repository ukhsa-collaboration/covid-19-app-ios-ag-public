//
// Copyright © 2022 DHSC. All rights reserved.
//

import Localization
import SwiftUI
import UIKit
import Common

public protocol SelfReportingWillNotNotifyOthersViewControllerInteracting {
    func didTapPrimaryButton()
    func didTapBackButton()
}

struct SelfReportingWillNotNotifyOthersContent {
    public typealias Interacting = SelfReportingWillNotNotifyOthersViewControllerInteracting
    var views: [StackViewContentProvider]

    init(interactor: Interacting) {
        let header = BaseLabel()
            .set(text: localize(.self_report_will_not_notify_others_header))
            .styleAsPageHeader()
            .centralized()

        let body = BaseLabel()
            .set(text: localize(.self_report_will_not_notify_others_body))
            .styleAsBody()

        let primaryButton = PrimaryButton(
            title: localize(.continue_button_label),
            action: {
                interactor.didTapPrimaryButton()
            }
        )

        let contentStack = UIStackView(arrangedSubviews: [header, body, primaryButton, SpacerView()])
        contentStack.axis = .vertical
        contentStack.spacing = .doubleSpacing

        views = [contentStack]
    }
}

public class SelfReportingWillNotNotifyOthersViewController: ScrollingContentViewController {
    public typealias Interacting = SelfReportingWillNotNotifyOthersViewControllerInteracting
    private let interactor: Interacting

    public init(interactor: Interacting) {
        self.interactor = interactor
        let content = SelfReportingWillNotNotifyOthersContent(interactor: interactor)
        super.init(views: content.views)
        UIAccessibility.post(notification: .screenChanged, argument: localize(.self_report_will_not_notify_others_accessibility_title))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: localize(.back), style: .plain, target: self, action: #selector(didTapBackButton))
        navigationItem.leftBarButtonItem?.accessibilityHint = localize(.self_report_will_not_notify_others_back_button_accessibility_label)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    @objc private func didTapBackButton() {
        interactor.didTapBackButton()
    }
}
