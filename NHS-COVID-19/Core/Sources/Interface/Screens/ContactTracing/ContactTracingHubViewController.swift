//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Localization
import SwiftUI

class ExposureNotificationState {
    private let _action: (Bool) -> Void
    private let _enabledSubject: CurrentValueSubject<Bool, Never>
    
    var enabled: Bool {
        get {
            _enabledSubject.value
        }
        set {
            _enabledSubject.send(newValue)
            _action(newValue)
        }
    }
    
    var enabledSubject: CurrentValueSubject<Bool, Never> {
        _enabledSubject
    }
    
    init(enabled: InterfaceProperty<Bool>, action: @escaping (Bool) -> Void) {
        _action = action
        _enabledSubject = enabled.currentValueSubject
    }
}

private extension InterfaceProperty {
    var currentValueSubject: CurrentValueSubject<Value, Never> {
        let currentValueSubject: CurrentValueSubject<Value, Never> = {
            let subject = CurrentValueSubject<Value, Never>(wrappedValue)
            sink { subject.send($0) }
            return subject
        }()
        return currentValueSubject
    }
}

private class ContactTracingState: ObservableObject {
    private var cancellable: AnyCancellable?
    let exposureNotifications: ExposureNotificationState
    private let userNotificationsEnabled: InterfaceProperty<Bool>
    
    @Published var isPresented: Bool = false
    @Published var toggleState: Bool = false
    @Published var exposureNotificationReminderIn: ExposureNotificationReminderIn? = nil
    @Published var showExposureNotificationReminderAlert: Bool = false
    
    // use a custom binding so that we can observe the state of the toggle
    var toggleBinding: Binding<Bool> {
        Binding {
            self.toggleState
        } set: { newValue in
            self.toggleState = newValue
            if newValue {
                self.exposureNotifications.enabled = true
            } else {
                if self.userNotificationsEnabled.wrappedValue {
                    self.isPresented = true // present a sheet with the reminder options
                } else {
                    self.exposureNotifications.enabled = false // can't remind the user so just switch off exposure notifications
                }
            }
        }
    }
    
    init(exposureNotifications: ExposureNotificationState, userNotificationsEnabled: InterfaceProperty<Bool>) {
        
        self.exposureNotifications = exposureNotifications
        self.userNotificationsEnabled = userNotificationsEnabled
        
        // update the toggle state based on whether exposure notifications are enabled by the user
        cancellable = exposureNotifications.enabledSubject
            .sink { [weak self] exposureNotificationsEnabled in
                self?.toggleState = exposureNotificationsEnabled
            }
    }
}

private struct ContactTracingHubContentView: View {
    @ObservedObject private var contactTracingState: ContactTracingState
    private let interactor: ContactTracingHubViewController.Interacting
    
    init(contactTracingState: ContactTracingState, interactor: ContactTracingHubViewController.Interacting) {
        self.contactTracingState = contactTracingState
        self.interactor = interactor
    }
    
    private var toggleTitle: String {
        contactTracingState.toggleBinding.wrappedValue ?
            localize(.contact_tracing_toggle_title_on) :
            localize(.contact_tracing_toggle_title_off)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            ToggleButton(
                isToggledOn: contactTracingState.toggleBinding,
                text: toggleTitle
            )
            .padding(.bottom)
            
            Group {
                IconItemView(
                    icon: .contactTracingNoTracking,
                    title: localize(.contact_tracing_hub_no_tracking_heading),
                    description: localize(.contact_tracing_hub_no_tracking_description)
                )
                IconItemView(
                    icon: .contactTracingPrivacy,
                    title: localize(.contact_tracing_hub_privacy_heading),
                    description: localize(.contact_tracing_hub_privacy_description)
                )
                IconItemView(
                    icon: .contactTracingBatteryLife,
                    title: localize(.contact_tracing_hub_battery_heading),
                    description: localize(.contact_tracing_hub_battery_description)
                )
            }
            .padding([.leading, .trailing], .halfSpacing)
            .layoutPriority(1)
            
            Spacer(minLength: .tripleSpacing)
            
            Group {
                Text(localize(.contact_tracing_hub_find_out_more))
                    .styleAsSecondaryHeading()
                
                VStack(alignment: .center, spacing: 2) {
                    ListRow(
                        text: localize(.contact_tracing_hub_should_not_pause),
                        tapAction: interactor.didTapAdviceWhenDoNotPauseCTButton
                    )
                }
                .padding([.leading, .trailing], -(.halfSpacing + 16))
            }
            .padding([.leading, .trailing], .halfSpacing)
            .layoutPriority(1)
        }
        .environment(\.locale, Locale(identifier: currentLocaleIdentifier()))
    }
}

private struct IconItemView: View {
    let icon: ImageName
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: .standardSpacing) {
            Image(icon)
                .frame(width: .bulletPointSize, height: .bulletPointSize, alignment: .center)
                .foregroundColor(Color(.secondaryText))
                .accessibility(hidden: true)
            VStack(alignment: .leading) {
                Text(title)
                    .styleAsHeading()
                Text(description)
                    .styleAsSecondaryBody()
            }
        }
    }
}

private struct ListRow: View {
    let text: String
    let tapAction: () -> Void
    
    var body: some View {
        Button(action: tapAction) {
            HStack(spacing: .halfSpacing) {
                Text(text)
                    .styleAsBody()
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(.menuChevron)
                    .foregroundColor(Color(.secondaryText))
            }
            .contentShape(Rectangle())
            .padding(24)
        }
        .background(Color(.surface))
    }
}

private struct ContactTracingHubView: View {
    private let interactor: ContactTracingHubViewController.Interacting
    @ObservedObject private var contactTracingState: ContactTracingState
    
    init(
        interactor: ContactTracingHubViewController.Interacting,
        contactTracingState: ContactTracingState
    ) {
        self.interactor = interactor
        self.contactTracingState = contactTracingState
    }
    
    var body: some View {
        ScrollView(.vertical) {
            ContactTracingHubContentView(contactTracingState: contactTracingState, interactor: interactor)
                .padding()
        }
        .background(Color(.background))
        .edgesIgnoringSafeArea(.bottom)
        .actionSheet(isPresented: $contactTracingState.isPresented) {
            ActionSheet(
                title: Text(.exposure_notification_reminder_sheet_title),
                message: Text(.exposure_notification_reminder_sheet_description),
                buttons: ExposureNotificationReminderIn.allCases.map { reminderIn in
                    ActionSheet.Button.default(Text(.exposure_notification_reminder_sheet_hours(hours: reminderIn.rawValue))) {
                        self.contactTracingState.exposureNotifications.enabled = false // only now actually switch off exposure notifications
                        self.contactTracingState.exposureNotificationReminderIn = reminderIn
                        self.contactTracingState.showExposureNotificationReminderAlert = true
                        self.interactor.scheduleReminderNotification(reminderIn: reminderIn)
                    }
                } + [ActionSheet.Button.cancel(Text(.exposure_notification_reminder_sheet_cancel), action: {
                    self.contactTracingState.toggleState = true // flip the toggle back on as we didn't actually change the underlying state
                })]
            )
        }
        .alert(isPresented: $contactTracingState.showExposureNotificationReminderAlert) { () -> Alert in
            Alert(
                title: Text(.exposure_notification_reminder_alert_title(hours: contactTracingState.exposureNotificationReminderIn!.rawValue)),
                message: Text(.exposure_notification_reminder_alert_description),
                dismissButton: .default(Text(.exposure_notification_reminder_alert_button))
            )
        }
    }
}

public protocol ContactTracingHubViewControllerInteracting {
    func scheduleReminderNotification(reminderIn: ExposureNotificationReminderIn)
    func didTapAdviceWhenDoNotPauseCTButton()
}

public class ContactTracingHubViewController: RootViewController {
    
    public typealias Interacting = ContactTracingHubViewControllerInteracting
    
    private let contactTracingState: ContactTracingState
    
    public init(
        _ interactor: Interacting,
        exposureNotificationsEnabled: InterfaceProperty<Bool>,
        exposureNotificationsToggleAction: @escaping (Bool) -> Void,
        userNotificationsEnabled: InterfaceProperty<Bool>
    ) {
        contactTracingState = ContactTracingState(
            exposureNotifications: ExposureNotificationState(
                enabled: exposureNotificationsEnabled,
                action: exposureNotificationsToggleAction
            ),
            userNotificationsEnabled: userNotificationsEnabled
        )
        
        super.init(nibName: nil, bundle: nil)
        
        title = localize(.contact_tracing_hub_title)
        
        let content = UIHostingController(rootView:
            ContactTracingHubView(
                interactor: interactor,
                contactTracingState: contactTracingState
            )
        )
        addFilling(content)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
