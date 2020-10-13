//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Localization
import SwiftUI

public protocol HomeViewControllerInteracting {
    func didTapRiskLevelBanner(viewModel: RiskLevelInfoViewController.ViewModel)
    func didTapDiagnosisButton()
    func didTapAdviceButton()
    func didTapIsolationAdviceButton()
    func didTapCheckInButton()
    func didTapTestingInformationButton()
    func didTapAboutButton()
    func didTapLinkTestResultButton()
    func setExposureNotifcationEnabled(_ enabled: Bool) -> AnyPublisher<Void, Never>
    func scheduleReminderNotification(reminderIn: ExposureNotificationReminderIn)
    var shouldShowCheckIn: Bool { get }
}

public class HomeViewController: UIViewController {
    
    public typealias Interacting = HomeViewControllerInteracting
    
    private var cancellables = [AnyCancellable]()
    private let interactor: Interacting
    private let riskLevelBannerViewModel: InterfaceProperty<RiskLevelBanner.ViewModel?>
    private let isolationViewModel: RiskLevelIndicator.ViewModel
    
    // Allows the UI to update immediately until a genuine value has been published by the model
    private let optimisiticExposureNotificationsEnabled = CurrentValueSubject<Bool?, Never>(nil)
    private let exposureNotificationsEnabled: InterfaceProperty<Bool>
    private let userNotificationsEnabled: InterfaceProperty<Bool>
    
    private let showOrderTestButton: InterfaceProperty<Bool>
    private let shouldShowSelfDiagnosis: InterfaceProperty<Bool>
    
    private let country: InterfaceProperty<Country>
    
    public init(
        interactor: Interacting,
        riskLevelBannerViewModel: InterfaceProperty<RiskLevelBanner.ViewModel?>,
        isolationViewModel: RiskLevelIndicator.ViewModel,
        exposureNotificationsEnabled: AnyPublisher<Bool, Never>,
        showOrderTestButton: InterfaceProperty<Bool>,
        shouldShowSelfDiagnosis: InterfaceProperty<Bool>,
        userNotificationsEnabled: InterfaceProperty<Bool>,
        country: InterfaceProperty<Country>
    ) {
        self.interactor = interactor
        self.riskLevelBannerViewModel = riskLevelBannerViewModel
        self.isolationViewModel = isolationViewModel
        
        self.exposureNotificationsEnabled = optimisiticExposureNotificationsEnabled
            .combineLatest(exposureNotificationsEnabled) { $0 ?? $1 }
            .removeDuplicates()
            .property(initialValue: false)
        
        self.userNotificationsEnabled = userNotificationsEnabled
        
        self.showOrderTestButton = showOrderTestButton
        self.shouldShowSelfDiagnosis = shouldShowSelfDiagnosis
        
        self.country = country
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.styleAsScreenBackground(with: traitCollection)
        
        let homeView = HomeView(
            interactor: interactor,
            riskLevelBannerViewModel: riskLevelBannerViewModel,
            isolationViewModel: isolationViewModel,
            showOrderTestButton: showOrderTestButton,
            shouldShowSelfDiagnosis: shouldShowSelfDiagnosis,
            exposureNotificationsEnabled: exposureNotificationsEnabled,
            exposureNotificationsToggleAction: exposureNotificationSwitchValueChanged,
            userNotificationsEnabled: userNotificationsEnabled,
            country: country
        )
        .navigationBarHidden(true)
        
        let controller = UIHostingController(rootView: homeView)
        controller.view.backgroundColor = UIColor(.background)
        
        if #available(iOS 14.0, *) {
            addChild(controller)
            view.addAutolayoutSubview(controller.view)
            controller.didMove(toParent: self)
        } else {
            view.addAutolayoutSubview(controller.view)
        }
        
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        #warning("Find a long term solution for this.")
        // Something goes wrong with the accessibility frame of elements on this screen after certain flows (for example
        // after submitting keys after a positive test result).
        if #available(iOS 14.0, *) {
            performAccessibilityHackForIOS14()
        } else {
            performAccessibilityHackForOlderOS()
        }
    }
    
    private func performAccessibilityHackForOlderOS() {
        // Scroll a small amount to trigger accessibility frame relayout
        let scrollView: UIScrollView? = view.getFirstSubview()
        scrollView?.setContentOffset(CGPoint(x: 0, y: 1), animated: false)
        scrollView?.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    private var isTryingToFixAccessibility = false
    
    private func performAccessibilityHackForIOS14() {
        // Push and pop a view controller; this solves the problem _somehow_ 🤷‍♀️
        if isTryingToFixAccessibility {
            isTryingToFixAccessibility = false
        } else {
            isTryingToFixAccessibility = true
            
            let viewController = UIViewController()
            navigationController?.pushViewController(viewController, animated: false)
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: false)
            }
        }
        
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @objc private func aboutTapped() {
        interactor.didTapAboutButton()
    }
    
    private func exposureNotificationSwitchValueChanged(_ isOn: Bool) {
        optimisiticExposureNotificationsEnabled.send(isOn)
        interactor.setExposureNotifcationEnabled(isOn)
            .sink(receiveCompletion: { [weak self] _ in
                // Reset ready for next time
                self?.optimisiticExposureNotificationsEnabled.send(nil)
            }, receiveValue: {})
            .store(in: &cancellables)
    }
}
