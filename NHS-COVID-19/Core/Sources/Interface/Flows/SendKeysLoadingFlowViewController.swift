//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import UIKit

public protocol SendKeysLoadingFlowViewControllerInteracting {
    func didTapOnlineServicesLink()
    func didTapExposureFAQLink()
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
        case confirmation
        case loading
        case failed
    }
    
    private var state: State = .started {
        didSet {
            update()
        }
    }
    
    public typealias Confirmation = () -> Void
    public typealias InitialViewControllerFactory = (@escaping Confirmation) -> UIViewController
    
    private let initialViewControllerFactory: InitialViewControllerFactory
    
    public init(interactor: Interacting, initialViewControllerFactory: @escaping InitialViewControllerFactory) {
        self.interactor = interactor
        self.initialViewControllerFactory = initialViewControllerFactory
        super.init(nibName: nil, bundle: nil)
        update()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update() {
        switch state {
        case .started:
            viewControllers = [initialViewControllerFactory { [weak self] in
                self?.state = .confirmation
            }]
        case .confirmation:
            let interactor = ConfirmationInteractor(
                didTapIUnderstand: { [weak self] in
                    self?.state = .loading
                },
                didTapBack: { [weak self] in
                    self?.dismissProgressView()
                    self?.state = .started
                }
            )
            presentedValue = ShareKeysConfirmationViewController(interactor: interactor)
            
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

private struct ConfirmationInteractor: ShareKeysConfirmationViewController.Interacting {
    var didTapIUnderstand: () -> Void
    var didTapBack: () -> Void
}
