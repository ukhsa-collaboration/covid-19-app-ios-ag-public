//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol BluetoothDisabledWarningViewControllerInteracting {
    func didTapSettings()
    func didTapContinue()
}

public class BluetoothDisabledWarningViewController: ScrollingContentViewController {
    public typealias Interacting = BluetoothDisabledWarningViewControllerInteracting
    
    public init(interactor: Interacting, country: Country) {
        super.init(
            views: [
                LogoStrapline(.nhsBlue, style: .home(country)),
                UIImageView(.shareKeysReview).styleAsDecoration(),
                BaseLabel().styleAsPageHeader().set(text: localize(.launcher_permissions_bluetooth_title)),
                InformationBox.indication(text: localize(.launcher_permissions_bluetooth_hint), style: .warning),
                BaseLabel().styleAsBody().set(text: localize(.launcher_permissions_bluetooth_description)),
                SpacerView(),
                PrimaryButton(
                    title: localize(.launcher_permissions_bluetooth_button),
                    action: interactor.didTapSettings
                ),
                SecondaryButton(
                    title: localize(.launcher_permissions_bluetooth_secondary_button),
                    action: interactor.didTapContinue
                ),
            ]
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
