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

private class EndOfIsolationContent {
    public typealias Interacting = EndOfIsolationViewControllerInteracting
    let views: [StackViewContentProvider]

    static func endOfIsolationLabelText(endDate: Date, currentDate: Date) -> String {
        if endDate < currentDate {
            return localizeForCountry(.end_of_isolation_has_passed_description(at: endDate))
        } else {
            return localizeForCountry(.end_of_isolation_is_near_description(at: endDate))
        }
    }

    public init(interactor: Interacting, isolationEndDate: Date, isIndexCase: Bool, country: Country, currentDateProvider: DateProviding) {
        views = [
                UIImageView(.isolationEnded).styleAsDecoration().isHidden(!isIndexCase),
                UIImageView(.isolationEndedWarning).styleAsDecoration().isHidden(isIndexCase),
                BaseLabel()
                    .set(text: localizeForCountry(.end_of_isolation_isolate_title))
                    .styleAsPageHeader()
                    .centralized(),
                BaseLabel()
                    .set(text: Self.endOfIsolationLabelText(endDate: isolationEndDate, currentDate: currentDateProvider.currentDate))
                    .styleAsHeading()
                    .centralized(),
                InformationBox.indication.warning(localizeForCountry(.end_of_isolation_isolate_if_have_symptom_warning))
                    .isHidden(!isIndexCase),
                BaseLabel().set(text: localizeForCountry(.end_of_isolation_link_label)).styleAsBody(),
                LinkButton(
                    title: localizeForCountry(.end_of_isolation_online_services_link),
                    action: interactor.didTapOnlineServicesLink
                ),
                SpacerView(),
                PrimaryButton(
                    title: localize(.end_of_isolation_corona_back_to_home_button),
                    action: interactor.didTapReturnHome
                )
        ]
    }
}

public class EndOfIsolationViewController: ScrollingContentViewController {
    public typealias Interacting = EndOfIsolationViewControllerInteracting

    public init(interactor: Interacting, isolationEndDate: Date, isIndexCase: Bool, currentDateProvider: DateProviding, currentCountry: Country) {
            super.init(views: EndOfIsolationContent(
                interactor: interactor,
                isolationEndDate: isolationEndDate,
                isIndexCase: isIndexCase,
                country: currentCountry,
                currentDateProvider: currentDateProvider).views)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
