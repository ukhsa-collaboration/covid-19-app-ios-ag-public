//
// Copyright © 2022 DHSC. All rights reserved.
//

import Localization
import UIKit

public protocol ClosureInteracting {
    func didTapURL1()
    func didTapURL2()
    func didTapURL3()
    func didTapURL4()
    func didTapURL5()
}

extension ClosureViewController {
    struct Content {
        var views: [StackViewContentProvider]

        init(interactor: Interacting) {
            views = [
                LogoStrapline(.nhsBlue, style: .closure),
                UIImageView(.onboardingStart)
                    .styleAsAccessibleDecoration(localize(.closure_image_accessibility_label)),
                BaseLabel()
                    .styleAsPageHeader()
                    .set(text: localize(.closure_title))
                    .centralized(),
                BaseLabel()
                    .styleAsBody()
                    .set(text: localize(.closure_paragraph)),

                LinkButton(title: localize(.closure_url_1_label)) {
                    interactor.didTapURL1()
                },
                LinkButton(title: localize(.closure_url_2_label)) {
                    interactor.didTapURL2()
                },
                LinkButton(title: localize(.closure_url_3_label)) {
                    interactor.didTapURL3()
                },
                LinkButton(title: localize(.closure_url_4_label)) {
                    interactor.didTapURL4()
                },
                LinkButton(title: localize(.closure_url_5_label)) {
                    interactor.didTapURL5()
                },
            ]
        }
    }
}

public class ClosureViewController: ScrollingContentViewController {
    public typealias Interacting = ClosureInteracting
    private let interactor: Interacting

    public init(interactor: Interacting) {
        UIAccessibility.post(notification: .screenChanged, argument: localize(.closure_page_name))
        self.interactor = interactor

        super.init(views: Content(interactor: interactor).views)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
