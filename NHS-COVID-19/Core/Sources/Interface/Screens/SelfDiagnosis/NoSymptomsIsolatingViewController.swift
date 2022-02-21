//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol NoSymptomsIsolatingViewControllerInteracting {
    func didTapReturnHome()
    func didTapCancel()
    func didTapOnlineServicesLink()
}

extension NoSymptomsIsolatingViewController {
    private class Content: PrimaryButtonStickyFooterScrollingContent {
        init(interactor: Interacting, isolationEndDate: Date, currentDateProvider: DateProviding) {
            let daysToIsolate = currentDateProvider.currentLocalDay.daysRemaining(until: isolationEndDate)
            
            let headingStack = UIStackView(
                content: BasicContent(
                    views: [
                        BaseLabel()
                            .set(text: localize(.no_symptoms_isolating_info_isolate_for))
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
            .accessibilityLabel(localize(.positive_test_please_isolate_accessibility_label(days: daysToIsolate)))
            
            super.init(
                scrollingViews: [
                    UIImageView(.isolationStartContact).styleAsDecoration(),
                    headingStack,
                    InformationBox.indication.goodNews(localize(.no_symptoms_isolating_info)),
                    BaseLabel().set(text: localize(.no_symptoms_isolating_body)).styleAsSecondaryBody(),
                    BaseLabel().set(text: localize(.no_symptoms_isolating_advice)).styleAsSecondaryBody(),
                    LinkButton(
                        title: localize(.no_symptoms_isolating_services_link),
                        action: interactor.didTapOnlineServicesLink
                    ),
                    
                ],
                primaryButton: (
                    title: localize(.no_symptoms_isolating_return_home_button),
                    action: interactor.didTapReturnHome
                )
            )
        }
    }
}

public class NoSymptomsIsolatingViewController: StickyFooterScrollingContentViewController {
    public typealias Interacting = NoSymptomsIsolatingViewControllerInteracting
    private let interactor: Interacting
    
    public init(interactor: Interacting, isolationEndDate: Date, dateProvider: DateProviding) {
        self.interactor = interactor
        super.init(content: Content(interactor: interactor, isolationEndDate: isolationEndDate, currentDateProvider: dateProvider))
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: localize(.cancel),
            style: .done, target: self,
            action: #selector(didTapCancel)
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapCancel() {
        interactor.didTapCancel()
    }
}
