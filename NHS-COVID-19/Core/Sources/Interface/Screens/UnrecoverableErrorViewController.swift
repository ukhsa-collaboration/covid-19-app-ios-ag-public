//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import UIKit
import Common

public protocol UnrecoverableErrorViewControllerInteracting {
    func faqLinkTapped()
}

public class UnrecoverableErrorViewController: RecoverableErrorViewController {
    public typealias Interacting = UnrecoverableErrorViewControllerInteracting

    public init(interactor: Interacting, country: Country) {
        super.init(error: NonRecoverableErrorDetail(
            link: (title: localize(.unrecoverable_error_link), act: interactor.faqLinkTapped),
            logoStrapLineStyle: .home(country)
        ))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

private struct NonRecoverableErrorDetail: ErrorDetail {
    var action: (title: String, act: () -> Void)? = nil
    var link: (title: String, act: () -> Void)
    var logoStrapLineStyle: LogoStrapline.Style = .onboarding

    let title = localize(.unrecoverable_error_page_title)

    var content: [UIView] {
        let headingOne = BaseLabel()
        headingOne.styleAsHeading()
        headingOne.text = localize(.unrecoverable_error_heading_1)

        let headingTwo = BaseLabel()
        headingTwo.styleAsHeading()
        headingTwo.text = localize(.unrecoverable_error_heading_2)

        let descriptionLabel = BaseLabel()
        descriptionLabel.styleAsBody()
        descriptionLabel.text = localize(.unrecoverable_error_description_2)

        return [
            headingOne,
            BulletedList(rows: localizeAndSplit(.unrecoverable_error_bulleted_list)),
            headingTwo,
            descriptionLabel,
            LinkButton(title: link.title, action: link.act),
        ]

    }
}
