//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Localization
import SwiftUI

struct HomeView: View {
    @ObservedObject private var showFinancialSupportButton: InterfaceProperty<Bool>
    private let interactor: HomeViewController.Interacting
    @ObservedObject private var riskLevelBannerViewModel: InterfaceProperty<RiskLevelBanner.ViewModel?>
    @ObservedObject private var localInfoBannerViewModel: InterfaceProperty<LocalInformationBanner.ViewModel?>
    private let isolationViewModel: RiskLevelIndicator.ViewModel
    @ObservedObject private var shouldShowSelfDiagnosis: InterfaceProperty<Bool>
    private let exposureNotificationState: ExposureNotificationState
    private let country: InterfaceProperty<Country>
    
    init(
        interactor: HomeViewController.Interacting,
        riskLevelBannerViewModel: InterfaceProperty<RiskLevelBanner.ViewModel?>,
        localInfoBannerViewModel: InterfaceProperty<LocalInformationBanner.ViewModel?>,
        isolationViewModel: RiskLevelIndicator.ViewModel,
        shouldShowSelfDiagnosis: InterfaceProperty<Bool>,
        exposureNotificationsEnabled: InterfaceProperty<Bool>,
        exposureNotificationsToggleAction: @escaping (Bool) -> Void,
        showFinancialSupportButton: InterfaceProperty<Bool>,
        country: InterfaceProperty<Country>
    ) {
        self.interactor = interactor
        self.riskLevelBannerViewModel = riskLevelBannerViewModel
        self.localInfoBannerViewModel = localInfoBannerViewModel
        self.isolationViewModel = isolationViewModel
        self.shouldShowSelfDiagnosis = shouldShowSelfDiagnosis
        self.country = country
        self.showFinancialSupportButton = showFinancialSupportButton
        
        exposureNotificationState = ExposureNotificationState(
            enabled: exposureNotificationsEnabled,
            action: exposureNotificationsToggleAction
        )
    }
    
    var riskLevelbanner: some View {
        guard let riskViewModel = riskLevelBannerViewModel.wrappedValue else { return AnyView(EmptyView()) }
        return AnyView(RiskLevelBanner(viewModel: riskViewModel, tapAction: interactor.didTapRiskLevelBanner(viewModel:)))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: .standardSpacing) {
                Strapline(country: self.country)
                    .zIndex(1)
                
                VStack(spacing: .halfSpacing) {
                    riskLevelbanner
                        .accessibility(sortPriority: 1)
                    
                    RiskLevelIndicator(
                        viewModel: isolationViewModel,
                        turnContactTracingOnTapAction: {
                            exposureNotificationState.enabled = true
                        }
                    )
                    .zIndex(-1)
                    
                    if let localInfoViewModel = localInfoBannerViewModel.wrappedValue {
                        LocalInformationBanner(
                            viewModel: localInfoViewModel,
                            tapAction: interactor.didTapLocalInfoBanner(viewModel:)
                        )
                        .padding([.leading, .trailing], -.standardSpacing)
                    }
                    
                    buttons()
                }
                .accessibilityElement(children: .contain)
                
                Spacer()
                    .frame(height: .standardSpacing)
            }
            .padding(.standardSpacing)
        }
        .environment(\.locale, Locale(identifier: currentLocaleIdentifier()))
    }
    
    private func buttons() -> some View {
        Group {
            if interactor.shouldShowCheckIn {
                NavigationButton(
                    imageName: .qrCode,
                    foregroundColor: Color(.background),
                    backgroundColor: Color(.stylePurple),
                    text: localize(.home_checkin_button_title),
                    action: interactor.didTapCheckInButton
                )
            }
            
            if shouldShowSelfDiagnosis.wrappedValue {
                NavigationButton(
                    imageName: .thermometer,
                    foregroundColor: Color(.background),
                    backgroundColor: Color(.styleOrange),
                    text: localize(.home_diagnosis_button_title),
                    action: interactor.didTapDiagnosisButton
                )
            }
            
            if isolationViewModel.isolationState != .notIsolating {
                NavigationButton(
                    imageName: .read,
                    iconName: .externalLink,
                    foregroundColor: Color(.background),
                    backgroundColor: Color(.stylePink),
                    text: localize(.home_isolation_advice_button_title),
                    action: interactor.didTapIsolationAdviceButton
                )
                .linkify(.home_isolation_advice_button_title)
            }
            
            NavigationButton(
                imageName: .swab,
                foregroundColor: Color(.background),
                backgroundColor: Color(.bookFreeTest),
                text: localize(.home_testing_hub_button_title),
                action: interactor.didTapTestingHubButton
            )
            
            NavigationButton(
                imageName: .enterTestResult,
                foregroundColor: Color(.background),
                backgroundColor: Color(.nhsLightBlue),
                text: localize(.home_link_test_result_button_title),
                action: interactor.didTapLinkTestResultButton
            )
            
            if showFinancialSupportButton.wrappedValue {
                NavigationButton(
                    imageName: .finance,
                    foregroundColor: Color(.background),
                    backgroundColor: Color(.styleGreen),
                    text: localize(.home_financial_support_button_title),
                    action: interactor.didTapFinancialSupportButton
                )
            }
            
            NavigationButton(
                imageName: .settings,
                foregroundColor: Color(.background),
                backgroundColor: Color(.amber),
                text: localize(.home_settings_button_title),
                action: interactor.didTapSettingsButton
            )
            
            NavigationButton(
                imageName: .info,
                foregroundColor: Color(.background),
                backgroundColor: Color(.styleTurquoise),
                text: localize(.home_about_the_app_button_title),
                action: interactor.didTapAboutButton
            )
            
            NavigationButton(
                imageName: .bluetooth,
                foregroundColor: Color(.background),
                backgroundColor: Color(.contactTracingHubButton),
                text: localize(.home_contact_tracing_hub_button_title),
                action: interactor.didTapContactTracingHubButton
            )
        }
    }
}
