//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
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
                _enabled = newValue
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

private class ActionSheetState: ObservableObject {
    private var cancellable: AnyCancellable?
    private var previousExposureNotificationEnabled: Bool?
    
    @Published
    var isPresented: Bool = false
    
    init(exposureNotificationsEnabled: InterfaceProperty<Bool>, userNotificationsEnabled: InterfaceProperty<Bool>) {
        cancellable = exposureNotificationsEnabled.$wrappedValue
            .combineLatest(userNotificationsEnabled.$wrappedValue)
            .sink { [weak self] exposureNotificationsEnabled, authorized in
                guard let self = self else { return }
                let toggledOff = !exposureNotificationsEnabled && self.previousExposureNotificationEnabled == true
                self.isPresented = authorized && toggledOff
                self.previousExposureNotificationEnabled = exposureNotificationsEnabled
            }
    }
}

struct HomeView: View {
    @ObservedObject private var showOrderTestButton: InterfaceProperty<Bool>
    private let interactor: HomeViewController.Interacting
    @ObservedObject
    private var riskLevelBannerViewModel: InterfaceProperty<RiskLevelBanner.ViewModel?>
    private let isolationViewModel: RiskLevelIndicator.ViewModel
    @ObservedObject private var shouldShowSelfDiagnosis: InterfaceProperty<Bool>
    @ObservedObject private var exposureNotifications: ExposureNotificationState
    @ObservedObject private var actionSheetState: ActionSheetState
    @State private var exposureNotificationReminderIn: ExposureNotificationReminderIn? = nil
    @State private var showExposureNotificationReminderAlert: Bool = false
    private let country: InterfaceProperty<Country>
    
    init(
        interactor: HomeViewController.Interacting,
        riskLevelBannerViewModel: InterfaceProperty<RiskLevelBanner.ViewModel?>,
        isolationViewModel: RiskLevelIndicator.ViewModel,
        showOrderTestButton: InterfaceProperty<Bool>,
        shouldShowSelfDiagnosis: InterfaceProperty<Bool>,
        exposureNotificationsEnabled: InterfaceProperty<Bool>,
        exposureNotificationsToggleAction: @escaping (Bool) -> Void,
        userNotificationsEnabled: InterfaceProperty<Bool>,
        country: InterfaceProperty<Country>
    ) {
        self.interactor = interactor
        self.riskLevelBannerViewModel = riskLevelBannerViewModel
        self.isolationViewModel = isolationViewModel
        self.showOrderTestButton = showOrderTestButton
        self.shouldShowSelfDiagnosis = shouldShowSelfDiagnosis
        self.country = country
        
        exposureNotifications = ExposureNotificationState(
            enabled: exposureNotificationsEnabled,
            action: exposureNotificationsToggleAction
        )
        
        actionSheetState = ActionSheetState(
            exposureNotificationsEnabled: exposureNotificationsEnabled,
            userNotificationsEnabled: userNotificationsEnabled
        )
    }
    
    var riskLevelbanner: some View {
        guard let riskViewModel = riskLevelBannerViewModel.wrappedValue else { return AnyView(EmptyView()) }
        return AnyView(RiskLevelBanner(viewModel: riskViewModel, tapAction: interactor.didTapRiskLevelBanner(viewModel:)))
    }
    
    var body: some View {
        return ScrollView {
            VStack(spacing: .standardSpacing) {
                Strapline(country: self.country)
                
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
                        NavigationButton(imageName: .read, iconName: .externalLink, foregroundColor: Color(.background), backgroundColor: Color(.stylePink), text: localize(.home_default_advice_button_title), action: interactor.didTapAdviceButton).linkify(.home_default_advice_button_title)
                    } else {
                        NavigationButton(imageName: .read, iconName: .externalLink, foregroundColor: Color(.background), backgroundColor: Color(.stylePink), text: localize(.home_isolation_advice_button_title), action: interactor.didTapIsolationAdviceButton).linkify(.home_isolation_advice_button_title)
                    }
                    
                    NavigationButton(imageName: .info, foregroundColor: Color(.background), backgroundColor: Color(.styleTurquoise), text: localize(.home_about_the_app_button_title), action: interactor.didTapAboutButton)
                    
                    NavigationButton(imageName: .chain, foregroundColor: Color(.background), backgroundColor: Color(.nhsLightBlue), text: localize(.home_link_test_result_button_title), action: interactor.didTapLinkTestResultButton)
                    
                    ToggleButton(isToggledOn: $exposureNotifications.enabled, imageName: .bluetooth, text: localize(.home_toggle_exposure_notification_title))
                }
                .accessibilityElement(children: .contain)
                
                Spacer().frame(height: .standardSpacing)
                
            }
            .padding(.standardSpacing)
            .actionSheet(isPresented: $actionSheetState.isPresented) {
                ActionSheet(
                    title: Text(.exposure_notification_reminder_sheet_title),
                    message: Text(.exposure_notification_reminder_sheet_description),
                    buttons: ExposureNotificationReminderIn.allCases.map { reminderIn in
                        ActionSheet.Button.default(Text(.exposure_notification_reminder_sheet_hours(hours: reminderIn.rawValue))) {
                            self.exposureNotificationReminderIn = reminderIn
                            self.showExposureNotificationReminderAlert = true
                        }
                    } + [ActionSheet.Button.cancel(Text(.exposure_notification_reminder_sheet_cancel))]
                )
            }.alert(isPresented: $showExposureNotificationReminderAlert) { () -> Alert in
                Alert(
                    title: Text(.exposure_notification_reminder_alert_title(hours: self.exposureNotificationReminderIn!.rawValue)),
                    message: Text(.exposure_notification_reminder_alert_description),
                    dismissButton: .default(Text(.exposure_notification_reminder_alert_button)) {
                        self.interactor.scheduleReminderNotification(reminderIn: self.exposureNotificationReminderIn!)
                    }
                )
            }
            
        }
    }
}
