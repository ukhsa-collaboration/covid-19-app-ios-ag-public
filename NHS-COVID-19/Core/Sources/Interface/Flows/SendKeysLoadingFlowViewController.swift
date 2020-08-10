//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import UIKit

public protocol SendKeysLoadingFlowViewControllerInteracting {
    func didTapOnlineServicesLink()
    func shareKeys() -> AnyPublisher<Void, Error>
    func didTapCancel()
}

public class SendKeysLoadingFlowViewController: UINavigationController {
    public typealias Interacting = SendKeysLoadingFlowViewControllerInteracting
    
    private var shareKeysCancellable: AnyCancellable?
    private let interactor: Interacting
    
    private var presentedNavigationController: UINavigationController?
    private var presentedValue: UIViewController? {
        didSet {
            if let presentedValue = presentedValue {
                if let presentedNavigationController = presentedNavigationController {
                    presentedNavigationController.viewControllers = [presentedValue]
                } else {
                    presentedNavigationController = UINavigationController(rootViewController: presentedValue)
                    presentedNavigationController?.isModalInPresentation = true
                    present(presentedNavigationController!, animated: true)
                }
            }
        }
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
    
    private let endOfIsolation: Date?
    
    public init(interactor: Interacting, endOfIsolation: Date?) {
        self.interactor = interactor
        self.endOfIsolation = endOfIsolation
        super.init(nibName: nil, bundle: nil)
        update()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update() {
        switch state {
        case .started:
            if let endOfIsolation = endOfIsolation {
                let positiveTestResultInteractor = PositiveTestResultInteractor(didTapContinue: { [weak self] in
                    self?.state = .loading
                }, didTapOnlineServicesLink: interactor.didTapOnlineServicesLink)
                viewControllers = [PositiveTestResultViewController(interactor: positiveTestResultInteractor, isolationEndDate: endOfIsolation)]
            } else {
                let positiveTestResultNoIsolationInteractor = PositiveTestResultNoIsolationInteractor(didTapContinue: { [weak self] in
                    self?.state = .loading
                }, didTapOnlineServicesLink: interactor.didTapOnlineServicesLink)
                viewControllers = [PositiveTestResultNoIsolationViewController(interactor: positiveTestResultNoIsolationInteractor)]
            }
        case .loading:
            let loadingViewControllerInteractor = LoadingViewControllerInteractor(didTapCancel: { [weak self] in
                self?.cancel()
            })
            
            let loadingViewController = LoadingViewController(interactor: loadingViewControllerInteractor, title: "")
            presentedValue = loadingViewController
            
            shareKeysCancellable = interactor.shareKeys().sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.dismissProgressView()
                case .failure:
                    self?.state = .failed
                }
            }, receiveValue: { _ in })
        case .failed:
            let loadingErrorViewInteractor = LoadingErrorViewControllerInteractor(didTapCancel: { [weak self] in
                self?.cancel()
            }, didTapRetry: { [weak self] in
                self?.state = .loading
            })
            
            let loadingErrorViewController = LoadingErrorViewController(interacting: loadingErrorViewInteractor, title: "")
            presentedValue = loadingErrorViewController
        }
    }
    
    private func cancel() {
        dismissProgressView()
        interactor.didTapCancel()
        shareKeysCancellable = nil
    }
    
    private func dismissProgressView() {
        presentedNavigationController?.dismiss(animated: true)
        presentedNavigationController = nil
    }
}

struct PositiveTestResultNoIsolationInteractor: PositiveTestResultNoIsolationViewControllerInteracting {
    
    private var _didTapContinue: () -> Void
    private var _didTapOnlineServicesLink: () -> Void
    
    init(didTapContinue: @escaping () -> Void, didTapOnlineServicesLink: @escaping () -> Void) {
        _didTapContinue = didTapContinue
        _didTapOnlineServicesLink = didTapOnlineServicesLink
    }
    
    func didTapContinue() {
        _didTapContinue()
    }
    
    func didTapOnlineServicesLink() {
        _didTapOnlineServicesLink()
    }
}

struct PositiveTestResultInteractor: PositiveTestResultViewControllerInteracting {
    
    private var _didTapContinue: () -> Void
    private var _didTapOnlineServicesLink: () -> Void
    
    init(didTapContinue: @escaping () -> Void, didTapOnlineServicesLink: @escaping () -> Void) {
        _didTapContinue = didTapContinue
        _didTapOnlineServicesLink = didTapOnlineServicesLink
    }
    
    func didTapContinue() {
        _didTapContinue()
    }
    
    func didTapOnlineServicesLink() {
        _didTapOnlineServicesLink()
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
