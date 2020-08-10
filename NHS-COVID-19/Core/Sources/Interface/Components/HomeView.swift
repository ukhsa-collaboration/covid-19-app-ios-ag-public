//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Localization
import SwiftUI
import UIKit

struct HomeView: View {
    @ObservedObject private var showOrderTestButton: InterfaceProperty<Bool>
    private let interactor: HomeViewController.Interacting
    private let riskViewModel: RiskLevelBanner.ViewModel?
    private let isolationViewModel: RiskLevelIndicator.ViewModel
    @ObservedObject private var shouldShowSelfDiagnosis: InterfaceProperty<Bool>
    @ObservedObject private var exposureNotificationsEnabled: InterfaceProperty<Bool>
    private let exposureNotificationsToggleAction: (Bool) -> Void
    
    init(
        interactor: HomeViewController.Interacting,
        riskViewModel: RiskLevelBanner.ViewModel?,
        isolationViewModel: RiskLevelIndicator.ViewModel,
        showOrderTestButton: InterfaceProperty<Bool>,
        shouldShowSelfDiagnosis: InterfaceProperty<Bool>,
        exposureNotificationsEnabled: InterfaceProperty<Bool>,
        exposureNotificationsToggleAction: @escaping (Bool) -> Void
    ) {
        self.interactor = interactor
        self.riskViewModel = riskViewModel
        self.isolationViewModel = isolationViewModel
        self.showOrderTestButton = showOrderTestButton
        self.shouldShowSelfDiagnosis = shouldShowSelfDiagnosis
        self.exposureNotificationsEnabled = exposureNotificationsEnabled
        self.exposureNotificationsToggleAction = exposureNotificationsToggleAction
    }
    
    var riskLevelbanner: some View {
        guard let riskViewModel = riskViewModel else { return AnyView(EmptyView()) }
        return AnyView(RiskLevelBanner(viewModel: riskViewModel))
    }
    
    var body: some View {
        let toggle = Binding<Bool>(
            get: { self.exposureNotificationsEnabled.wrappedValue },
            set: self.exposureNotificationsToggleAction
        )
        
        return ScrollView {
            VStack(spacing: .doubleSpacing) {
                VStack(spacing: .halfSpacing) {
                    riskLevelbanner
                        .accessibility(sortPriority: 1)
                    
                    RiskLevelIndicator(viewModel: isolationViewModel)
                        .zIndex(-1)
                    
                    if showOrderTestButton.wrappedValue {
                        NavigationButton(imageName: .homeTesting, text: localize(.home_testing_information_button_title), action: interactor.didTapTestingInformationButton)
                    }
                    
                    if interactor.shouldShowCheckIn {
                        NavigationButton(imageName: .homeCheckin, text: localize(.home_checkin_button_title), action: interactor.didTapCheckInButton)
                    }
                    
                    if shouldShowSelfDiagnosis.wrappedValue {
                        NavigationButton(imageName: .homeSymptoms, text: localize(.home_diagnosis_button_title), action: interactor.didTapDiagnosisButton)
                    }
                    
                    if isolationViewModel.isolationState == .notIsolating {
                        NavigationButton(imageName: .homeAdvice, text: localize(.home_default_advice_button_title), action: interactor.didTapAdviceButton).linkify(.home_default_advice_button_title)
                    } else {
                        NavigationButton(imageName: .homeAdvice, text: localize(.home_isolation_advice_button_title), action: interactor.didTapIsolationAdviceButton).linkify(.home_isolation_advice_button_title)
                    }
                    
                    NavigationButton(imageName: .homeInfo, text: localize(.home_about_the_app_button_title), action: interactor.didtapContactTracingButton).linkify(.home_about_the_app_button_title)
                    
                    ToggleButton(isToggledOn: toggle, imageName: .homeContactTracing, text: localize(.home_toggle_exposure_notification_title))
                }
                .accessibilityElement(children: .contain)
                
                Text(localize(.home_early_access_label))
                    .foregroundColor(Color(.secondaryText))
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                
            }
            .padding(.standardSpacing)
        }
    }
}
