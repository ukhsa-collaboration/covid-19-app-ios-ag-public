//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public protocol NoSymptomsViewControllerInteracting {
    func didTapReturnHome()
    func didTapNHS111Link()
}

private class NoSymptomsContent: PrimaryButtonStickyFooterScrollingContent {
    public typealias Interacting = NoSymptomsViewControllerInteracting
    
    public init(interactor: Interacting) {
        super.init(
            scrollingViews: [
                UIImageView(.isolationEnded).styleAsDecoration(),
                UILabel().set(text: localize(.no_symptoms_heading)).styleAsPageHeader(),
                UILabel().set(text: localize(.no_symptoms_body_1)).styleAsBody(),
                UILabel().set(text: localize(.no_symptoms_body_2)).styleAsBody(),
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
