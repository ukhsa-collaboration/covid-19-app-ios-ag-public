//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol PlodTestResultViewControllerInteracting {
    func didTapReturnHome()
}

extension PlodTestResultViewController {
    private class Content: PrimaryButtonStickyFooterScrollingContent {
        init(interactor: Interacting) {
            super.init(
                scrollingViews: [
                    BaseLabel().set(text: localizeForCountry(.plod_test_result_title)).styleAsPageHeader().centralized(),
                    BaseLabel().set(text: localizeForCountry(.plod_test_result_subtitle)).styleAsHeading().centralized(),
                    InformationBox.indication.warning(localizeForCountry(.plod_test_result_warning)),
                    localizeForCountryAndSplit(.plod_test_result_description)
                        .map { BaseLabel().styleAsBody().set(text: String($0)) },
                ],
                primaryButton: (
                    title: localize(.plod_test_result_button_title),
                    action: interactor.didTapReturnHome
                )
            )
        }
    }
}

public class PlodTestResultViewController: StickyFooterScrollingContentViewController {

    public typealias Interacting = PlodTestResultViewControllerInteracting

    public init(interactor: Interacting) {
        super.init(content: Content(interactor: interactor))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
