//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Localization
import SwiftUI
import UIKit

private class ExposureNotificationState: ObservableObject {
    private let action: (Bool) -> Void
    
    @Published
    private var _enabled: Bool
    
    var enabled: Bool {
        get {
            _enabled
        }
        set {
            if newValue != _enabled {
                action(newValue)
            }
        }
    }
    
    init(enabled: InterfaceProperty<Bool>, action: @escaping (Bool) -> Void) {
        self.action = action
        _enabled = enabled.wrappedValue
        
        enabled.sink { [weak self] value in
            self?._enabled = value
        }
    }
}

struct HomeView: View {
    @ObservedObject private var showOrderTestButton: InterfaceProperty<Bool>
    private let interactor: HomeViewController.Interacting
    private let riskViewModel: RiskLevelBanner.ViewModel?
    private let isolationViewModel: RiskLevelIndicator.ViewModel
    @ObservedObject private var shouldShowSelfDiagnosis: InterfaceProperty<Bool>
    @ObservedObject private var exposureNotifications: ExposureNotificationState
    
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
        
        exposureNotifications = ExposureNotificationState(
            enabled: exposureNotificationsEnabled,
            action: exposureNotificationsToggleAction
        )
    }
    
    var riskLevelbanner: some View {
        guard let riskViewModel = riskViewModel else { return AnyView(EmptyView()) }
        return AnyView(RiskLevelBanner(viewModel: riskViewModel, moreInfo: interactor.didTapMoreInfo))
    }
    
    var body: some View {
        return ScrollView {
            VStack(spacing: .standardSpacing) {
                Strapline().frame(width: 80, height: 40)
                
                VStack(spacing: .halfSpacing) {
                    riskLevelbanner
                        .accessibility(sortPriority: 1)
                    
                    RiskLevelIndicator(viewModel: isolationViewModel)
                        .zIndex(-1)
                    
                    if showOrderTestButton.wrappedValue {
                        NavigationButton(imageName: .swab, foregroundColor: Color(.background), backgroundColor: Color(.styleOrange), text: localize(.home_testing_information_button_title), action: interactor.didTapTestingInformationButton)
                    }
                    
                    if interactor.shouldShowCheckIn {
                        NavigationButton(imageName: .qrCode, foregroundColor: Color(.background), backgroundColor: Color(.stylePurple), text: localize(.home_checkin_button_title), action: interactor.didTapCheckInButton)
                    }
                    
                    if shouldShowSelfDiagnosis.wrappedValue {
                        NavigationButton(imageName: .thermometer, foregroundColor: Color(.background), backgroundColor: Color(.styleOrange), text: localize(.home_diagnosis_button_title), action: interactor.didTapDiagnosisButton)
                    }
                    
                    if isolationViewModel.isolationState == .notIsolating {
                        NavigationButton(imageName: .read, foregroundColor: Color(.background), backgroundColor: Color(.stylePink), text: localize(.home_default_advice_button_title), action: interactor.didTapAdviceButton).linkify(.home_default_advice_button_title)
                    } else {
                        NavigationButton(imageName: .read, foregroundColor: Color(.background), backgroundColor: Color(.stylePink), text: localize(.home_isolation_advice_button_title), action: interactor.didTapIsolationAdviceButton).linkify(.home_isolation_advice_button_title)
                    }
                    
                    NavigationButton(imageName: .info, foregroundColor: Color(.background), backgroundColor: Color(.styleTurquoise), text: localize(.home_about_the_app_button_title), action: interactor.didTapAboutButton)
                    
                    ToggleButton(isToggledOn: $exposureNotifications.enabled, imageName: .bluetooth, text: localize(.home_toggle_exposure_notification_title))
                }
                .accessibilityElement(children: .contain)
                
                Spacer().frame(height: .standardSpacing)
                
                Text(localize(.home_early_access_label))
                    .foregroundColor(Color(.secondaryText))
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                
            }
            .padding(.standardSpacing)
        }
    }
}

struct Strapline: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let logoStrapline = LogoStrapline(.primaryText, style: .home)
        logoStrapline.translatesAutoresizingMaskIntoConstraints = false
        return logoStrapline
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
