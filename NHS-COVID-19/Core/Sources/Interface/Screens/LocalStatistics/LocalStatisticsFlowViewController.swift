//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation
import Localization
import UIKit

public protocol LocalStatisticsFlowViewControllerInteracting {
    func fetchLocalDailyStats() -> AnyPublisher<InterfaceLocalCovidStatsDaily, Error>
    var openURL: (URL) -> Void { get }
}

public class LocalStatisticsFlowViewController: UIViewController {
    public typealias Interacting = LocalStatisticsFlowViewControllerInteracting
    
    fileprivate let interactor: Interacting
    
    fileprivate enum State: Equatable {
        case loading
        case localCovidStats(InterfaceLocalCovidStatsDaily)
        case failed
    }
    
    @Published
    fileprivate var state: State = .loading
    
    private var cancellables = [AnyCancellable]()
    
    public init(_ interactor: Interacting) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
        monitorState()
        fetchLocalStatsData()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func monitorState() {
        $state
            .regulate(as: .modelChange)
            .removeDuplicates()
            .sink { [weak self] state in
                self?.update(for: state)
            }
            .store(in: &cancellables)
    }
    
    private func update(for state: State) {
        content = rootViewController(for: state)
    }
    
    private var content: UIViewController? {
        didSet {
            oldValue?.remove()
            if let content = content {
                addFilling(content)
                UIAccessibility.post(notification: .screenChanged, argument: nil)
            }
        }
    }
    
    private func rootViewController(for state: State) -> UIViewController {
        switch state {
        case .loading:
            let interactor = LoadingViewControllerInteractor(navigationController: self)
            title = localize(.local_statistics_main_screen_title)
            return LoadingViewController(interactor: interactor, title: "")
        case .localCovidStats(let localCovidStats):
            let interactor = LocalStatisticsControllerInteractor(navigationController: self, openURL: interactor.openURL)
            title = localize(.local_statistics_main_screen_title)
            return LocalStatisticsViewController(interactor: interactor, covidStats: localCovidStats)
        case .failed:
            let interactor = LoadingErrorControllerInteractor(navigationController: self)
            title = localize(.local_statistics_error_loading_title)
            return LoadingErrorViewController(interacting: interactor, title: "")
        }
    }
    
    func fetchLocalStatsData() {
        state = .loading
        interactor.fetchLocalDailyStats()
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                case .failure: self?.state = .failed
                }
            } receiveValue: { [weak self] localStats in
                self?.state = .localCovidStats(localStats)
            }.store(in: &cancellables)
    }
}

private class LoadingViewControllerInteractor: LoadingViewController.Interacting {
    private weak var navigationController: LocalStatisticsFlowViewController?
    
    init(navigationController: LocalStatisticsFlowViewController?) {
        self.navigationController = navigationController
    }
    
    func didTapCancel() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

private struct LoadingErrorControllerInteractor: LoadingErrorViewController.Interacting {
    private weak var navigationController: LocalStatisticsFlowViewController?
    
    init(navigationController: LocalStatisticsFlowViewController?) {
        self.navigationController = navigationController
    }
    
    func didTapCancel() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    public func didTapRetry() {
        navigationController?.fetchLocalStatsData()
    }
}

private struct LocalStatisticsControllerInteractor: LocalStatisticsViewController.Interacting {
    
    var openURL: (URL) -> Void
    
    private weak var navigationController: LocalStatisticsFlowViewController?
    
    init(navigationController: LocalStatisticsFlowViewController, openURL: @escaping (URL) -> Void) {
        self.navigationController = navigationController
        self.openURL = openURL
    }
    
    func didTapdashboardLinkButton() {
        openURL(ExternalLink.localCovidStatsInfo.url)
    }
}
