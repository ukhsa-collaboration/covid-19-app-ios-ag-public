//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import SwiftUI
import UIKit

public protocol ContactTracingBluetoothInteracting {
    func didTapContinueButton()
}

extension ContactTracingBluetoothViewController {
    struct Content {
        var views: [StackViewContentProvider]

        init(interactor: Interacting, country: InterfaceProperty<Country>) {
            let bulletItemsView = BulletItems(rows: localizeAndSplit(.onboarding_permissions_bluetooth_checklist))
            let bulletItemsController = SelfSizingHostingController(rootView: bulletItemsView)
            bulletItemsController.view.backgroundColor = .clear

            views = [
                LogoStrapline(.primaryText, style: .home(country.wrappedValue)),
                UIImageView(.onboardingPermissions)
                    .styleAsDecoration(),
                BaseLabel()
                    .styleAsPageHeader()
                    .set(text: localize(.onboarding_permissions_bluetooth_title)),
                BaseLabel()
                    .styleAsBody()
                    .set(text: localize(.onboarding_permissions_bluetooth_description)),
                bulletItemsController.view,
                BaseLabel()
                    .styleAsBody()
                    .set(text: localize(.onboarding_permissions_bluetooth_description2)),
                SpacerView(),
                PrimaryButton(title: localize(.onboarding_permissions_bluetooth_continue_button_title), action: {
                    interactor.didTapContinueButton()
                }),
            ]
        }
    }
}

public class ContactTracingBluetoothViewController: ScrollingContentViewController {
    public typealias Interacting = ContactTracingBluetoothInteracting
    private let interactor: Interacting

    public init(interactor: Interacting, country: InterfaceProperty<Country>) {
        self.interactor = interactor

        super.init(views: Content(interactor: interactor, country: country).views)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
