//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import Localization
import SwiftUI
import UIKit

public protocol ContactCaseExposureInfoInteracting {
    func didTapContinue()
}

public struct ContactCaseExposureInfoContent {
    public typealias Interacting = ContactCaseExposureInfoInteracting
    
    var views: [StackViewContentProvider]
    
    public init(interactor: Interacting,
                exposureDate: Date,
                isIndexCase: Bool) {
        let accordionController = UIHostingController(
            rootView: AccordionView(
                localize(.contact_case_exposure_info_screen_how_close_contacts_are_calculated_heading),
                displayMode: .singleWithChevron
            ) {
                ForEach.fromStrings(
                    localizeAndSplit(.contact_case_exposure_info_screen_how_close_contacts_are_calculated_body),
                    spacing: .standardSpacing
                ) {
                    Text($0).styleAsBody()
                }
            })
        let accordionView = accordionController.view!
        accordionView.backgroundColor = .clear
        
        // it fixes bug with height of expanded accordion on iOS 13 and iOS 15
        accordionView.translatesAutoresizingMaskIntoConstraints = false
        let accordionHeightConstraint = accordionView.heightAnchor.constraint(equalToConstant: 0)
        accordionController.rootView.onSizeChanged { size in
            guard size.height > 0 else { return }
            accordionHeightConstraint.constant = size.height
            accordionHeightConstraint.isActive = true
        }
        
        views = [
            UIImageView(.coronaVirus)
                .styleAsDecoration()
                .color(.nhsBlue),
            BaseLabel().styleAsPageHeader()
                .set(text: localize(.contact_case_exposure_info_screen_title))
                .centralized(),
            BaseLabel().styleAsBody()
                .set(text: localize(.contact_case_exposure_info_screen_exposure_date(date: exposureDate)))
                .centralized(),
            accordionView,
        ]
        
        if !isIndexCase {
            views.append(contentsOf: [
                InformationBox.indication(
                    text: localize(.contact_case_exposure_info_screen_information),
                    style: .warning
                ),
                WelcomePoint(image: .thermometer, body: localize(.contact_case_exposure_info_screen_if_you_have_symptoms)),
            ])
        }
        
        views.append(contentsOf: [
            UIView(), // This adds space when between the content and button. Otherwise the button is vertically stretched when the content height is less than screen height.
            PrimaryButton(title: localize(.contact_case_exposure_info_screen_continue_button), action: interactor.didTapContinue),
        ])
    }
}

public class ContactCaseExposureInfoViewController: ScrollingContentViewController {
    public typealias Interacting = ContactCaseExposureInfoInteracting
    
    public init(interactor: Interacting,
                exposureDate: Date,
                isIndexCase: Bool) {
        let content = ContactCaseExposureInfoContent(
            interactor: interactor,
            exposureDate: exposureDate,
            isIndexCase: isIndexCase
        )
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
