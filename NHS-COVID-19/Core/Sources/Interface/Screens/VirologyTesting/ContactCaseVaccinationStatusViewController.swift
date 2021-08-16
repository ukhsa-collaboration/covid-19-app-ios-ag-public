//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Localization
import SwiftUI

public protocol ContactCaseVaccinationStatusViewControllerInteracting {
    func didTapAboutApprovedVaccinesLink()
    func didTapConfirm(isFullyVaccinated: Bool)
}

struct ContactCaseVaccinationStatusContent {
    public typealias Interacting = ContactCaseVaccinationStatusViewControllerInteracting
    var views: [StackViewContentProvider]
    
    private let interactor: Interacting
    private let vaccineThresholdDate: Date
    private var cancellables: Set<AnyCancellable> = []
    
    init(interactor: Interacting, vaccineThresholdDate: Date) {
        self.interactor = interactor
        self.vaccineThresholdDate = vaccineThresholdDate
        
        let hasReceivedAllVaccineDosesSubject = CurrentValueSubject<Bool?, Never>(nil)
        var isLastVaccineDoseTimeValid: Bool?
        
        let allApprovedDosesRadioButtonGroup = RadioButtonGroup(buttonViewModels: [
            RadioButtonGroup.ButtonViewModel(
                title: localize(.contact_case_vaccination_status_all_doses_of_vaccine_yes_option),
                accessibilityText: localize(.contact_case_vaccination_status_all_doses_of_vaccine_yes_option_accessibility_text),
                action: { hasReceivedAllVaccineDosesSubject.value = true }
            ),
            RadioButtonGroup.ButtonViewModel(
                title: localize(.contact_case_vaccination_status_all_doses_of_vaccine_no_option),
                accessibilityText: localize(.contact_case_vaccination_status_all_doses_of_vaccine_no_option_accessibility_text),
                action: { hasReceivedAllVaccineDosesSubject.value = false }
            ),
        ])
        
        let lastDoseDateRadioButtonGroup = RadioButtonGroup(buttonViewModels: [
            RadioButtonGroup.ButtonViewModel(
                title: localize(.contact_case_vaccination_status_last_dose_of_vaccine_yes_option),
                accessibilityText: localize(.contact_case_vaccination_status_last_dose_of_vaccine_yes_option_accessibility_text(date: vaccineThresholdDate)),
                action: { isLastVaccineDoseTimeValid = true }
            ),
            RadioButtonGroup.ButtonViewModel(
                title: localize(.contact_case_vaccination_status_last_dose_of_vaccine_no_option),
                accessibilityText: localize(.contact_case_vaccination_status_last_dose_of_vaccine_no_option_accessibility_text(date: vaccineThresholdDate)),
                action: { isLastVaccineDoseTimeValid = false }
            ),
        ])
        
        let allApprovedDosesRadioButtonGroupVC = UIHostingController(rootView: allApprovedDosesRadioButtonGroup)
        allApprovedDosesRadioButtonGroupVC.view.backgroundColor = .clear
        
        let lastDoseDateRadioButtonGroupVC = UIHostingController(rootView: lastDoseDateRadioButtonGroup)
        lastDoseDateRadioButtonGroupVC.view.backgroundColor = .clear
        
        let lastDoseDateQuestionHeading = BaseLabel()
            .styleAsSecondaryTitle()
            .set(text: localize(.contact_case_vaccination_status_last_dose_of_vaccine_question(date: vaccineThresholdDate)))
        
        hasReceivedAllVaccineDosesSubject
            .sink { hasReceivedAllDoses in
                lastDoseDateRadioButtonGroupVC.view.isHidden = hasReceivedAllDoses != true
                lastDoseDateQuestionHeading.isHidden = hasReceivedAllDoses != true
                
                // reset selection for `lastDoseDateRadioButtonGroup`
                if hasReceivedAllDoses == false {
                    lastDoseDateRadioButtonGroupVC.rootView.state.selectedID = nil
                    isLastVaccineDoseTimeValid = nil
                }
            }
            .store(in: &cancellables)
        
        let emptyError = UIHostingController(
            rootView: ErrorBox(
                localize(.contact_case_vaccination_status_error_title),
                description: localize(.contact_case_vaccination_status_error_description)
            )
        )
        emptyError.view.backgroundColor = .clear
        emptyError.view.isHidden(true)
        
        let stackedViews: [UIView] = [
            UIImageView(.isolationContinue)
                .styleAsDecoration(),
            BaseLabel()
                .styleAsPageHeader()
                .set(text: localize(.contact_case_vaccination_status_heading))
                .centralized(),
            BaseLabel()
                .styleAsBody()
                .set(text: localize(.contact_case_vaccination_status_description)),
            emptyError.view,
            BaseLabel()
                .styleAsSecondaryTitle()
                .set(text: localize(.contact_case_vaccination_status_all_doses_of_vaccine_question)),
            BaseLabel()
                .styleAsBody()
                .set(text: localize(.contact_case_vaccination_status_all_doses_of_vaccine_description)),
            LinkButton(
                title: localize(.contact_case_vaccination_status_aproved_vaccines_link_title),
                action: interactor.didTapAboutApprovedVaccinesLink
            ),
            allApprovedDosesRadioButtonGroupVC.view,
            lastDoseDateQuestionHeading,
            lastDoseDateRadioButtonGroupVC.view,
        ]
        
        let contentStack = UIStackView(arrangedSubviews: stackedViews.flatMap { $0.content })
        contentStack.axis = .vertical
        contentStack.spacing = .standardSpacing
        
        let button = PrimaryButton(
            title: localize(.contact_case_vaccination_status_confirm_button_title),
            action: {
                let showError = {
                    emptyError.view.isHidden(false)
                    UIAccessibility.post(notification: .layoutChanged, argument: emptyError)
                }
                
                let confirmIsFullyVaccinated: (Bool) -> Void = { isFullyVaccinated in
                    interactor.didTapConfirm(isFullyVaccinated: isFullyVaccinated)
                    emptyError.view.isHidden(true)
                }
                
                guard let hasReceivedAllVaccineDoses = hasReceivedAllVaccineDosesSubject.value else {
                    showError()
                    return
                }
                
                if hasReceivedAllVaccineDoses {
                    guard let isLastVaccineDoseTimeValid = isLastVaccineDoseTimeValid else {
                        showError()
                        return
                    }
                    confirmIsFullyVaccinated(isLastVaccineDoseTimeValid)
                } else {
                    confirmIsFullyVaccinated(false)
                }
            }
        )
        
        let stackContent = [contentStack, button]
        let stackView = UIStackView(arrangedSubviews: stackContent)
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = .bigSpacing
        
        views = [stackView]
    }
    
}

public class ContactCaseVaccinationStatusViewController: ScrollingContentViewController {
    public typealias Interacting = ContactCaseVaccinationStatusViewControllerInteracting
    
    private let content: ContactCaseVaccinationStatusContent
    
    public init(interactor: Interacting, vaccineThresholdDate: Date) {
        let content = ContactCaseVaccinationStatusContent(
            interactor: interactor,
            vaccineThresholdDate: vaccineThresholdDate
        )
        self.content = content
        super.init(views: content.views)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = localize(.contact_case_vaccination_status_title)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
