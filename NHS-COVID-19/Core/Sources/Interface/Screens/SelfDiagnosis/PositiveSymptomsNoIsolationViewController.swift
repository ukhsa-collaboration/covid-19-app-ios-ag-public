//
// Copyright © 2022 DHSC. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol PositiveSymptomsNoIsolationViewControllerInteracting {
    func backHomeButtonTapped()
    func didTapCancel()
    func nhs111OnlineLinkTapped()
}

extension PositiveSymptomsNoIsolationViewController {
    private class Content: PrimaryButtonStickyFooterScrollingContent {
        init(interactor: Interacting) {
            super.init(
                scrollingViews: [
                    UIImageView(.isolationStartIndex).styleAsDecoration(),
                    SpacerView(),
                    BaseLabel()
                        .set(text: localize(.positive_symptoms_no_isolation_heading))
                        .styleAsPageHeader()
                        .centralized()
                        .isAccessibilityElement(true),
                    localizeAndSplit(.positive_symptoms_no_isolation_explanation).map {
                        BaseLabel().set(text: $0).styleAsBody()
                    },
                    SpacerView(),
                    BaseLabel().set(text: localize(.positive_symptoms_no_isolation_advice)).styleAsBody(),
                    LinkButton(
                        title: localize(.nhs_111_online_service),
                        action: interactor.nhs111OnlineLinkTapped
                    ),
                ],
                primaryButton: (
                    title: localize(.positive_symptoms_no_isolation_home_button),
                    action: interactor.backHomeButtonTapped
                )
            )
        }
    }
}

public class PositiveSymptomsNoIsolationViewController: StickyFooterScrollingContentViewController {
    public typealias Interacting = PositiveSymptomsNoIsolationViewControllerInteracting
    private let interactor: Interacting

    public init(interactor: Interacting) {
        self.interactor = interactor
        super.init(content: Content(interactor: interactor))
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
