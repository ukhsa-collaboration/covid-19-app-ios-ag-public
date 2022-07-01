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

    public enum ViewType {
        case onboarding
        case contactTracing
    }

    public static func viewController(for type: ViewType, interactor: Interacting, country: Country) -> BluetoothDisabledWarningViewController {
        switch type {
        case .onboarding:
            return BluetoothDisabledWarningViewController(
                interactor: interactor,
                country: country,
                titleText: localize(.launcher_permissions_bluetooth_title),
                hintText: localize(.launcher_permissions_bluetooth_hint),
                descriptionText: localizeAndSplit(.launcher_permissions_bluetooth_description),
                primaryButtonTitle: localize(.launcher_permissions_bluetooth_button),
                secondaryButtonTitle: localize(.launcher_permissions_bluetooth_secondary_button)
            )
        case .contactTracing:
            return BluetoothDisabledWarningViewController(
                interactor: interactor,
                country: country,
                titleText: localize(.contact_tracing_permissions_bluetooth_title),
                hintText: localize(.contact_tracing_permissions_bluetooth_hint),
                descriptionText: localizeAndSplit(.contact_tracing_permissions_bluetooth_description),
                primaryButtonTitle: localize(.contact_tracing_permissions_bluetooth_button),
                secondaryButtonTitle: localize(.contact_tracing_permissions_bluetooth_secondary_button)
            )
        }
    }

    private init(
        interactor: Interacting,
        country: Country,
        titleText: String,
        hintText: String,
        descriptionText: [String],
        primaryButtonTitle: String,
        secondaryButtonTitle: String
    ) {
        super.init(
            views: [
                LogoStrapline(.nhsBlue, style: .home(country)),
                UIImageView(.shareKeysReview).styleAsDecoration(),
                BaseLabel().styleAsPageHeader().set(text: titleText),
                InformationBox.indication(text: hintText, style: .warning),
            ]
                +
                descriptionText.map { BaseLabel().styleAsBody().set(text: $0) }
                +
                [
                    SpacerView(),
                    PrimaryButton(
                        title: primaryButtonTitle,
                        action: interactor.didTapSettings
                    ),
                    SecondaryButton(
                        title: secondaryButtonTitle,
                        action: interactor.didTapContinue
                    ),
                ]
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
