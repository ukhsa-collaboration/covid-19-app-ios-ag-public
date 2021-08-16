//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import Localization
import UIKit

public protocol ContactCaseExposureInfoInteracting {
    func didTapContinue()
}

public struct ContactCaseExposureInfoContent {
    public typealias Interacting = ContactCaseExposureInfoInteracting
    
    var views: [StackViewContentProvider]
    
    public init(interactor: Interacting) {
        views = [
            UIImageView(.coronaVirus)
                .styleAsDecoration()
                .color(.nhsBlue),
            BaseLabel().styleAsPageHeader()
                .set(text: localize(.contact_case_exposure_info_screen_title))
                .centralized(),
            InformationBox.indication(
                text: localize(.contact_case_exposure_info_screen_information),
                style: .warning
            ),
            WelcomePoint(image: .thermometer, body: localize(.contact_case_exposure_info_screen_if_you_have_symptoms)),
            PrimaryButton(title: localize(.contact_case_exposure_info_screen_continue_button), action: interactor.didTapContinue),
        ]
    }
}

public class ContactCaseExposureInfoViewController: ScrollingContentViewController {
    public typealias Interacting = ContactCaseExposureInfoInteracting
    
    public init(interactor: Interacting) {
        let content = ContactCaseExposureInfoContent(interactor: interactor)
        super.init(views: content.views)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}
