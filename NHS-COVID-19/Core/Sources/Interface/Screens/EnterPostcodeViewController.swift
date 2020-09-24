//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public class EnterPostcodeViewController: OnboardingStepViewController {
    
    public init(submit: @escaping (String) -> Result<Void, DisplayableError>) {
        super.init(step: EnterPostcodeStep(submit: submit))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private class EnterPostcodeStep: NSObject, OnboardingStep {
    var footerContent = [UIView]()
    
    private let submit: (String) -> Result<Void, DisplayableError>
    
    private var showError = false
    
    private lazy var title: UILabel = {
        let label = UILabel()
        label.text = localize(.postcode_entry_step_title)
        label.styleAsPageHeader()
        return label
    }()
    
    let actionTitle = localize(.postcode_entry_continue_button_title)
    let image: UIImage? = UIImage(.onboardingPostcode)
    
    init(submit: @escaping (String) -> Result<Void, DisplayableError>) {
        self.submit = submit
    }
    
    private lazy var exampleLabel: UILabel = {
        let label = UILabel()
        label.text = localize(.postcode_entry_example_label)
        label.styleAsSecondaryBody()
        return label
    }()
    
    private lazy var errorTitle: UILabel = {
        let label = UILabel()
        label.text = localize(.postcode_entry_error_title)
        label.styleAsErrorHeading()
        label.isHidden = true
        return label
    }()
    
    private lazy var errorDescription: UILabel = {
        let label = UILabel()
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
    
    func stack(for labels: [UILabel]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: labels)
        stackView.axis = .vertical
        stackView.spacing = .standardSpacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .inner
        return stackView
    }
    
    private lazy var informationBox: InformationBox = InformationBox.error(
        title, exampleLabel, errorTitle, errorDescription, postcodeTextField
    )
    
    var content: [UIView] {
        [
            informationBox,
            stack(for: [descriptionTitle, description1, description2]),
        ]
    }
    
    func act() {
        postcodeTextField.resignFirstResponder()
        if let textFieldContent = postcodeTextField.text {
            switch submit(textFieldContent) {
            case .success:
                break
            case .failure(let error):
                errorTitle.isHidden = false
                errorDescription.text = error.localizedDescription
                errorDescription.isHidden = false
                informationBox.error()
                postcodeTextField.layer.borderColor = UIColor(.errorRed).cgColor
                UIAccessibility.post(notification: .layoutChanged, argument: errorTitle)
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
