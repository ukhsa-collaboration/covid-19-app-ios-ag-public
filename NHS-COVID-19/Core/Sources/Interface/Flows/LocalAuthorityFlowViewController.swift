//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation
import Localization
import UIKit

public protocol LocalAuthorityFlowViewControllerInteracting {
    func localAuthorities(for postcode: String) -> Result<[LocalAuthority], DisplayableError>
    func confirmLocalAuthority(_ localAuthority: LocalAuthority?) -> Result<Void, LocalAuthoritySelectionError>
    func didTapGovUKLink()
}

public struct LocalAuthorityFlowViewModel: Equatable {
    enum FlowType: Equatable {
        case single(LocalAuthority)
        case selection([LocalAuthority])
    }
    
    var postcode: String
    var flowType: FlowType
    
    public init(postcode: String, localAuthorities: [LocalAuthority]) {
        self.postcode = postcode
        if localAuthorities.count > 1 {
            flowType = .selection(localAuthorities)
        } else {
            flowType = .single(localAuthorities[0])
        }
    }
}

public class LocalAuthorityFlowViewController: UINavigationController {
    
    public typealias Interacting = LocalAuthorityFlowViewControllerInteracting
    
    fileprivate let interactor: Interacting
    
    private var isEditMode: Bool = false
    private var dismissAction: (() -> Void)?
    
    fileprivate enum State: Equatable {
        case postcode
        case information(LocalAuthorityFlowViewModel)
        case confirmation(LocalAuthorityFlowViewModel, Bool)
        case postcodeEdit
    }
    
    @Published
    fileprivate var state: State
    
    private var cancellables = [AnyCancellable]()
    
    public init(_ interactor: Interacting, viewModel: LocalAuthorityFlowViewModel? = nil, isEditMode: Bool = false) {
        self.isEditMode = isEditMode
        self.interactor = interactor
        if let viewModel = viewModel {
            state = .information(viewModel)
        } else {
            state = isEditMode ? .postcodeEdit : .postcode
        }
        super.init(nibName: nil, bundle: nil)
        _ = self.isEditMode == true ? setupDismissAction() : nil
        monitorState()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func monitorState() {
        $state
            .regulate(as: .modelChange)
            .sink { [weak self] state in
                self?.update(for: state)
            }
            .store(in: &cancellables)
    }
    
    private func setupDismissAction() {
        dismissAction = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func update(for state: State) {
        pushViewController(rootViewController(for: state), animated: state != .postcode && state != .postcodeEdit)
    }
    
    private func handleSubmittedPostcode(_ postcode: String, confirmation: Bool) -> Result<Void, DisplayableError> {
        let result = interactor.localAuthorities(for: postcode)
        switch result {
        case .success(let localAuthorities):
            let viewModel = LocalAuthorityFlowViewModel(postcode: postcode, localAuthorities: localAuthorities)
            state = .confirmation(viewModel, confirmation)
            return Result.success(())
        case .failure(let error):
            return Result.failure(error)
        }
    }
    
    private func rootViewController(for state: State) -> UIViewController {
        switch state {
        case .postcodeEdit:
            let interactor = EditPostcodeInteractor(
                savePostcode: { postcode in
                    self.handleSubmittedPostcode(postcode, confirmation: false)
                },
                didTapCancel: {
                    self.dismiss(animated: true, completion: nil)
                }
            )
            return EditPostcodeViewController(interactor: interactor, isLocalAuthorityEnabled: true)
        case .postcode:
            return EnterPostcodeViewController { postcode in
                self.handleSubmittedPostcode(postcode, confirmation: false)
            }
        case .information(let viewModel):
            return LocalAuthorityInformationViewController {
                self.state = .confirmation(viewModel, true)
            }
        case .confirmation(let viewModel, let hideBackButton):
            switch viewModel.flowType {
            case .single(let localAuthority):
                let interactor = LocalAuthorityConfirmationInteractor(
                    _confirm: self.interactor.confirmLocalAuthority, _dismiss: dismissAction
                )
                
                return LocalAuthorityConfirmationViewController(interactor: interactor, postcode: viewModel.postcode, localAuthority: localAuthority, hideBackButton: hideBackButton)
            case .selection(let localAuthorities):
                let interactor = SelectLocalAuthorityInteractor(
                    openURL: self.interactor.didTapGovUKLink,
                    submit: self.interactor.confirmLocalAuthority,
                    _dismiss: dismissAction
                )
                let selectionViewModel = LocalAuthorityViewModel(postcode: viewModel.postcode, localAuthorities: localAuthorities)
                return SelectLocalAuthorityViewController(interactor: interactor, localAuthorityViewModel: selectionViewModel, hideBackButton: hideBackButton)
            }
        }
        
    }
    
}

private struct LocalAuthorityConfirmationInteractor: LocalAuthorityConfirmationViewController.Interacting {
    var _confirm: (LocalAuthority?) -> Result<Void, LocalAuthoritySelectionError>
    var _dismiss: (() -> Void)?
    
    func confirm(localAuthority: LocalAuthority?) -> Result<Void, LocalAuthoritySelectionError> {
        return _confirm(localAuthority)
    }
    
    func dismiss() {
        _dismiss?()
    }
}

private struct SelectLocalAuthorityInteractor: SelectLocalAuthorityViewController.Interacting {
    
    var openURL: () -> Void
    var submit: (LocalAuthority?) -> Result<Void, LocalAuthoritySelectionError>
    var _dismiss: (() -> Void)?
    
    func didTapSubmitButton(localAuthority: LocalAuthority?) -> Result<Void, LocalAuthoritySelectionError> {
        return submit(localAuthority)
    }
    
    func didTapLink() {
        openURL()
    }
    
    func dismiss() {
        _dismiss?()
    }
}

private struct EditPostcodeInteractor: EditPostcodeViewController.Interacting {
    var savePostcode: (String) -> Result<Void, DisplayableError>
    var didTapCancel: () -> Void
    
}
