//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import UIKit

public protocol RiskyVenueInformationBookATestViewControllerInteracting {
    func bookATestLaterTapped()
    func bookATestTapped()
    func closeTapped()
}

extension RiskyVenueInformationBookATestViewController {
    private class Content: PrimaryButtonStickyFooterScrollingContent {
        init(interactor: Interacting) {
            let title = localize(.checkin_risky_venue_information_warn_and_book_a_test_title)
            
            let scrollingViews: [UIView] = [
                UIImageView(.coronaVirus).styleAsDecoration(),
                BaseLabel().set(text: title).styleAsPageHeader().centralized(),
                BaseLabel().set(
                    text: localize(.checkin_risky_venue_information_warn_and_book_a_test_info)
                )
                .styleAsBody(),
                BulletedList(
                    rows: localizeAndSplit(.checkin_risky_venue_information_warn_and_book_a_test_bulleted_list)
                ),
                BaseLabel().set(
                    text: localize(.checkin_risky_venue_information_warn_and_book_a_test_additional_info)
                )
                .styleAsBody(),
            ]
            
            super.init(
                scrollingViews: scrollingViews,
                primaryButton: (
                    title: localize(.checkin_risky_venue_information_book_a_test_button_title),
                    action: interactor.bookATestTapped
                ),
                secondaryButton: (
                    title: localize(.checkin_risky_venue_information_will_book_a_test_later_button_title),
                    action: interactor.bookATestLaterTapped
                )
            )
        }
        
    }
}

public class RiskyVenueInformationBookATestViewController: StickyFooterScrollingContentViewController {
    public typealias Interacting = RiskyVenueInformationBookATestViewControllerInteracting
    
    private let interactor: Interacting
    
    public init(interactor: Interacting) {
        self.interactor = interactor
        super.init(content: Content(interactor: interactor))
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    @objc private func didTapClose() {
        interactor.closeTapped()
    }
    
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = UIColor(.nhsBlue)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: localize(.checkin_risky_venue_information_warn_and_book_a_test_close_button), style: .done, target: self, action: #selector(didTapClose))
    }
}
