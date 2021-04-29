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
    func didTapFinancialSupportButton()
    func didTapSettingsButton()
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
    private let showFinancialSupportButton: InterfaceProperty<Bool>
    
    private let country: InterfaceProperty<Country>
    let showLanguageSelectionScreen: (() -> Void)?
    private var didShowLanguageSelectionScreen = false
    private var removeSnapshot: (() -> Void)?

    public init(
        interactor: Interacting,
        riskLevelBannerViewModel: InterfaceProperty<RiskLevelBanner.ViewModel?>,
        isolationViewModel: RiskLevelIndicator.ViewModel,
        exposureNotificationsEnabled: AnyPublisher<Bool, Never>,
        showOrderTestButton: InterfaceProperty<Bool>,
        shouldShowSelfDiagnosis: InterfaceProperty<Bool>,
        userNotificationsEnabled: InterfaceProperty<Bool>,
        showFinancialSupportButton: InterfaceProperty<Bool>,
        country: InterfaceProperty<Country>,
        showLanguageSelectionScreen: (() -> Void)?
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
        self.showFinancialSupportButton = showFinancialSupportButton
        
        self.country = country
        self.showLanguageSelectionScreen = showLanguageSelectionScreen
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
            showFinancialSupportButton: showFinancialSupportButton,
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
        
        if showLanguageSelectionScreen != nil, let snapshot = LanguageSelectionViewController.snapshotBeforeChangingLanguage {
            view.addFillingSubview(snapshot)
            LanguageSelectionViewController.snapshotBeforeChangingLanguage = nil
            removeSnapshot = snapshot.removeFromSuperview
        }
    }
        
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // This if statement would run if we've just changed the language, and therefore we need to re-render all views
        // with the new language and navigate back to where we were.
        //
        // Conceptually, we want `showLanguageSelectionScreen` to happen *before* we appear. However, that somehow
        // confuses navigation controller, as it would lay out this screen as if there is a nav bar.
        // This results in a jarring jump of the contect when we navigate back to home screen.
        //
        // As a fix for that, we only navigate the language selector after we appeared for the first time.
        // Now, that, in turn causes another problem: You would see the home screen flash for a moment before we can
        // navigate back to language selector.
        //
        // As a fix for _that_, we temporarily add a snapshot of the pre-change language selector to the home screen,
        // so even though UIKit is showing the home screen, it's actually rendering the language selector, and this
        // avoids the flash.
        if let showLanguageSelectionScreen = self.showLanguageSelectionScreen, !didShowLanguageSelectionScreen {
            didShowLanguageSelectionScreen = true
            showLanguageSelectionScreen()
            removeSnapshot?()
            removeSnapshot = nil
        } else {
            #warning("Find a long term solution for this.")
            // Something goes wrong with the accessibility frame of elements on this screen after certain flows (for example
            // after submitting keys after a positive test result).
            if #available(iOS 14.0, *) {
                performAccessibilityHackForIOS14()
            } else {
                performAccessibilityHackForOlderOS()
            }
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
            viewController.view = view.snapshotView(afterScreenUpdates: false)
            navigationController?.pushViewController(viewController, animated: false)
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: false)
            }
        }
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
