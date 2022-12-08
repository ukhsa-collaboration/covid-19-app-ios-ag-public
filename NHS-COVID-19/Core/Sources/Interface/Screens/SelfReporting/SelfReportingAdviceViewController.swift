//
// Copyright © 2022 DHSC. All rights reserved.
//

import Localization
import SwiftUI
import UIKit
import Common

public protocol SelfReportingAdviceViewControllerInteracting {
    func didTapReadMoreLink()
    func didTapReportResult()
    func didTapBackToHome()
}

private class Content {
    var views: [StackViewContentProvider]

    public typealias Interacting = SelfReportingAdviceViewControllerInteracting

    public init(interactor: Interacting, state: SelfReportingAdviceViewController.State) {

        let headerImage = UIImageView(state.headerImage).styleAsDecoration()

        let headerLabel = BaseLabel().set(text: state.headerLabel).styleAsPageHeader().centralized()

        let infoSectionLink = LinkButton(title: localize(.self_report_advice_info_section_url_label), externalLink: true, action: { interactor.didTapReportResult() })
        let infoSectionDescription = BaseLabel().set(text: localize(.self_report_advice_info_section_description)).styleAsBody()

        let infoSection = UIStackView(arrangedSubviews: [infoSectionLink, infoSectionDescription])
        infoSection.axis = .vertical
        infoSection.alignment = .fill
        infoSection.distribution = .equalSpacing
        infoSection.spacing = .standardSpacing
        infoSection.layoutMargins = .standard
        infoSection.isLayoutMarginsRelativeArrangement = true
        infoSection.layer.cornerRadius = .buttonCornerRadius
        infoSection.backgroundColor = .systemBackground

        let subHeaderLabel = BaseLabel().set(text: state.subHeader).styleAsBoldSecondaryTitle()

        let infoBox = InformationBox.indication.warning(localize(.self_report_advice_information_label))

        let bulletedListHeader = BaseLabel().set(text: localize(.self_report_advice_bulleted_list_header_label)).styleAsBody()
        let iconBullet1 = WelcomePoint(image: .socialDistancing, header: "", body: localize(.self_report_advice_icon_bullet_1_label))
        let iconBullet2 = WelcomePoint(image: .washHands, header: "", body: localize(.self_report_advice_icon_bullet_2_label))
        let iconBullet3 = WelcomePoint(image: .riskLevelFaceCoveringsIcon, header: "", body: localize(.self_report_advice_icon_bullet_3_label))

        let readMoreLink = LinkButton(title: localizeForCountry(.self_report_advice_read_more_url_label), externalLink: true, action: { interactor.didTapReadMoreLink() })

        let primaryButton = PrimaryButton(title: localize(.back_to_home), action: { interactor.didTapBackToHome() })
        let primaryLinkButton = PrimaryLinkButton(title: localize(.self_report_advice_primary_link_button_label), action: { interactor.didTapReportResult() })
        let secondaryLinkButton = SecondaryButton(title: localize(.back_to_home), action: { interactor.didTapBackToHome() })

        switch state {
        case .reportedResult:
            infoSection.isHidden = true
            subHeaderLabel.isHidden = true
            infoBox.isHidden = true
            primaryLinkButton.isHidden = true
            secondaryLinkButton.isHidden = true
        case .notReportedResult:
            infoBox.isHidden = true
            primaryButton.isHidden = true
        case .reportedResultOutOfIsolation:
            infoSection.isHidden = true
            subHeaderLabel.isHidden = true
            bulletedListHeader.isHidden = true
            iconBullet1.isHidden = true
            iconBullet2.isHidden = true
            iconBullet3.isHidden = true
            primaryLinkButton.isHidden = true
            secondaryLinkButton.isHidden = true
        case .notReportedResultOutOfIsolation:
            bulletedListHeader.isHidden = true
            iconBullet1.isHidden = true
            iconBullet2.isHidden = true
            iconBullet3.isHidden = true
            primaryButton.isHidden = true
        }

        let contentStack = UIStackView(arrangedSubviews: [
            headerImage,
            headerLabel,
            infoSection,
            subHeaderLabel,
            infoBox,
            bulletedListHeader,
            iconBullet1,
            iconBullet2,
            iconBullet3,
            readMoreLink,
            primaryButton,
            primaryLinkButton,
            secondaryLinkButton
        ])

        contentStack.axis = .vertical
        contentStack.spacing = .doubleSpacing

        views = [contentStack]
    }
}

public class SelfReportingAdviceViewController: ScrollingContentViewController {
    public enum State {
        case reportedResult(isolationDuration: Int)
        case notReportedResult(isolationDuration: Int, endDate: Date)
        case reportedResultOutOfIsolation
        case notReportedResultOutOfIsolation
    }

    public typealias Interacting = SelfReportingAdviceViewControllerInteracting
    private let interactor: Interacting

    public init(interactor: Interacting, state: State) {
        UIAccessibility.post(notification: .screenChanged, argument: localize(.self_report_advice_accessibility_title))
        self.interactor = interactor
        super.init(views: Content(interactor: interactor, state: state).views)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

extension SelfReportingAdviceViewController.State {

    var headerImage: ImageName {
        switch self {
        case .reportedResult:
            return .isolationContinue
        case .notReportedResult, .notReportedResultOutOfIsolation:
            return .isolationStartIndex
        case .reportedResultOutOfIsolation:
            return .onboardingStart
        }
    }

    var headerLabel: String {
        switch self {
        case .reportedResult(let isolationDuration):
            return localize(.self_report_advice_reported_result_header(days: isolationDuration))
        case .notReportedResult, .notReportedResultOutOfIsolation:
            return localize(.self_report_advice_not_reported_result_header)
        case .reportedResultOutOfIsolation:
            return localize(.self_report_advice_reported_result_out_of_isolation_header)
        }
    }

    var subHeader: String {
        switch self {
        case .reportedResult, .reportedResultOutOfIsolation:
            return ""
        case .notReportedResult(let isolationDuration, let endDate):
            return localize(.self_report_advice_not_reported_result_header(days: isolationDuration, endDate: endDate))
        case .notReportedResultOutOfIsolation:
            return localize(.self_report_advice_not_reported_result_out_of_isolation_second_header)
        }
    }
}
