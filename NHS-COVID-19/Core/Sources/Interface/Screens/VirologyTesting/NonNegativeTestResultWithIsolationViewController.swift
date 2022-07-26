//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Localization
import UIKit

public protocol NonNegativeTestResultWithIsolationViewControllerInteracting {
    var didTapOnlineServicesLink: () -> Void { get }
    var didTapPrimaryButton: () -> Void { get }
    var didTapExposureFAQLink: () -> Void { get }
    var didTapNHSGuidanceLink: () -> Void { get }
    var didTapCancel: (() -> Void)? { get }
}

private class NonNegativeTestResultWithIsolationContent: PrimaryButtonStickyFooterScrollingContent {
    typealias Interacting = NonNegativeTestResultWithIsolationViewControllerInteracting
    typealias TestResultType = NonNegativeTestResultWithIsolationViewController.TestResultType

    init(interactor: Interacting, isolationEndDate: Date, testResultType: TestResultType, currentDateProvider: DateProviding) {
        let informationBox: InformationBox = {
            if case .positive(_, true) = testResultType {
                return InformationBox.indication.warning(testResultType.infoText)
            } else {
                return InformationBox.indication.warning(testResultType.infoText)
            }
        }()

        let linkAction = interactor.didTapOnlineServicesLink

        super.init(
            scrollingViews: [
                UIImageView(testResultType.image).styleAsDecoration(),
                UIStackView(content: BasicContent(
                    views: [
                        BaseLabel()
                            .styleAsHeading()
                            .set(text: testResultType.title)
                            .isAccessibilityElement(false)
                            .centralized(),
                        BaseLabel()
                            .styleAsPageHeader()
                            .set(text: localize(.positive_symptoms_days(days: currentDateProvider.currentLocalDay.daysRemaining(until: isolationEndDate))))
                            .isAccessibilityElement(false)
                            .centralized(),
                        BaseLabel()
                            .styleAsHeading()
                            .set(text: testResultType.subtitle)
                            .isAccessibilityElement(false)
                            .centralized(),

                    ],
                    spacing: .standardSpacing,
                    margins: .zero
                ))
                    .accessibilityTraits([.staticText, .header])
                    .isAccessibilityElement(true)
                    .accessibilityLabel(testResultType.titleAccessibilityLabel(daysRemaining: currentDateProvider.currentLocalDay.daysRemaining(until: isolationEndDate))),
                informationBox,
                testResultType.explanationText.map {
                    BaseLabel().styleAsSecondaryBody().set(text: $0)
                },
                testResultType.showExposureFAQ ?
                    [
                        BaseLabel().set(text: localize(.exposure_faqs_link_label)).styleAsSecondaryBody(),
                        LinkButton(
                            title: localize(.exposure_faqs_link_button_title),
                            action: interactor.didTapExposureFAQLink
                        ),
                    ] : [],
                BaseLabel().styleAsSecondaryBody().set(text: localizeForCountry(.void_end_of_isolation_link_label)),
                LinkButton(
                    title: testResultType.linkLabel,
                    action: linkAction
                ),
            ],
            primaryButton: (title: testResultType.primaryButtonText, action: interactor.didTapPrimaryButton)
        )
    }
}

public class NonNegativeTestResultWithIsolationViewController: StickyFooterScrollingContentViewController {
    public typealias Interacting = NonNegativeTestResultWithIsolationViewControllerInteracting

    public enum TestResultType {
        public enum Isolation {
            case start
            case `continue`
        }

        case void
        case positive(isolation: Isolation, requiresConfirmatoryTest: Bool)
        case positiveButAlreadyConfirmedPositive
    }

    private let interactor: Interacting

    public init(interactor: Interacting, isolationEndDate: Date, testResultType: TestResultType, currentDateProvider: DateProviding) {
        self.interactor = interactor

        let content = NonNegativeTestResultWithIsolationContent(
            interactor: interactor,
            isolationEndDate: isolationEndDate,
            testResultType: testResultType,
            currentDateProvider: currentDateProvider
        )

        super.init(content: content)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if interactor.didTapCancel != nil {
            navigationController?.setNavigationBarHidden(false, animated: animated)
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: localize(.cancel), style: .done, target: self, action: #selector(didTapCancel))
        } else {
            navigationController?.setNavigationBarHidden(true, animated: animated)
        }
    }

    @objc func didTapCancel() {
        interactor.didTapCancel?()
    }
}

extension NonNegativeTestResultWithIsolationContent.TestResultType {

    var image: ImageName {
        switch self {
        case .void, .positive(_, true):
            return .isolationStartIndex
        case .positive(.start, false):
            return .isolationStartIndex
        case .positive(.continue, false),
             .positiveButAlreadyConfirmedPositive:
            return .isolationContinue
        }
    }

    var title: String {
        switch self {
        case .positive(.continue, _):
            return localize(.positive_test_result_title)
        case .void:
            return localizeForCountry(.void_test_result_title)
        case .positive(.start, _):
            return localize(.try_to_stay_at_home_for_after_positive_test_wales)
        case .positiveButAlreadyConfirmedPositive:
            return localize(.positive_test_result_already_confirmed_positive_title)
        }
    }

    var subtitle: String? {
        if case .positive(_, true) = self {
            return localize(.positive_test_result_requires_follow_up_test_subtitle)
        } else {
            return nil
        }
    }

    func titleAccessibilityLabel(daysRemaining: Int) -> String {
        switch self {
        case .void:
            return localizeForCountry(.void_test_please_isolate_accessibility_label(days: daysRemaining))
        case .positive(.continue, _), .positiveButAlreadyConfirmedPositive:
            return localize(.positive_test_please_isolate_accessibility_label(days: daysRemaining))
            
        case .positive(.start, _):
            return localize(.try_to_stay_at_home_for_wales_header(days: daysRemaining))
        }
    }

    var explanationText: [String] {
        switch self {
        case .void:
            return localizeForCountryAndSplit(.void_test_result_explanation)
        case .positive(_, true):
            return localizeAndSplit(.positive_test_result_requires_follow_up_test_explanation)
        case .positive(.continue, false):
            return localizeAndSplit(.positive_test_result_explanation)
        case .positive(.start, false):
            return localizeAndSplit(.positive_test_result_start_to_isolate_explaination)
        case .positiveButAlreadyConfirmedPositive:
            return localizeAndSplit(.positive_test_result_already_confirmed_positive_explanation)
        }
    }

    var infoText: String {
        switch self {
        case .void:
            return localizeForCountry(.void_end_of_isolation_void_text_no_isolation_title)
        case .positive(_, true):
            return localize(.positive_test_result_requires_follow_up_test_start_to_isolate_info)
        case .positive(_, false):
            return localize(.infobox_after_positive_test_wales)
        case .positiveButAlreadyConfirmedPositive:
            return localize(.positive_test_result_already_confirmed_positive_info)
        }
    }

    var showExposureFAQ: Bool {
        switch self {
        case .void, .positive(_, false):
            return false
        case .positiveButAlreadyConfirmedPositive, .positive(_, true):
            return true
        }
    }

    var primaryButtonText: String {
        switch self {
        case .void:
            return localizeForCountry(.void_test_results_primary_button_title)
        case .positive(_, true):
            return localize(.positive_test_result_requires_follow_up_test_book_test_button)
        case .positive(_, false):
            return localize(.positive_test_results_continue)
        case .positiveButAlreadyConfirmedPositive:
            return localize(.positive_test_result_already_confirmed_positive_continue)
        }
    }

    var linkLabel: String {
        switch self {
        case .positive, .positiveButAlreadyConfirmedPositive:
            return localize(.end_of_isolation_online_services_link)
        case .void:
            return localizeForCountry(.void_test_result_with_isolation_nhs_guidance_link)
        }
    }
}
