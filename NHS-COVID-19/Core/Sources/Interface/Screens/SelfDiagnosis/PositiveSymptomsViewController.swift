//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol PositiveSymptomsViewControllerInteracting {
    func didTapBookTest()
    func didTapCancel()
    func furtherAdviceLinkTapped()
}

extension PositiveSymptomsViewController {
    private class Content: PrimaryButtonStickyFooterScrollingContent {
        
        init(interactor: Interacting, isolationEndDate: Date) {
            let daysToIsolate = LocalDay.today.daysRemaining(until: isolationEndDate)
            
            let headingStack = UIStackView(
                content: BasicContent(
                    views: [
                        UILabel()
                            .set(text: localize(.positive_symptoms_please_isolate_for))
                            .styleAsHeading()
                            .centralized()
                            .isAccessibilityElement(false),
                        UILabel()
                            .set(text: localize(.positive_symptoms_days(days: daysToIsolate)))
                            .styleAsPageHeader()
                            .centralized()
                            .isAccessibilityElement(false),
                        UILabel()
                            .set(text: localize(.positive_symptoms_and_book_a_test))
                            .styleAsHeading()
                            .centralized()
                            .isAccessibilityElement(false),
                    ],
                    spacing: .zero,
                    margins: .zero
                )
            )
            .isAccessibilityElement(true)
            .accessibilityTraits([.header, .staticText])
            .accessibilityLabel(localize(.positive_symptoms_please_isolate_accessibility_label(days: daysToIsolate)))
            
            super.init(
                scrollingViews: [
                    UIImageView(.isolationStartIndex).styleAsDecoration(),
                    headingStack,
                    InformationBox.indication.warning(localize(.positive_symptoms_you_might_have_corona)),
                    localizeAndSplit(.positive_symptoms_explanation).map {
                        UILabel().set(text: $0).styleAsBody()
                    },
                    UILabel().set(text: localize(.positive_symptoms_link_label)).styleAsBody(),
                    LinkButton(
                        title: localize(.end_of_isolation_online_services_link),
                        action: interactor.furtherAdviceLinkTapped
                    ),
                ],
                primaryButton: (
                    title: localize(.positive_symptoms_corona_test_button),
                    action: interactor.didTapBookTest
                )
            )
        }
    }
}

public class PositiveSymptomsViewController: StickyFooterScrollingContentViewController {
    public typealias Interacting = PositiveSymptomsViewControllerInteracting
    private let interactor: Interacting
    
    public init(interactor: Interacting, isolationEndDate: Date) {
        self.interactor = interactor
        super.init(content: Content(interactor: interactor, isolationEndDate: isolationEndDate))
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
