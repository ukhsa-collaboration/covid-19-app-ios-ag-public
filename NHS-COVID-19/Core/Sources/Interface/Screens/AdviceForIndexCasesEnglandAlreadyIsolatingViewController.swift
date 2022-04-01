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
        
        init(interactor: Interacting) {
            
            views = [
                UIImageView(.isolationStartIndex)
                    .styleAsDecoration(),
                BaseLabel()
                    .styleAsPageHeader()
                    .centralized()
                    .set(text: localize(.index_case_already_isolating_advice_heading_title)),
                
                InformationBox.indication.warning(localize(.index_case_already_isolating_advice_information_box_description)),
                BaseLabel()
                    .styleAsBody()
                    .set(text: localize(.index_case_already_isolating_advice_body)),
                
                LinkButton(
                    title: localize(.index_case_already_isolating_advice_common_question_link_button),
                    action: interactor.didTapCommonQuestions
                ),
                BaseLabel()
                    .styleAsBody()
                    .set(text: localize(.index_case_already_isolating_advice_further_advice)),
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
    
    public init(interactor: Interacting) {
        self.interactor = interactor
        super.init(views: Content(interactor: interactor).views)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
