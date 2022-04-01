//
// Copyright © 2022 DHSC. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol IsolationAdviceForSymptomaticCasesEnglandViewControllerInteracting {
    func didTapContinue()
}

extension IsolationAdviceForSymptomaticCasesEnglandViewController {

    private struct Content {
        let views: [StackViewContentProvider]
        
        init(interactor: Interacting) {
            views = [
                UIImageView(.shareKeysReview)
                    .styleAsDecoration(),
                BaseLabel()
                    .styleAsPageHeader()
                    .set(text: localize(.isolation_advice_symptomatic_title_england))
                    .centralized(),
                InformationBox.indication.warning(localize(.isolation_advice_symptomatic_info_england)),
                BaseLabel()
                    .styleAsBody()
                    .set(text: localize(.isolation_advice_symptomatic_description_england)),
                SpacerView(),
                PrimaryButton(
                    title: localize(.isolation_advice_symptomatic_primary_button_title_england),
                    action: interactor.didTapContinue
                ),
            ]
        }
    }
}

public class IsolationAdviceForSymptomaticCasesEnglandViewController: ScrollingContentViewController {
    public typealias Interacting = IsolationAdviceForSymptomaticCasesEnglandViewControllerInteracting
    private let interactor: Interacting
    
    public init(interactor: Interacting) {
        self.interactor = interactor
        super.init(views: Content(interactor: interactor).views)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
    }
    
}

