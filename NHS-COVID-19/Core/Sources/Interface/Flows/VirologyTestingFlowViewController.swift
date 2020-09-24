//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation
import Localization
import UIKit

public protocol VirologyTestingFlowViewControllerInteracting {
    func fetchVirologyTestingInfo() -> AnyPublisher<InterfaceVirologyTestingInfo, NetworkRequestError>
    
    func didTapCopyReferenceCode()
    func didTapOrderTestLink()
    
    var acknowledge: (() -> Void)? { get }
}

public class VirologyTestingFlowViewController: UINavigationController {
    
    public typealias Interacting = VirologyTestingFlowViewControllerInteracting
    
    private let interactor: Interacting
    
    private enum State: Equatable {
        case start
        case failedToLoad
    }
    
    @Published
    private var state: State = .start
    
    private var referenceCode = ""
    
    private var cancellables = [AnyCancellable]()
    
    public init(_ interactor: Interacting) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
        
        monitorState()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func monitorState() {
        $state
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                self?.update(for: state)
            }
            .store(in: &cancellables)
    }
    
    private func update(for state: State) {
        viewControllers = [
            rootViewController(for: state),
        ]
    }
    
    private func rootViewController(for state: State) -> UIViewController {
        switch state {
        case .start:
            executeFetchVirologyTestingInfo()
            return LoadingViewController(
                interactor: LoadingInteractor(
                    _didTapCancel: { [weak self] in
                        guard let self = self else { return }
                        self.interactor.acknowledge?()
                        self.dismiss(animated: true, completion: nil)
                    }
                ),
                title: localize(.virology_testing_information_title)
            )
        case .failedToLoad:
            return LoadingErrorViewController(
                interacting: LoadingErrorInteractor(
                    _didTapCancel: { [weak self] in
                        guard let self = self else { return }
                        self.interactor.acknowledge?()
                        self.dismiss(animated: true, completion: nil)
                    },
                    _didTapRetry: {
                        [weak self] in
                        self?.executeFetchVirologyTestingInfo()
                    }
                ),
                title: localize(.virology_testing_information_title)
            )
        }
    }
    
    func executeFetchVirologyTestingInfo() {
        state = .start
        
        interactor.fetchVirologyTestingInfo()
            .sink(
                receiveCompletion: { [weak self] completion in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        switch completion {
                        case .finished:
                            self.interactor.acknowledge?()
                            self.interactor.didTapOrderTestLink()
                            self.dismiss(animated: false)
                        case .failure:
                            self.state = .failedToLoad
                        }
                    }
                },
                receiveValue: { [weak self] virologyTestingInfo in
                    DispatchQueue.main.async {
                        self?.referenceCode = virologyTestingInfo.referenceCode
                    }
                }
            )
            .store(in: &cancellables)
    }
}

struct LoadingInteractor: LoadingViewController.Interacting {
    var _didTapCancel: () -> Void
    
    public func didTapCancel() {
        _didTapCancel()
    }
}

struct LoadingErrorInteractor: LoadingErrorViewController.Interacting {
    var _didTapCancel: () -> Void
    var _didTapRetry: () -> Void
    
    public func didTapCancel() {
        
        _didTapCancel()
    }
    
    public func didTapRetry() {
        _didTapRetry()
    }
}
