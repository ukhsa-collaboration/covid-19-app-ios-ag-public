//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public protocol StopIsolationViewControllerInteracting {
    var stopIsolation: () -> Void { get }
}

public class StopIsolationViewController: ScrollingContentViewController {
    public typealias Interacting = StopIsolationViewControllerInteracting
    
    public init(interactor: Interacting) {
        let content = BasicContent(
            views: [
                UIImageView(.stopIsolation).styleAsDecoration(),
                UILabel().set(text: localize(.stop_isolation_heading)).styleAsPageHeader(),
                localizeAndSplit(.stop_isolation_body).map {
                    UILabel().set(text: $0).styleAsSecondaryBody()
                },
                PrimaryButton(title: localize(.stop_isolation_countdown_button), action: interactor.stopIsolation),
            ],
            spacing: .standardSpacing,
            margins: .largeInset
        )
        
        super.init(content: content)
        title = localize(.stop_isolation_title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
