//
// Copyright © 2022 DHSC. All rights reserved.
//

import Localization
import SwiftUI
import UIKit
import Common

public protocol SelfReportingNegativeOrVoidTestResultViewControllerInteracting {
    func didTapFindOutMoreLink()
    func didTapNHS111Online()
    func didTapPrimaryButton()
    func didTapBackButton()
}

struct SelfReportingNegativeOrVoidTestResultContent {
    public typealias Interacting = SelfReportingNegativeOrVoidTestResultViewControllerInteracting
    var views: [StackViewContentProvider]

    init(interactor: Interacting, country: Country) {

        let header = BaseLabel()
            .set(text: localize(.self_report_negative_or_void_test_result_header))
            .styleAsPageHeader()
            .centralized()

        let body_one = BaseLabel()
            .set(text: localize(.self_report_negative_or_void_test_result_body_one))
            .styleAsBody()

        let findOutMoreLink = LinkButton(
            title: localize(.self_report_negative_or_void_test_result_link_one_title),
            action: {
                interactor.didTapFindOutMoreLink()
            }
        )

        let body_two = BaseLabel()
            .set(text: localize(.self_report_negative_or_void_test_result_body_two))
            .styleAsBody()

        let sectionTitle = BaseLabel()
            .set(text: localize(.self_report_negative_or_void_test_result_subtitle))
            .styleAsBoldSecondaryTitle()

        let body_three = BaseLabel()
            .set(text: localize(.self_report_negative_or_void_test_result_body_three))
            .styleAsBody()

        let body_four = BaseLabel()
            .set(text: localize(.self_report_negative_or_void_test_result_body_four))
            .styleAsBody()

        let nhs111OnlineLink = LinkButton(
            title: localizeForCountry(.nhs111_online_opens_outside_the_app_link_button_title),
            action: {
                interactor.didTapNHS111Online()
            }
        )

        let primaryButton = PrimaryButton(
            title: localize(.self_report_negative_or_void_test_result_back_to_home),
            action: {
                interactor.didTapPrimaryButton()
            }
        )

        var contentStack: UIStackView

        switch country {
        case .england:
            contentStack = UIStackView(arrangedSubviews: [header, body_one, findOutMoreLink, body_two, sectionTitle, body_three, body_four,nhs111OnlineLink, primaryButton, SpacerView()])
        case .wales:
            contentStack = UIStackView(arrangedSubviews: [header, body_one, sectionTitle, body_three, body_four,nhs111OnlineLink, primaryButton, SpacerView()])
        }

        contentStack.axis = .vertical
        contentStack.spacing = .doubleSpacing

        views = [contentStack]
    }
}

public class SelfReportingNegativeOrVoidTestResultViewController: ScrollingContentViewController {
    public typealias Interacting = SelfReportingNegativeOrVoidTestResultViewControllerInteracting
    private let interactor: Interacting
    private let country: Country

    public init(interactor: Interacting, country: Country) {
        self.interactor = interactor
        self.country = country
        let content = SelfReportingNegativeOrVoidTestResultContent(interactor: interactor, country: country)
        super.init(views: content.views, topMargin: true)
        UIAccessibility.post(notification: .screenChanged, argument: localize(.self_report_negative_or_void_test_result_accessibility_title))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: localize(.back), style: .plain, target: self, action: #selector(didTapBackButton))
        navigationItem.leftBarButtonItem?.accessibilityHint = localize(.self_report_negative_or_void_test_result_back_button_accessibility_label)
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
