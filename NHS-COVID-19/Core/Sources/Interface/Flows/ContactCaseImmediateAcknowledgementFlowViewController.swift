//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Localization
import SwiftUI
import UIKit

public protocol ContactCaseImmediateAcknowledgementFlowViewControllerInteracting {
    func acknowledge() -> Void
}

public class ContactCaseImmediateAcknowledgementFlowViewController: BaseNavigationController {
    public typealias Interacting = ContactCaseImmediateAcknowledgementFlowViewControllerInteracting

    fileprivate enum State {
        case exposureInfo
        case advice
    }

    fileprivate let interactor: Interacting
    private let exposureDate: Date
    private let openURL: (URL) -> Void
    private let country: Country

    @Published fileprivate var state: State
    private var cancellables: Set<AnyCancellable> = []

    public init(interactor: Interacting, country: Country, openURL: @escaping (URL) -> Void, exposureDate: Date) {
        self.interactor = interactor
        self.exposureDate = exposureDate
        self.country = country
        self.openURL = openURL
        state = .exposureInfo
        super.init()
        monitorState()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func monitorState() {
        $state
            .regulate(as: .modelChange)
            .sink { [weak self] state in
                self?.update(for: state)
            }
            .store(in: &cancellables)
    }

    private func update(for state: State) {
        pushViewController(rootViewController(for: state), animated: true)
    }

    private func rootViewController(for state: State) -> UIViewController {
        switch state {
        case .exposureInfo:
            return ContactCaseExposureInfoEnglandViewController(
                interactor: ContactCaseExposureInfoInteractor(viewController: self),
                exposureDate: exposureDate
            )

        case .advice:

            switch self.country {
            case .england:
                return ContactCaseNoIsolationAdviceViewController(
                    interactor: ContactCaseNoIsolationAdviceViewControllerInteractor(
                        viewController: self,
                        openURL: openURL
                    )
                )
            case .wales:
                return ContactCaseNoIsolationAdviceWalesViewController(
                    interactor: ContactCaseNoIsolationAdviceWalesViewControllerInteractor(
                        viewController: self,
                        openURL: openURL
                    )
                )
            }

        }
    }
}

// MARK: - Interactors

private struct ContactCaseExposureInfoInteractor: ContactCaseExposureInfoEnglandViewController.Interacting {
    private weak var viewController: ContactCaseImmediateAcknowledgementFlowViewController?

    init(viewController: ContactCaseImmediateAcknowledgementFlowViewController?) {
        self.viewController = viewController
    }

    func didTapContinue() {
        viewController?.state = .advice
    }
}

private struct ContactCaseNoIsolationAdviceViewControllerInteractor: ContactCaseNoIsolationAdviceViewController.Interacting {
    private weak var viewController: ContactCaseImmediateAcknowledgementFlowViewController?
    private let openURL: (URL) -> Void

    init(viewController: ContactCaseImmediateAcknowledgementFlowViewController?, openURL: @escaping (URL) -> Void) {
        self.viewController = viewController
        self.openURL = openURL
    }

    func didTapBackToHome() {
        viewController?.interactor.acknowledge()
    }

    func didTapGuidanceForHouseholdContacts() {
        openURL(ExternalLink.guidanceForHouseholdContactsInEngland.url)
        viewController?.interactor.acknowledge()
    }

    func didTapReadGuidanceForContacts() {
        openURL(ExternalLink.guidanceForContactsInEngland.url)
        viewController?.interactor.acknowledge()
    }
}

private struct ContactCaseNoIsolationAdviceWalesViewControllerInteractor: ContactCaseNoIsolationAdviceWalesViewController.Interacting {
    private weak var viewController: ContactCaseImmediateAcknowledgementFlowViewController?
    private let openURL: (URL) -> Void

    init(viewController: ContactCaseImmediateAcknowledgementFlowViewController?, openURL: @escaping (URL) -> Void) {
        self.viewController = viewController
        self.openURL = openURL
    }

    func didTapBackToHome() {
        viewController?.interactor.acknowledge()
    }

    func didTapReadGuidanceForContacts() {
        openURL(ExternalLink.guidanceForContactsInWales.url)
        viewController?.interactor.acknowledge()
    }
}
