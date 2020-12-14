//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Localization
import UIKit

public class IsolationPaymentFlowViewController: UINavigationController {
    
    fileprivate enum State: Equatable {
        case idle
        case loading
        case failedToLoad
    }
    
    @Published
    fileprivate var state: State
    
    fileprivate let _openURL: (URL) -> Void
    fileprivate let _didTapCheckEligibility: () -> AnyPublisher<URL, NetworkRequestError>
    private var cancellables = [AnyCancellable]()
    
    public init(openURL: @escaping (URL) -> Void, didTapCheckEligibility: @escaping () -> AnyPublisher<URL, NetworkRequestError>) {
        _openURL = openURL
        _didTapCheckEligibility = didTapCheckEligibility
        state = .idle
        super.init(nibName: nil, bundle: nil)
        monitorState()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func rootViewController(for state: State) -> UIViewController {
        switch state {
        case .idle:
            let interactor = FinancialSupportViewControllerInteractor(controller: self)
            return FinancialSupportViewController(interactor: interactor)
        case .loading:
            let interactor = LoadingViewControllerInteractor(navigationController: self)
            return LoadingViewController(interactor: interactor, title: localize(.financial_support_title))
        case .failedToLoad:
            let interactor = LoadingErrorViewControllerInteractor(controller: self)
            return LoadingErrorViewController(interacting: interactor, title: localize(.financial_support_title))
        }
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
        pushViewController(rootViewController(for: state), animated: false)
    }
    
    fileprivate func handleCheckEligibility() {
        state = .loading
        _didTapCheckEligibility()
            .sink(
                receiveCompletion: { [weak self] completion in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        switch completion {
                        case .finished:
                            self.dismiss(animated: false)
                        case .failure:
                            self.state = .failedToLoad
                        }
                    }
                },
                receiveValue: { [weak self] url in
                    DispatchQueue.main.async {
                        self?._openURL(url)
                    }
                }
            )
            .store(in: &cancellables)
    }
}

private struct LoadingErrorViewControllerInteractor: LoadingErrorViewController.Interacting {
    private weak var controller: IsolationPaymentFlowViewController?
    
    init(controller: IsolationPaymentFlowViewController?) {
        self.controller = controller
    }
    
    func didTapCancel() {
        controller?.dismiss(animated: true, completion: nil)
    }
    
    public func didTapRetry() {
        controller?.handleCheckEligibility()
    }
}

private struct LoadingViewControllerInteractor: LoadingViewController.Interacting {
    private weak var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    func didTapCancel() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

private struct FinancialSupportViewControllerInteractor: FinancialSupportViewController.Interacting {
    private weak var controller: IsolationPaymentFlowViewController?
    
    init(controller: IsolationPaymentFlowViewController?) {
        self.controller = controller
    }
    
    public func didTapHelpForEngland() {
        controller?._openURL(ExternalLink.financialSupportEngland.url)
    }
    
    public func didTapHelpForWales() {
        controller?._openURL(ExternalLink.financialSupportWales.url)
    }
    
    public func didTapCheckEligibility() {
        controller?.handleCheckEligibility()
    }
    
    public func didTapViewPrivacyNotice() {
        controller?._openURL(ExternalLink.financialSupportPrivacyNotice.url)
    }
}
