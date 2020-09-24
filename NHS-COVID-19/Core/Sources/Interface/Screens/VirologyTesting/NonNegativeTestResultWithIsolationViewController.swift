//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Localization
import UIKit

public protocol NonNegativeTestResultWithIsolationViewControllerInteracting {
    var didTapOnlineServicesLink: () -> Void { get }
    var didTapPrimaryButton: () -> Void { get }
    var didTapCancel: (() -> Void)? { get }
}

private class NonNegativeTestResultWithIsolationContent: PrimaryButtonStickyFooterScrollingContent {
    typealias Interacting = NonNegativeTestResultWithIsolationViewControllerInteracting
    typealias TestResultType = NonNegativeTestResultWithIsolationViewController.TestResultType
    
    static func daysRemaining(_ isolationEndDate: Date) -> Int {
        LocalDay.today.daysRemaining(until: isolationEndDate)
    }
    
    init(interactor: Interacting, isolationEndDate: Date, testResultType: TestResultType) {
        var scrollingViews = [
            UIImageView(testResultType.image).styleAsDecoration(),
            UIStackView(content: BasicContent(
                views: [
                    UILabel()
                        .styleAsHeading()
                        .set(text: testResultType.title)
                        .isAccessibilityElement(false)
                        .centralized(),
                    UILabel()
                        .styleAsPageHeader()
                        .set(text: localize(.positive_symptoms_days(days: Self.daysRemaining(isolationEndDate))))
                        .isAccessibilityElement(false)
                        .centralized(),
                ],
                spacing: .standardSpacing,
                margins: .zero
            ))
                .accessibilityTraits([.staticText, .header])
                .isAccessibilityElement(true)
                .accessibilityLabel(testResultType.titleAccessibilityLabel(daysRemaining: Self.daysRemaining(isolationEndDate))),
            InformationBox.indication.badNews(testResultType.infoText),
        ]
        
        scrollingViews += testResultType.explanationText.map {
            UILabel().styleAsSecondaryBody().set(text: $0)
        }
        
        scrollingViews += [
            UILabel().styleAsSecondaryBody().set(text: localize(.end_of_isolation_link_label)),
            LinkButton(
                title: localize(.end_of_isolation_online_services_link),
                action: interactor.didTapOnlineServicesLink
            ),
        ]
        
        super.init(
            scrollingViews: scrollingViews,
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
        case positive(Isolation)
    }
    
    private let interactor: Interacting
    
    public init(interactor: Interacting, isolationEndDate: Date, testResultType: TestResultType) {
        self.interactor = interactor
        
        let content = NonNegativeTestResultWithIsolationContent(
            interactor: interactor,
            isolationEndDate: isolationEndDate,
            testResultType: testResultType
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
        case .void:
            return .isolationStartIndex
        case .positive(.start):
            return .isolationStartContact
        case .positive(.continue):
            return .isolationContinue
        }
    }
    
    var title: String {
        switch self {
        case .void, .positive(.continue):
            return localize(.positive_test_result_title)
        case .positive(.start):
            return localize(.positive_test_result_start_to_isolate_title)
        }
    }
    
    func titleAccessibilityLabel(daysRemaining: Int) -> String {
        switch self {
        case .void, .positive(.continue):
            return localize(.positive_test_please_isolate_accessibility_label(days: daysRemaining))
        case .positive(.start):
            return localize(.positive_test_start_to_isolate_accessibility_label(days: daysRemaining))
        }
    }
    
    var explanationText: [String] {
        switch self {
        case .void:
            return localizeAndSplit(.void_test_result_explanation)
        case .positive(.continue):
            return localizeAndSplit(.positive_test_result_explanation)
        case .positive(.start):
            return localizeAndSplit(.positive_test_result_start_to_isolate_explaination)
        }
    }
    
    var infoText: String {
        switch self {
        case .void:
            return localize(.void_test_result_info)
        case .positive(.continue):
            return localize(.positive_test_result_info)
        case .positive(.start):
            return localize(.positive_test_result_start_to_isolate_info)
        }
    }
    
    var primaryButtonText: String {
        switch self {
        case .void:
            return localize(.void_test_results_continue)
        case .positive:
            return localize(.positive_test_results_continue)
        }
    }
}
