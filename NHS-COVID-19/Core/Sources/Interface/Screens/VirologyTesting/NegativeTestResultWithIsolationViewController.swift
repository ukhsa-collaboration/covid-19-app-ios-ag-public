//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol NegativeTestResultWithIsolationViewControllerInteracting {
    func didTapOnlineServicesLink()
    func didTapNHSGuidanceLink()
    func didTapReturnHome()
    
}

extension NegativeTestResultWithIsolationViewController {
    private class Content: PrimaryButtonStickyFooterScrollingContent {
        init(interactor: Interacting, viewModel: ViewModel) {
            let daysToIsolate = LocalDay.today.daysRemaining(until: viewModel.isolationEndDate)
            
            super.init(
                scrollingViews: [
                    UIImageView(.isolationContinue).styleAsDecoration(),
                    UIStackView(
                        content: BasicContent(
                            views: [
                                BaseLabel()
                                    .set(text: localize(.positive_test_result_title))
                                    .styleAsHeading()
                                    .centralized()
                                    .isAccessibilityElement(false),
                                BaseLabel()
                                    .set(text: localize(.positive_symptoms_days(days: daysToIsolate)))
                                    .styleAsPageHeader()
                                    .centralized()
                                    .isAccessibilityElement(false),
                            ],
                            spacing: .zero,
                            margins: .zero
                        )
                    )
                    .isAccessibilityElement(true)
                    .accessibilityTraits([.header, .staticText])
                    .accessibilityLabel(localize(.positive_test_please_isolate_accessibility_label(days: daysToIsolate))),
                    viewModel.infobox,
                    BaseLabel().set(text: viewModel.explanationLabel).styleAsSecondaryBody(),
                    BaseLabel().set(text: localize(.negative_test_result_with_isolation_advice)).styleAsSecondaryBody(),
                    LinkButton(
                        title: viewModel.linkLabel,
                        action: viewModel.testResultType == .firstResult ? interactor.didTapNHSGuidanceLink : interactor.didTapOnlineServicesLink
                    ),
                ],
                primaryButton: (
                    title: viewModel.continueButtonText,
                    action: interactor.didTapReturnHome
                )
            )
        }
    }
}

public class NegativeTestResultWithIsolationViewController: StickyFooterScrollingContentViewController {
    public typealias Interacting = NegativeTestResultWithIsolationViewControllerInteracting
    
    public struct ViewModel {
        public enum TestResultType {
            case firstResult, afterPositive
        }
        
        var isolationEndDate: Date
        var testResultType: TestResultType
        
        public init(isolationEndDate: Date, testResultType: TestResultType) {
            self.isolationEndDate = isolationEndDate
            self.testResultType = testResultType
        }
    }
    
    public init(interactor: Interacting, viewModel: ViewModel) {
        super.init(content: Content(interactor: interactor, viewModel: viewModel))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

private extension NegativeTestResultWithIsolationViewController.ViewModel {
    var infobox: InformationBox {
        switch testResultType {
        case .firstResult:
            return InformationBox.indication.warning(localize(.negative_test_result_with_isolation_info))
        case .afterPositive:
            return InformationBox.indication.badNews(localize(.negative_test_result_after_positive_info))
        }
    }
    
    var explanationLabel: String {
        switch testResultType {
        case .firstResult:
            return localize(.negative_test_result_with_isolation_explanation)
        case .afterPositive:
            return localize(.negative_test_result_after_positive_explanation)
        }
    }
    
    var continueButtonText: String {
        switch testResultType {
        case .firstResult:
            return localize(.negative_test_result_with_isolation_back_to_home)
        case .afterPositive:
            return localize(.negative_test_result_after_positive_button_label)
        }
    }
    
    var linkLabel: String {
        switch testResultType {
        case .firstResult:
            return localize(.negative_test_result_with_isolation_nhs_guidance_link)
        case .afterPositive:
            return localize(.negative_test_result_with_isolation_service_link)
        }
    }
}
