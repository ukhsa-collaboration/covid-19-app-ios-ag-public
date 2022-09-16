//
// Copyright © 2022 DHSC. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol AdviceForIndexCasesEnglandAlreadyIsolatingViewControllerInteracting {
    func didTapCommonQuestions()
    func didTapNHSOnline()
    func didTapContinue()
}

extension AdviceForIndexCasesEnglandAlreadyIsolatingViewController {
    private struct Content {
        let views: [StackViewContentProvider]

        init(interactor: Interacting, isolationEndDate: Date, currentDateProvider: DateProviding) {

            views = [
                UIImageView(.isolationContinue)
                    .styleAsDecoration(),
                BaseLabel()
                    .styleAsHeading()
                    .centralized()
                    .set(text: localize(.index_case_already_isolating_advice_heading_title)),

                BaseLabel()
                    .styleAsPageHeader()
                    .set(text: localize(.positive_symptoms_days(days: currentDateProvider.currentLocalDay.daysRemaining(until: isolationEndDate))))
                    .isAccessibilityElement(false)
                    .centralized(),

                InformationBox.indication.warning(localize(.index_case_already_isolating_advice_information_box_description)),
                BaseLabel()
                    .styleAsBody()
                    .set(text: localize(.index_case_already_isolating_advice_body)),
                BaseLabel()
                    .styleAsBody()
                    .set(text: localize(.further_advice_header)),
                LinkButton(
                    title: localize(.index_case_already_isolating_advice_nhs_onilne_link_button),
                    action: interactor.didTapNHSOnline
                ),
                SpacerView(),
                PrimaryButton(
                    title: localize(.index_case_already_isolating_advice_primary_button_title),
                    action: interactor.didTapContinue
                ),
            ]
        }
    }
}

public class AdviceForIndexCasesEnglandAlreadyIsolatingViewController: ScrollingContentViewController {
    public typealias Interacting = AdviceForIndexCasesEnglandAlreadyIsolatingViewControllerInteracting
    private let interactor: Interacting

    public init(interactor: Interacting, isolationEndDate: Date, currentDateProvider: DateProviding) {
        self.interactor = interactor
        super.init(views: Content(interactor: interactor, isolationEndDate: isolationEndDate, currentDateProvider: currentDateProvider).views)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
