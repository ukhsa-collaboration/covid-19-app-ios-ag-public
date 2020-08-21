//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Localization
import UIKit

public class PilotActivationViewController: OnboardingStepViewController {
    
    public init(submit: @escaping (String) -> AnyPublisher<Void, Error>) {
        super.init(step: PilotActivationStep(submit: submit))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private class PilotActivationStep: NSObject, OnboardingStep {
    var footerContent = [UIView]()
    
    private var cancellable: AnyCancellable?
    private let submit: (String) -> AnyPublisher<Void, Error>
    
    let actionTitle = localize(.authentication_code_button_title)
    let image: UIImage? = nil
    
    init(submit: @escaping (String) -> AnyPublisher<Void, Error>) {
        self.submit = submit
    }
    
    private let title = UILabel().styleAsPageHeader().set(text: localize(.authentication_code_title))
    
    private lazy var headerContent: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [title])
        localize(.authentication_code_description).components(separatedBy: "\n").forEach {
            stackView.addArrangedSubview(UILabel().styleAsBody().set(text: $0))
        }
        stackView.axis = .vertical
        stackView.spacing = .standardSpacing
        stackView.layoutMargins = .inner
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private lazy var textfieldHeading: UILabel = {
        let label = UILabel()
        label.text = localize(.authentication_code_textfield_heading)
        label.styleAsTertiaryTitle()
        return label
    }()
    
    private lazy var textfieldExampleLabel: UILabel = {
        let label = UILabel()
        label.text = localize(.authentication_code_textfield_example)
        label.styleAsSecondaryBody()
        return label
    }()
    
    private lazy var errorDescription: UILabel = {
        let label = UILabel()
        label.text = localize(.authentication_code_error_description)
        label.styleAsError()
        label.isHidden = true
        return label
    }()
    
    private lazy var authenticationCodeTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.layer.borderWidth = 2
        textField.accessibilityLabel = localize(.authentication_code_textfield_label)
        textField.layer.borderColor = UIColor(.secondaryText).cgColor
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        textField.textContentType = .oneTimeCode
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .continue
        textField.enablesReturnKeyAutomatically = true
        textField.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
        textField.rightView = spinner
        NSLayoutConstraint.activate([textField.heightAnchor.constraint(greaterThanOrEqualToConstant: .hitAreaMinHeight)])
        return textField
    }()
    
    @objc private func valueChanged() {
        if let textFieldContent = authenticationCodeTextField.text {
            let formattedActivationCode = PilotActivationCodeFormatter.format(textFieldContent)
            authenticationCodeTextField.text = formattedActivationCode
            if textFieldContent.count != formattedActivationCode.count {
                DispatchQueue.main.async {
                    let endPosition = self.authenticationCodeTextField.endOfDocument
                    self.authenticationCodeTextField.selectedTextRange = self.authenticationCodeTextField.textRange(from: endPosition, to: endPosition)
                }
            }
        }
    }
    
    private let informationBox = InformationBox.information(
        .title(localize(.authentication_code_info_heading)),
        .body(localize(.authentication_code_info_description_1)),
        .heading(localize(.authentication_code_info_example)),
        .body(localize(.authentication_code_info_description_2))
    )
    
    private lazy var textfieldInformationBox = InformationBox.error(
        textfieldHeading,
        textfieldExampleLabel,
        errorDescription,
        authenticationCodeTextField
    )
    
    private lazy var spinner: UIView = {
        let container = UIView()
        let spinner = UIActivityIndicatorView()
        spinner.startAnimating()
        container.addAutolayoutSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.topAnchor.constraint(equalTo: container.topAnchor),
            spinner.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            spinner.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            spinner.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -.standardSpacing),
        ])
        return container
    }()
    
    var content: [UIView] {
        [
            headerContent,
            textfieldInformationBox,
            informationBox,
        ]
    }
    
    func act() {
        CATransaction.disableActions {
            authenticationCodeTextField.rightViewMode = .always
        }
        
        authenticationCodeTextField.resignFirstResponder()
        if let textFieldContent = authenticationCodeTextField.text {
            let code = textFieldContent.replacingOccurrences(of: "-", with: "")
            cancellable = submit(code).sink(receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.showError()
                }
            }, receiveValue: {})
        }
    }
    
    func showError() {
        errorDescription.isHidden = false
        authenticationCodeTextField.layer.borderColor = UIColor(.errorRed).cgColor
        textfieldInformationBox.error()
        UIAccessibility.post(notification: .layoutChanged, argument: errorDescription)
        
        CATransaction.disableActions {
            authenticationCodeTextField.rightViewMode = .never
        }
    }
    
}

extension PilotActivationStep: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        act()
        return false
    }
}

public struct PilotActivationCodeFormatter {
    public static func format(_ code: String) -> String {
        let allowedChars = CharacterSet.alphanumerics
        var formattedCode = code
            .lowercased()
            .components(separatedBy: allowedChars.inverted)
            .joined()
        if formattedCode.count > 4 {
            formattedCode.insert("-", at: formattedCode.index(formattedCode.startIndex, offsetBy: 4))
        }
        return String(formattedCode.prefix(9))
    }
}
