//
// Copyright © 2022 DHSC. All rights reserved.
//

import Localization
import SwiftUI
import UIKit
import Common

public protocol SelfReportingShareTestResultViewControllerInteracting {
    func didTapPrimaryButton()
    func didTapBackButton()
}

struct SelfReportingShareTestResultContent {
    public typealias Interacting = SelfReportingShareTestResultViewControllerInteracting
    var views: [StackViewContentProvider]

    init(interactor: Interacting) {

        let image = UIImageView(.selfReportShareKeys)
            .styleAsDecoration()

        let header = BaseLabel()
            .set(text: localize(.self_report_share_result_header))
            .styleAsPageHeader()
            .centralized()

        let subheader = BaseLabel()
            .set(text: localize(.self_report_share_result_subheader))
            .styleAsHeading()
            .centralized()

        let body = BaseLabel()
            .set(text: localize(.self_report_share_result_body))
            .styleAsBody()

        let privacyBox = IconAndTextBoxView.privacy(text: localize(.self_report_share_result_privacy_box))

        let bulletedListHeader = BaseLabel()
        bulletedListHeader.set(text: localize(.self_report_share_result_bulleted_list_header))
        bulletedListHeader.styleAsBody()

        let bulletedList = BulletedList(
            symbolProperties: SymbolProperties(type: .fullCircle, size: .halfSpacing, color: .nhsBlue),
            rows: localizeAndSplit(.self_report_share_result_bulleted_list)
        )

        let primaryButton = PrimaryButton(
            title: localize(.continue_button_label),
            action: {
                interactor.didTapPrimaryButton()
            }
        )

        let bulletedListStack = UIStackView(arrangedSubviews: [bulletedListHeader, bulletedList])
        bulletedListStack.axis = .vertical
        bulletedListStack.spacing = .standardSpacing

        let contentStack = UIStackView(arrangedSubviews: [header, subheader, body, privacyBox, bulletedListStack, primaryButton, SpacerView()])
        contentStack.axis = .vertical
        contentStack.spacing = .doubleSpacing

        let stackView = UIStackView(arrangedSubviews: [image, contentStack])
        stackView.axis = .vertical
        stackView.spacing = .zero

        views = [stackView]
    }
}

public class SelfReportingShareTestResultViewController: ScrollingContentViewController {
    public typealias Interacting = SelfReportingShareTestResultViewControllerInteracting
    private let interactor: Interacting

    public init(interactor: Interacting) {
        self.interactor = interactor
        let content = SelfReportingShareTestResultContent(interactor: interactor)
        super.init(views: content.views, topMargin: false)
        UIAccessibility.post(notification: .screenChanged, argument: localize(.self_report_share_result_accessibility_title))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: localize(.back), style: .plain, target: self, action: #selector(didTapBackButton))
        navigationItem.leftBarButtonItem?.accessibilityHint = localize(.self_report_share_result_back_button_accessibility_label)
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
