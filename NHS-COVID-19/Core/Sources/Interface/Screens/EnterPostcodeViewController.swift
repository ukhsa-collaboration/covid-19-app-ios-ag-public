//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public class EnterPostcodeViewController: OnboardingStepViewController {
    
    public init(submit: @escaping (String) -> Result<Void, Error>) {
        super.init(step: EnterPostcodeStep(submit: submit))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private class EnterPostcodeStep: NSObject, OnboardingStep {
    var footerContent = [UIView]()
    
    private let submit: (String) -> Result<Void, Error>
    
    private var showError = false
    
    private lazy var title: UILabel = {
        let label = UILabel()
        label.text = localize(.postcode_entry_step_title)
        label.styleAsPageHeader()
        return label
    }()
    
    let actionTitle = localize(.postcode_entry_continue_button_title)
    let image: UIImage? = UIImage(.onboardingPostcode)
    
    init(submit: @escaping (String) -> Result<Void, Error>) {
        self.submit = submit
    }
    
    private lazy var exampleLabel: UILabel = {
        let label = UILabel()
        label.text = localize(.postcode_entry_example_label)
        label.styleAsSecondaryBody()
        return label
    }()
    
    private lazy var errorDescription: UILabel = {
        let label = UILabel()
        label.text = localize(.postcode_entry_error_description)
        label.styleAsError()
        label.isHidden = true
        return label
    }()
    
    private lazy var postcodeTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.layer.borderWidth = 2
        textField.accessibilityLabel = localize(.postcode_entry_textfield_label)
        textField.layer.borderColor = UIColor(.secondaryText).cgColor
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        textField.textContentType = .postalCode
        textField.autocapitalizationType = .allCharacters
        textField.autocorrectionType = .no
        textField.returnKeyType = .continue
        textField.enablesReturnKeyAutomatically = true
        textField.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
        
        NSLayoutConstraint.activate([textField.heightAnchor.constraint(greaterThanOrEqualToConstant: .hitAreaMinHeight)])
        return textField
    }()
    
    @objc private func valueChanged() {
        if let textFieldContent = postcodeTextField.text {
            let processedPostcode = PostcodeProcessor.process(textFieldContent)
            postcodeTextField.text = processedPostcode
            if textFieldContent.count != processedPostcode.count {
                DispatchQueue.main.async {
                    let endPosition = self.postcodeTextField.endOfDocument
                    self.postcodeTextField.selectedTextRange = self.postcodeTextField.textRange(from: endPosition, to: endPosition)
                }
            }
        }
    }
    
    private let descriptionTitle = UILabel().styleAsTertiaryTitle().set(text: localize(.postcode_entry_information_title))
    private let description1 = UILabel().styleAsBody().set(text: localize(.postcode_entry_information_description_1))
    private let description2 = UILabel().styleAsBody().set(text: localize(.postcode_entry_information_description_2))
    
    var content: [UIView] {
        [
            title,
            exampleLabel,
            errorDescription,
            postcodeTextField,
            descriptionTitle,
            description1,
            description2,
        ]
    }
    
    func act() {
        postcodeTextField.resignFirstResponder()
        if let textFieldContent = postcodeTextField.text {
            switch submit(textFieldContent) {
            case .success:
                break
            case .failure:
                errorDescription.isHidden = false
                postcodeTextField.layer.borderColor = UIColor(.errorRed).cgColor
                UIAccessibility.post(notification: .layoutChanged, argument: errorDescription)
            }
        }
    }
    
}

extension EnterPostcodeStep: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        act()
        return false
    }
}
