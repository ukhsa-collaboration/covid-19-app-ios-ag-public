//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import UIKit

public protocol DailyContactTestingConfirmationViewControllerInteracting {
    func didTapConfirm()
}

private class DailyContactTestingConfirmationContent: PrimaryButtonStickyFooterScrollingContent {
    public typealias Interacting = DailyContactTestingConfirmationViewControllerInteracting
    
    private let interactor: Interacting
    
    public init(interactor: Interacting) {
        self.interactor = interactor
        
        super.init(
            scrollingViews: [
                BaseLabel().set(text: localize(.daily_contact_testing_confirmation_screen_heading)).styleAsPageHeader(),
                BaseLabel().set(text: localize(.daily_contact_testing_confirmation_screen_description)).styleAsBody(),
                BaseLabel().set(text: localize(.daily_contact_testing_confirmation_screen_bulleted_list_continue_heading)).styleAsBody(),
                BulletedList(rows: localizeAndSplit(.daily_contact_testing_confirmation_screen_bulleted_list_continue)),
                BaseLabel().set(text: localize(.daily_contact_testing_confirmation_screen_bulleted_list_no_longer_heading)).styleAsBody(),
                BulletedList(rows: localizeAndSplit(.daily_contact_testing_confirmation_screen_bulleted_list_no_longer)),
            ],
            primaryButton: (
                title: localize(.daily_contact_testing_confirmation_screen_confirm_button_title),
                action: {
                    interactor.didTapConfirm()
                }
            )
        )
    }
}

public class DailyContactTestingConfirmationViewController: StickyFooterScrollingContentViewController {
    public typealias Interacting = DailyContactTestingConfirmationViewControllerInteracting
    
    public init(interactor: Interacting) {
        super.init(content: DailyContactTestingConfirmationContent(interactor: interactor))
        title = localize(.daily_contact_testing_confirmation_screen_title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
}
