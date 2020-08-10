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
    
    private lazy var title: UILabel = {
        let label = UILabel()
        label.text = localize(.authentication_code_title)
        label.styleAsPageHeader()
        return label
    }()
    
    private lazy var description1: UILabel = {
        let label = UILabel()
        label.text = localize(.authentication_code_description_1)
        label.styleAsBody()
        return label
    }()
    
    private lazy var description2: UILabel = {
        let label = UILabel()
        label.text = localize(.authentication_code_description_2)
        label.styleAsBody()
        return label
    }()
    
    private lazy var headerContent: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            title,
            description1,
            description2,
        ])
        stackView.axis = .vertical
        stackView.spacing = .standardSpacing
        stackView.layoutMargins = .inner
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private lazy var textfieldHeading: UILabel = {
        let label = UILabel()
        label.text = localize(.authentication_code_textfield_heading)
        label.styleAsHeading()
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
    
    private lazy var informationBox: InformationBox = {
        let title = UILabel()
        title.styleAsHeading()
        title.text = localize(.authentication_code_info_heading)
        
        let description1 = UILabel()
        description1.styleAsBody()
        description1.text = localize(.authentication_code_info_description_1)
        
        let example = UILabel()
        example.styleAsHeading()
        example.text = localize(.authentication_code_info_example)
        
        let description2 = UILabel()
        description2.styleAsBody()
        description2.text = localize(.authentication_code_info_description_2)
        
        return InformationBox(views: [title, description1, example, description2], style: .information, backgroundColor: .clear)
    }()
    
    private lazy var textfieldInformationBox: InformationBox = {
        InformationBox(views: [
            textfieldHeading,
            textfieldExampleLabel,
            errorDescription,
            authenticationCodeTextField,
        ], style: .noNews, backgroundColor: .clear)
    }()
    
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
        textfieldInformationBox.style = .badNews
        
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
