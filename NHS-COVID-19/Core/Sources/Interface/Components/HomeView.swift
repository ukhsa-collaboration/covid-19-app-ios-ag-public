//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Localization
import SwiftUI

struct HomeView: View {
    private let interactor: HomeViewController.Interacting
    @ObservedObject private var riskLevelBannerViewModel: InterfaceProperty<RiskLevelBanner.ViewModel?>
    @ObservedObject private var localInfoBannerViewModel: InterfaceProperty<LocalInformationBanner.ViewModel?>
    private let isolationViewModel: RiskLevelIndicator.ViewModel
    @ObservedObject private var shouldShowSelfDiagnosis: InterfaceProperty<Bool>
    private let exposureNotificationState: ExposureNotificationState
    private let country: InterfaceProperty<Country>
    private let shouldShowLocalStats: Bool

    init(
        interactor: HomeViewController.Interacting,
        riskLevelBannerViewModel: InterfaceProperty<RiskLevelBanner.ViewModel?>,
        localInfoBannerViewModel: InterfaceProperty<LocalInformationBanner.ViewModel?>,
        isolationViewModel: RiskLevelIndicator.ViewModel,
        shouldShowSelfDiagnosis: InterfaceProperty<Bool>,
        exposureNotificationsEnabled: InterfaceProperty<Bool>,
        exposureNotificationsToggleAction: @escaping (Bool) -> Void,
        country: InterfaceProperty<Country>,
        shouldShowLocalStats: Bool
    ) {
        self.interactor = interactor
        self.riskLevelBannerViewModel = riskLevelBannerViewModel
        self.localInfoBannerViewModel = localInfoBannerViewModel
        self.isolationViewModel = isolationViewModel
        self.shouldShowSelfDiagnosis = shouldShowSelfDiagnosis
        self.country = country
        self.shouldShowLocalStats = shouldShowLocalStats

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
                        },
                        openSettings: interactor.openSettings
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

    // Two Groups are within the function "buttons" because a view only can have 10 subviews.

    private func buttons() -> some View {
        Group {
            Group {
                if interactor.shouldShowGuidanceHub {
                    NavigationButton(
                        imageName: .read,
                        foregroundColor: Color(.background),
                        backgroundColor: Color(.styleTurquoise),
                        text: localize(.home_covid19_guidance_button_title),
                        action: {
                            switch self.country.wrappedValue {
                            case .england:
                                interactor.didTapGuidanceHubEnglandButton()
                            case .wales:
                                interactor.didTapGuidanceHubWalesButton()
                            }
                        })
                }

                if isolationViewModel.isolationState != .notIsolating && interactor.shouldShowSelfIsolation {
                    NavigationButton(
                        imageName: .selfIsolation,
                        foregroundColor: Color(.background),
                        backgroundColor: Color(.styleRed),
                        text: localize(.home_self_isolation_button_title),
                        action: interactor.didTapSelfIsolationButton
                    )
                }

                if interactor.shouldShowCheckIn {
                    NavigationButton(
                        imageName: .read,
                        foregroundColor: Color(.background),
                        backgroundColor: Color(.stylePurple),
                        text: localize(.home_checkin_button_title),
                        action: interactor.didTapCheckInButton
                    )
                }
            }
            Group {

                if isolationViewModel.isolationState == .notIsolating && shouldShowLocalStats {
                    statsButton()
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

                if interactor.shouldShowTestingForCOVID19 {
                    NavigationButton(
                        imageName: .swab,
                        foregroundColor: Color(.background),
                        backgroundColor: Color(.bookFreeTest),
                        text: localize(.home_testing_hub_button_title),
                        action: interactor.didTapTestingHubButton
                    )
                }

                NavigationButton(
                    imageName: .enterTestResult,
                    foregroundColor: Color(.background),
                    backgroundColor: Color(.nhsLightBlue),
                    text: localize(.home_link_test_result_button_title),
                    action: interactor.didTapLinkTestResultButton
                )

                if isolationViewModel.isolationState != .notIsolating && shouldShowLocalStats {
                    statsButton()
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

    private func statsButton() -> some View {
        NavigationButton(
            imageName: .statsChart,
            foregroundColor: Color(.background),
            backgroundColor: Color(.styleGold),
            text: localize(.status_option_local_data),
            action: interactor.didTapStatsButton
        )
    }
}
