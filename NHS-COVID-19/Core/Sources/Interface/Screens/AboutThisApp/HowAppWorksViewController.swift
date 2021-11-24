//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import SwiftUI
import UIKit

public protocol HowAppWorksInteracting {
    func didTapContinueButton()
}

extension HowAppWorksViewController {
    struct Content {
        var views: [StackViewContentProvider]
        
        init(interactor: Interacting) {
            views = [
                LogoStrapline(.nhsBlue, style: .onboarding),
                UIImageView(.isolationEndedWarning)
                    .styleAsDecoration(),
                BaseLabel()
                    .styleAsPageHeader()
                    .set(text: localize(.onboarding_how_app_works_title)),
                
                WelcomePoint(image: .bluetooth, header: localize(.onboarding_how_app_works_bluetooth_bullet_header), body: localize(.onboarding_how_app_works_bluetooth_bullet_desc), link: nil),
                
                WelcomePoint(image: .contactTracingBatteryLife, header: localize(.onboarding_how_app_works_battery_bullet_header), body: localize(.onboarding_how_app_works_battery_bullet_desc), link: nil),
                
                WelcomePoint(image: .contactTracingNoTracking, header: localize(.onboarding_how_app_works_location_bullet_header), body: localize(.onboarding_how_app_works_location_bullet_desc), link: nil),
                
                WelcomePoint(image: .contactTracingPrivacy, header: localize(.onboarding_how_app_works_privacy_bullet_header), body: localize(.onboarding_how_app_works_privacy_bullet_desc), link: nil),
                
                PrimaryButton(
                    title: localize(.onboarding_how_app_works_continue),
                    action: interactor.didTapContinueButton
                ),
            ]
        }
    }
}

public class HowAppWorksViewController: ScrollingContentViewController {
    public typealias Interacting = HowAppWorksInteracting
    private let interactor: Interacting
    
    public init(interactor: Interacting) {
        self.interactor = interactor
        
        super.init(views: Content(interactor: interactor).views)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
