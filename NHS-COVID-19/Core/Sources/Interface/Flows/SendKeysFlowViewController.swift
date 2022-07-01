//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import UIKit

public protocol SendKeysFlowViewControllerInteracting {
    func shareKeys(flowType: SendKeysFlowViewController.ShareFlowType) -> AnyPublisher<Void, Error>
    func doNotShareKeys(flowType: SendKeysFlowViewController.ShareFlowType)
}

public class SendKeysFlowViewController: BaseNavigationController {
    public typealias Interacting = SendKeysFlowViewControllerInteracting

    private var shareKeysCancellable: AnyCancellable?
    private let interactor: Interacting
    private let shareFlowType: ShareFlowType

    public enum ShareFlowType {
        case initial
        case reminder
    }

    private enum State {
        case started
        case loading
        case failed
    }

    private var state: State = .started {
        didSet {
            update()
        }
    }

    public init(
        interactor: Interacting,
        shareFlowType: ShareFlowType
    ) {
        self.interactor = interactor
        self.shareFlowType = shareFlowType
        super.init()
        update()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update() {
        switch state {
        case .started:
            switch shareFlowType {
            case .initial:
                let interactor = ShareKeysViewControllerInteractor(didTapContinue: { [weak self] in
                    self?.state = .loading
                })
                let viewController = ShareKeysViewController(interactor: interactor)
                viewControllers = [viewController]
            case .reminder:
                let interactor = ShareKeysReminderViewControllerInteractor(
                    didTapShareResult: { [weak self] in
                        self?.state = .loading
                    },
                    didTapDoNotShareResult: { [weak self] in
                        self?.cancel()
                    }
                )
                let reminderVC = ShareKeysReminderViewController(interactor: interactor)
                viewControllers = [reminderVC]
            }

        case .loading:
            let loadingViewControllerInteractor = LoadingViewControllerInteractor(didTapCancel: { [weak self] in
                self?.cancel()
            })

            let loadingViewController = LoadingViewController(interactor: loadingViewControllerInteractor, title: "")
            viewControllers = [loadingViewController]

            shareKeysCancellable = interactor.shareKeys(flowType: shareFlowType)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }

                    switch completion {
                    case .finished:
                        break
                    case .failure:
                        self.state = .failed
                    }
                }, receiveValue: {})
        case .failed:
            let loadingErrorViewInteractor = LoadingErrorViewControllerInteractor(didTapCancel: { [weak self] in
                self?.cancel()
            }, didTapRetry: { [weak self] in
                self?.state = .loading
            })

            let loadingErrorViewController = LoadingErrorViewController(interacting: loadingErrorViewInteractor, title: "")
            viewControllers = [loadingErrorViewController]
        }
    }

    private func cancel() {
        interactor.doNotShareKeys(flowType: shareFlowType)
        shareKeysCancellable = nil
    }
}

public extension SendKeysFlowViewController.ShareFlowType {

    init?(hasFinishedInitialKeySharingFlow: Bool, hasTriggeredReminderNotification: Bool) {
        if !hasFinishedInitialKeySharingFlow {
            self = .initial
        } else if hasTriggeredReminderNotification {
            self = .reminder
        } else {
            return nil
        }
    }

}

private struct LoadingViewControllerInteractor: LoadingViewController.Interacting {
    private let _didTapCancel: () -> Void

    init(didTapCancel: @escaping () -> Void) {
        _didTapCancel = didTapCancel
    }

    func didTapCancel() {
        _didTapCancel()
    }
}

private struct LoadingErrorViewControllerInteractor: LoadingErrorViewController.Interacting {
    private let _didTapCancel: () -> Void
    private let _didTapRetry: () -> Void

    init(didTapCancel: @escaping () -> Void, didTapRetry: @escaping () -> Void) {
        _didTapCancel = didTapCancel
        _didTapRetry = didTapRetry
    }

    func didTapCancel() {
        _didTapCancel()
    }

    func didTapRetry() {
        _didTapRetry()
    }
}

private struct ConfirmationInteractor: ShareKeysViewController.Interacting {
    var didTapContinue: () -> Void
}

private struct ShareKeysViewControllerInteractor: ShareKeysViewController.Interacting {
    var didTapContinue: () -> Void

    init(didTapContinue: @escaping () -> Void) {
        self.didTapContinue = didTapContinue
    }
}

private struct ShareKeysReminderViewControllerInteractor: ShareKeysReminderViewControllerInteracting {
    var didTapShareResult: () -> Void
    var didTapDoNotShareResult: () -> Void
}
