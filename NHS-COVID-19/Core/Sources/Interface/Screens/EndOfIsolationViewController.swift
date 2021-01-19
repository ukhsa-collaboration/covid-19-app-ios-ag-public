//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol EndOfIsolationViewControllerInteracting {
    func didTapOnlineServicesLink()
    func didTapReturnHome()
}

private class EndOfIsolationContent: PrimaryButtonStickyFooterScrollingContent {
    public typealias Interacting = EndOfIsolationViewControllerInteracting
    
    static func endOfIsolationLabelText(endDate: Date, currentDate: Date) -> String {
        if endDate < currentDate {
            return localize(.end_of_isolation_has_passed_description(at: endDate))
        } else {
            return localize(.end_of_isolation_is_near_description(at: endDate))
        }
    }
    
    public init(interactor: Interacting, isolationEndDate: Date, isIndexCase: Bool, currentDateProvider: DateProviding) {
        super.init(
            scrollingViews: [
                UIImageView(.isolationEnded).styleAsDecoration().isHidden(!isIndexCase),
                UIImageView(.isolationEndedWarning).styleAsDecoration().isHidden(isIndexCase),
                BaseLabel()
                    .set(text: localize(.end_of_isolation_isolate_title))
                    .styleAsPageHeader()
                    .centralized(),
                BaseLabel()
                    .set(text: Self.endOfIsolationLabelText(endDate: isolationEndDate, currentDate: currentDateProvider.currentDate))
                    .styleAsHeading()
                    .centralized(),
                
                InformationBox.indication.warning(localize(.end_of_isolation_isolate_if_have_symptom_warning))
                    .isHidden(!isIndexCase),
                BaseLabel().set(text: localize(.end_of_isolation_link_label)).styleAsBody(),
                LinkButton(
                    title: localize(.end_of_isolation_online_services_link),
                    action: interactor.didTapOnlineServicesLink
                ),
            ],
            primaryButton: (
                title: localize(.end_of_isolation_corona_back_to_home_button),
                action: interactor.didTapReturnHome
            )
        )
    }
}

public class EndOfIsolationViewController: StickyFooterScrollingContentViewController {
    public typealias Interacting = EndOfIsolationViewControllerInteracting
    
    public init(interactor: Interacting, isolationEndDate: Date, isIndexCase: Bool, currentDateProvider: DateProviding) {
        super.init(content: EndOfIsolationContent(
            interactor: interactor,
            isolationEndDate: isolationEndDate,
            isIndexCase: isIndexCase,
            currentDateProvider: currentDateProvider
        ))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
