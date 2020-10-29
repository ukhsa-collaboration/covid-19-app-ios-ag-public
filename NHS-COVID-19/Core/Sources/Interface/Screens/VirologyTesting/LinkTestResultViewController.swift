//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Localization
import UIKit

public protocol LinkTestResultViewControllerInteracting {
    func submit(testCode: String) -> AnyPublisher<Void, DisplayableError>
}

public class LinkTestResultViewController: UIViewController {
    
    public typealias Interacting = LinkTestResultViewControllerInteracting
    
    private let interactor: Interacting
    private var cancellable: AnyCancellable?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.styleAsPageHeader()
        label.text = localize(.link_test_result_header)
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.styleAsBody()
        label.text = localize(.link_test_result_description)
        return label
    }()
    
    private lazy var headingLabel: UILabel = {
        let label = UILabel()
        label.styleAsHeading()
        label.text = localize(.link_test_result_enter_code_heading)
        return label
    }()
    
    private lazy var exampleLabel: UILabel = {
        let label = UILabel()
        label.styleAsSecondaryBody()
        label.text = localize(.link_test_result_enter_code_example)
        return label
    }()
    
    private lazy var errorTitle: UILabel = {
        let label = UILabel()
        label.styleAsErrorHeading()
        label.isHidden = true
        return label
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
    
    private lazy var testCodeTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .asciiCapable
        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.layer.borderWidth = 2
        textField.accessibilityLabel = localize(.link_test_result_enter_code_textfield_label)
        textField.layer.borderColor = UIColor(.secondaryText).cgColor
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        textField.autocorrectionType = .no
        textField.enablesReturnKeyAutomatically = true
        textField.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
        textField.rightView = spinner
        NSLayoutConstraint.activate([textField.heightAnchor.constraint(greaterThanOrEqualToConstant: .hitAreaMinHeight)])
        return textField
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.styleAsPrimary()
        button.setTitle(localize(.link_test_result_button_title), for: .normal)
        button.addTarget(self, action: #selector(didSelectAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var informationBox: InformationBox = InformationBox.error(
        headingLabel, exampleLabel, errorTitle, testCodeTextField
    )
    
    func stack(for labels: [UILabel]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: labels)
        stackView.axis = .vertical
        stackView.spacing = .standardSpacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .inner
        return stackView
    }
    
    public init(interactor: Interacting) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
        
        title = localize(.link_test_result_title)
        isModalInPresentation = true
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: localize(.cancel), style: .done, target: self, action: #selector(didTapCancel))
        
        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)
        
        let content = [
            stack(for: [titleLabel, descriptionLabel]),
            informationBox,
        ]
        
        let stackView = UIStackView(arrangedSubviews: content)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = .standardSpacing
        stackView.layoutMargins = .standard
        stackView.isLayoutMarginsRelativeArrangement = true
        
        let scrollView = UIScrollView()
        scrollView.addFillingSubview(stackView)
        
        view.addAutolayoutSubview(scrollView)
        
        let keyboardIndicatingView = UIView()
        keyboardIndicatingView.isHidden = true
        view.addAutolayoutSubview(keyboardIndicatingView)

        let footerStack = UIStackView(arrangedSubviews: [submitButton])
        footerStack.axis = .vertical
        footerStack.spacing = .standardSpacing
        view.addAutolayoutSubview(footerStack)
        
        // Setup Keyboard
        view.setupKeyboardAppearance(pushedView: footerStack)
        scrollView.keyboardDismissMode = .onDrag
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerStack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: .standardSpacing),
            footerStack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -.standardSpacing),
            
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            scrollView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            footerStack.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: .standardSpacing),
            footerStack.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).withPriority(.defaultHigh),
        ])
        
    }
    
    @objc private func valueChanged() {
        if let textFieldContent = testCodeTextField.text {
            let formattedActivationCode = LinkTestResultCodeFormatter.format(textFieldContent)
            testCodeTextField.text = formattedActivationCode
            if textFieldContent.count != formattedActivationCode.count {
                DispatchQueue.main.async {
                    let endPosition = self.testCodeTextField.endOfDocument
                    self.testCodeTextField.selectedTextRange = self.testCodeTextField.textRange(from: endPosition, to: endPosition)
                }
            }
        }
    }
    
    private func submit() {
        CATransaction.disableActions {
            submitButton.isEnabled = false
            testCodeTextField.rightViewMode = .always
        }
        
        testCodeTextField.resignFirstResponder()
        if let textFieldContent = testCodeTextField.text {
            cancellable = interactor.submit(testCode: textFieldContent)
                .receive(on: RunLoop.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        CATransaction.disableActions {
                            self?.submitButton.isEnabled = true
                            self?.testCodeTextField.rightViewMode = .never
                        }
                        
                        if case .failure(let error) = completion {
                            self?.showError(error.localizedDescription)
                        }
                    },
                    receiveValue: {}
                )
        }
    }
    
    private func showError(_ error: String) {
        errorTitle.isHidden = false
        errorTitle.text = error
        informationBox.error()
        testCodeTextField.layer.borderColor = UIColor(.errorRed).cgColor
        UIAccessibility.post(notification: .layoutChanged, argument: errorTitle)
    }
    
    @objc private func didSelectAction() {
        submit()
    }
    
    @objc private func didTapCancel() {
        dismiss(animated: true)
    }
}

extension LinkTestResultViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        submit()
        return false
    }
}

public struct LinkTestResultCodeFormatter {
    public static func format(_ code: String) -> String {
        let allowedChars = CharacterSet.crockfordDamm
        let formattedCode = code
            .lowercased()
            .components(separatedBy: allowedChars.inverted)
            .joined()
        return String(formattedCode.prefix(8))
    }
}

private extension CharacterSet {
    static var crockfordDamm: CharacterSet {
        var allowedChars = CharacterSet()
        allowedChars.insert(charactersIn: "0123456789abcdefghjkmnpqrstvwxyz")
        return allowedChars
    }
}
