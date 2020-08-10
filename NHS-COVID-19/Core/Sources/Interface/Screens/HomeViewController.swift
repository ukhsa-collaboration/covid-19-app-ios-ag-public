//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Localization
import SwiftUI

public protocol HomeViewControllerInteracting {
    func didTapDiagnosisButton()
    func didTapAdviceButton()
    func didTapIsolationAdviceButton()
    func didTapCheckInButton()
    func didTapTestingInformationButton()
    func didTapAboutButton()
    func didtapContactTracingButton()
    func setExposureNotifcationEnabled(_ enabled: Bool) -> AnyPublisher<Void, Never>
    var shouldShowCheckIn: Bool { get }
}

public class HomeViewController: UIViewController {
    
    public typealias Interacting = HomeViewControllerInteracting
    
    private var cancellables = [AnyCancellable]()
    private let interactor: Interacting
    private let postcodeRiskViewModel: RiskLevelBanner.ViewModel?
    private let isolationViewModel: RiskLevelIndicator.ViewModel
    
    // Allows the UI to update immediately until a genuine value has been published by the model
    private let optimisiticExposureNotificationsEnabled = CurrentValueSubject<Bool?, Never>(nil)
    private let exposureNotificationsEnabled: InterfaceProperty<Bool>
    
    private let showOrderTestButton: InterfaceProperty<Bool>
    private let shouldShowSelfDiagnosis: InterfaceProperty<Bool>
    
    public init(
        interactor: Interacting,
        postcodeRiskViewModel: RiskLevelBanner.ViewModel?,
        isolationViewModel: RiskLevelIndicator.ViewModel,
        exposureNotificationsEnabled: AnyPublisher<Bool, Never>,
        showOrderTestButton: InterfaceProperty<Bool>,
        shouldShowSelfDiagnosis: InterfaceProperty<Bool>
    ) {
        self.interactor = interactor
        self.postcodeRiskViewModel = postcodeRiskViewModel
        self.isolationViewModel = isolationViewModel
        
        self.exposureNotificationsEnabled = optimisiticExposureNotificationsEnabled
            .combineLatest(exposureNotificationsEnabled) { $0 ?? $1 }
            .removeDuplicates()
            .property(initialValue: false)
        
        self.showOrderTestButton = showOrderTestButton
        self.shouldShowSelfDiagnosis = shouldShowSelfDiagnosis
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.styleAsScreenBackground(with: traitCollection)
        
        let logoStrapline = LogoStrapline(.lightSurface, style: .home)
        navigationItem.titleView = logoStrapline
        let aboutButton = UIBarButtonItem(title: localize(.home_about_button_title), style: .plain, target: self, action: #selector(aboutTapped))
        aboutButton.accessibilityLabel = localize(.home_about_button_title_accessibility_label)
        navigationItem.rightBarButtonItem = aboutButton
        
        let homeView = HomeView(
            interactor: interactor,
            riskViewModel: postcodeRiskViewModel,
            isolationViewModel: isolationViewModel,
            showOrderTestButton: showOrderTestButton,
            shouldShowSelfDiagnosis: shouldShowSelfDiagnosis,
            exposureNotificationsEnabled: exposureNotificationsEnabled,
            exposureNotificationsToggleAction: exposureNotificationSwitchValueChanged
        )
        
        let controller = UIHostingController(rootView: homeView)
        
        addChild(controller)
        view.addAutolayoutSubview(controller.view)
        controller.didMove(toParent: self)
        controller.view.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        
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
