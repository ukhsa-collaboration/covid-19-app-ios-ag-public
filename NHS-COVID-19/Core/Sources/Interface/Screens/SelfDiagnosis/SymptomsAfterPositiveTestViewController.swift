//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol SymptomsAfterPositiveTestViewControllerInteracting {
    func didTapReturnHome()
    func didTapOnlineServicesLink()
}

extension SymptomsAfterPositiveTestViewController {
    private class Content: PrimaryButtonStickyFooterScrollingContent {
        init(interactor: Interacting, isolationEndDate: Date) {
            let daysToIsolate = LocalDay.today.daysRemaining(until: isolationEndDate)
            
            let headingStack = UIStackView(
                content: BasicContent(
                    views: [
                        BaseLabel()
                            .set(text: localize(.positive_test_result_start_to_isolate_title))
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
            .accessibilityLabel(localize(.positive_test_start_to_isolate_accessibility_label(days: daysToIsolate)))
            
            super.init(
                scrollingViews: [
                    UIImageView(.isolationStartIndex).styleAsDecoration(),
                    headingStack,
                    InformationBox.indication.warning(localize(.self_diagnosis_symptoms_after_positive_info)),
                    localizeAndSplit(.self_diagnosis_symtpoms_after_positive_body).map {
                        BaseLabel().set(text: $0).styleAsBody()
                    },
                    BaseLabel().set(text: localize(.self_diagnosis_symptoms_after_positive_advice)).styleAsBody(),
                    LinkButton(
                        title: localize(.self_diagnosis_symptoms_after_positive_link),
                        action: interactor.didTapOnlineServicesLink
                    ),
                    
                ],
                primaryButton: (
                    title: localize(.self_diagnosis_symptoms_after_positive_button_title),
                    action: interactor.didTapReturnHome
                )
            )
        }
    }
}

public class SymptomsAfterPositiveTestViewController: StickyFooterScrollingContentViewController {
    public typealias Interacting = SymptomsAfterPositiveTestViewControllerInteracting
    private let interactor: Interacting
    
    public init(interactor: Interacting, isolationEndDate: Date) {
        self.interactor = interactor
        super.init(content: Content(interactor: interactor, isolationEndDate: isolationEndDate))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
