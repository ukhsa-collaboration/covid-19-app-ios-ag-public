//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol EndOfIsolationViewControllerInteracting {
    func didTapOnlineServicesLink()
    func didTapReturnHome()
    func didTapPrimaryLinkButton()
}

private class EndOfIsolationEnglandContent {
    public typealias Interacting = EndOfIsolationViewControllerInteracting
    let views: [StackViewContentProvider]
    
    static func endOfIsolationLabelText(endDate: Date, currentDate: Date) -> String {
        if endDate < currentDate {
            return localize(.end_of_isolation_has_passed_description(at: endDate))
        } else {
            return localize(.end_of_isolation_is_near_description(at: endDate))
        }
    }
    
    public init(interactor: Interacting, isolationEndDate: Date, isIndexCase: Bool, currentDateProvider: DateProviding) {
        
        views = [
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
                SpacerView(),
                PrimaryButton(
                    title: localize(.end_of_isolation_corona_back_to_home_button),
                    action: interactor.didTapReturnHome
                )
        ]
    }
}

private class EndOfIsolationWalesContent {
    public typealias Interacting = EndOfIsolationViewControllerInteracting
    let views: [StackViewContentProvider]
    
    public init(interactor: Interacting, isolationEndDate: Date, isIndexCase: Bool, numberOfIsolationDaysForIndexCase: Int?, currentDateProvider: DateProviding) {
        
        let isolationHasNotEnded: Bool  = isolationEndDate >= currentDateProvider.currentDate
        
        if isIndexCase {
            views = [
                UIImageView(isolationHasNotEnded ? .isolationContinue : .isolationEndedWarning)
                    .styleAsDecoration(),
                numberOfIsolationDaysForIndexCase.map({ _ -> [UIView] in
                    
                    return [
                        BaseLabel()
                            .set(text: isolationHasNotEnded ? localize(.your_isolation_are_ending_soon_wales) : localize(.expiration_notification_description_passed_wales))
                            .styleAsPageHeader()
                            .centralized(),
                        BaseLabel()
                            .set(text: localize(.expiration_notification_testing_advice_wales_after_isolation_ended_wales))
                            .styleAsBody()
                            .isHidden(isolationHasNotEnded),
                        InformationBox.indication.warning(isolationHasNotEnded ? localize(.expiration_notification_callout_advice_wales) : localize(.end_of_isolation_index_case_isolation_ended_callout_wales)),
                        BaseLabel()
                            .set(text: localize(.expiration_notification_testing_advice_wales_before_isolation_ended_wales))
                            .styleAsBody()
                            .isHidden(!isolationHasNotEnded),
                    ]
                }).flatMap{ $0 },
                BaseLabel().set(text: localize(.end_of_isolation_link_label)).styleAsBody(),
                LinkButton(
                    title: localize(.end_of_isolation_online_services_link),
                    action: interactor.didTapOnlineServicesLink
                ),
                SpacerView(),
                PrimaryLinkButton(
                    title: localize(.expiration_notification_link_button_title_wales),
                    action: interactor.didTapPrimaryLinkButton
                ),
                SecondaryButton(
                    title: localize(.end_of_isolation_corona_back_to_home_button),
                    action: interactor.didTapReturnHome)
            ].compactMap{ $0 }
        }
        else {
            views = [
                UIImageView(isolationHasNotEnded ? .isolationEndedWarning : .isolationEnded)
                    .styleAsDecoration(),
                BaseLabel()
                    .set(text: localize(.end_of_isolation_isolate_title))
                    .styleAsPageHeader()
                    .centralized(),
                BaseLabel()
                    .set(text: isolationHasNotEnded ? localize(.end_of_isolation_is_near_description(at: isolationEndDate)) : localize(.end_of_isolation_has_passed_description(at: isolationEndDate)))
                    .styleAsHeading()
                    .centralized(),
                BaseLabel().set(text: localize(.end_of_isolation_link_label)).styleAsBody(),
                LinkButton(
                    title: localize(.end_of_isolation_online_services_link),
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
}

public class EndOfIsolationViewController: ScrollingContentViewController {
    public typealias Interacting = EndOfIsolationViewControllerInteracting
    
    public init(interactor: Interacting, isolationEndDate: Date, isIndexCase: Bool, numberOfIsolationDaysForIndexCase: Int?, currentDateProvider: DateProviding, currentCountry: Country) {
        switch currentCountry {
            case .england:
                super.init(views: EndOfIsolationEnglandContent(
                    interactor: interactor,
                    isolationEndDate: isolationEndDate,
                    isIndexCase: isIndexCase,
                    currentDateProvider: currentDateProvider).views)
            case .wales:
                super.init(views: EndOfIsolationWalesContent(
                    interactor: interactor,
                    isolationEndDate: isolationEndDate,
                    isIndexCase: isIndexCase,
                    numberOfIsolationDaysForIndexCase: numberOfIsolationDaysForIndexCase,
                    currentDateProvider: currentDateProvider).views)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
