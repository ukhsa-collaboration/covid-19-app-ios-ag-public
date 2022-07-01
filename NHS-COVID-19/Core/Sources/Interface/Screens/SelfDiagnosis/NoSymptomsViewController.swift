//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import UIKit

public protocol NoSymptomsViewControllerInteracting {
    func didTapReturnHome()
    func didTapNHS111Link()
    func didTapGettingTestedLink()
}

private class NoSymptomsContent: PrimaryButtonStickyFooterScrollingContent {
    public typealias Interacting = NoSymptomsViewControllerInteracting

    public init(interactor: Interacting) {
        super.init(
            scrollingViews: [
                UIImageView(.isolationEnded).styleAsDecoration(),
                BaseLabel().set(text: localize(.no_symptoms_heading)).styleAsPageHeader(),

                localizeAndSplit(.no_symptoms_still_get_test_body)
                    .map { BaseLabel().set(text: $0).styleAsBody() },

                LinkButton(title: localize(.no_symptoms_getting_tested_link_label), action: interactor.didTapGettingTestedLink),

                localizeAndSplit(.no_symptoms_develop_symptoms_body)
                    .map { BaseLabel().set(text: $0).styleAsBody() },

                LinkButton(title: localize(.no_symptoms_link), action: interactor.didTapNHS111Link),
            ],
            primaryButton: (
                title: localize(.no_symptoms_return_home_button),
                action: interactor.didTapReturnHome
            )
        )
    }
}

public class NoSymptomsViewController: StickyFooterScrollingContentViewController {
    public typealias Interacting = NoSymptomsViewControllerInteracting

    public init(interactor: Interacting) {
        super.init(content: NoSymptomsContent(interactor: interactor))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
