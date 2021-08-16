//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import Localization
import UIKit

public protocol NewNoSymptomsViewControllerInteracting {
    func didTapReturnHome()
    func didTapNHSGuidanceLink()
    func didTapBookAPCRTestLink()
}

private class NewNoSymptomsContent {
    typealias Interacting = NewNoSymptomsViewControllerInteracting
    
    var views: [StackViewContentProvider]
    
    public init(interactor: Interacting) {
        views = [
            UIImageView(.isolationStartIndex)
                .styleAsDecoration(),
            BaseLabel().styleAsPageHeader()
                .set(text: localize(.new_no_symptoms_screen_header))
                .centralized(),
            
            BaseLabel().styleAsBody()
                .set(text: localize(.new_no_symptoms_screen_introduction_line)),
            
            BaseLabel().styleAsBoldBody()
                .accessibilityTraits(.header)
                .set(text: localize(.new_no_symptoms_screen_block1_heading)),
            BaseLabel().styleAsBody()
                .set(text: localize(.new_no_symptoms_screen_block1_body)),
            
            BaseLabel().styleAsBoldBody()
                .accessibilityTraits(.header)
                .set(text: localize(.new_no_symptoms_screen_block2_heading)),
            BaseLabel().styleAsBody()
                .set(text: localize(.new_no_symptoms_screen_block2_body)),
            
            BaseLabel().styleAsBoldBody()
                .accessibilityTraits(.header)
                .set(text: localize(.new_no_symptoms_screen_block3_heading)),
            BaseLabel().styleAsBody()
                .set(text: localize(.new_no_symptoms_screen_block3_body)),
            
            BaseLabel().styleAsBoldBody()
                .accessibilityTraits(.header)
                .set(text: localize(.new_no_symptoms_screen_block4_heading)),
            BaseLabel().styleAsBody()
                .set(text: localize(.new_no_symptoms_screen_block4_body)),
            
            // MARK: PCR testing block
            
            BaseLabel().styleAsHeading()
                .set(text: localize(.new_no_symptoms_screen_pcr_testing_header)),
            
            WelcomePoint(
                image: .swabTest,
                body: localize(.new_no_symptoms_screen_pcr_testing_text),
                link:
                (
                    title: localize(.new_no_symptoms_screen_pcr_testing_link_title),
                    action: interactor.didTapBookAPCRTestLink
                )
            ),
            
            // MARK: General guidance
            
            BaseLabel().styleAsHeading()
                .set(text: localize(.new_no_symptoms_screen_general_guidance_header)),
            
            localizeAndSplit(.new_no_symptoms_screen_general_guidance_text)
                .map { BaseLabel().set(text: $0).styleAsBody() },
            
            LinkButton(title: localize(.new_no_symptoms_screen_general_guidance_link_title), action: interactor.didTapNHSGuidanceLink),
            
            // MARK: Footer button
            
            PrimaryButton(title: localize(.new_no_symptoms_screen_back_home_button), action: interactor.didTapReturnHome),
        ]
        
    }
}

public class NewNoSymptomsViewController: ScrollingContentViewController {
    public typealias Interacting = NewNoSymptomsViewControllerInteracting
    
    public init(interactor: Interacting) {
        let content = NewNoSymptomsContent(interactor: interactor)
        super.init(views: content.views)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
