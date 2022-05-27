//
// Copyright © 2022 DHSC. All rights reserved.
//

import Common
import Localization
import SwiftUI
import UIKit

public protocol YourSymptomsViewControllerInteracting {
    func didTapReportButton(hasNonCardinalSymptoms: Bool, hasCardinalSymptoms: Bool)
    func didTapCancel()
}

public class YourSymptomsViewController: UIViewController {
    
    public typealias Interacting = YourSymptomsViewControllerInteracting
    
    private let interactor: Interacting
    private var symptomsQuestionnaire: InterfaceSymptomsQuestionnaire

    public init(symptomsQuestionnaire: InterfaceSymptomsQuestionnaire, interactor: Interacting) {
        self.symptomsQuestionnaire = symptomsQuestionnaire
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
        
        title = localize(.your_symptoms_title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var firstQuestionNotAnswerdError: UIHostingController<ErrorBox> = {
        UIHostingController(rootView: ErrorBox(
            localize(.your_symptoms_error_title),
            description: localize(.your_symptoms_error_description(question: symptomsQuestionnaire.noncardinal.heading))
        ))
    }()
    
    private lazy var secondQuestionNotAnswerdError: UIHostingController<ErrorBox> = {
        UIHostingController(rootView: ErrorBox(
            localize(.your_symptoms_error_title),
            description: localize(.your_symptoms_error_description(question: symptomsQuestionnaire.cardinal.heading))
        ))
    }()
    
    private lazy var noQuestionsAnswerdError: UIHostingController<ErrorBox> = {
        UIHostingController(rootView: ErrorBox(
            localize(.your_symptoms_error_title),
            description: localize(.your_symptoms_no_questions_answerd_error_description)
        ))
    }()
    
    private lazy var scrollView: UIScrollView = {
        UIScrollView()
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: localize(.back), style: .plain, target: self, action: #selector(didTapCancel))
        
        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)
        
        let stepLabel = BaseLabel()
        stepLabel.text = localize(.step_label(index: 1, count: 3))
        stepLabel.accessibilityLabel = localize(.step_accessibility_label(index: 1, count: 3))
        stepLabel.textColor = UIColor(.secondaryText)
        stepLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        stepLabel.numberOfLines = 0
        stepLabel.adjustsFontForContentSizeCategory = true
        
        let firstHeading = BaseLabel()
        firstHeading.text = symptomsQuestionnaire.noncardinal.heading
        firstHeading.styleAsPageHeader()

        let nonCardinalSymptoms = BulletedList(
            symbolProperties: SymbolProperties(type: .fullCircle, size: .hairSpacing, color: .primaryText),
            rows: symptomsQuestionnaire.noncardinal.content
        )
        
        let nonCardinalSymptomsStack = UIStackView(arrangedSubviews: [nonCardinalSymptoms])
        nonCardinalSymptomsStack.axis = .vertical
        nonCardinalSymptomsStack.spacing = .standardSpacing
        nonCardinalSymptomsStack.isLayoutMarginsRelativeArrangement = true
        nonCardinalSymptomsStack.layoutMargins = .standard
        
        let firstYesNoOptions: [RadioButtonGroup.ButtonViewModel] = [
            .init(
                title: localize(.your_symptoms_first_yes_option),
                accessibilityText: localize(.your_symptoms_first_yes_option_accessibility_text),
                action: {
                    self.firstQuestionNotAnswerdError.view.isHidden = true
                    self.noQuestionsAnswerdError.view.isHidden = true
                    self.symptomsQuestionnaire.noncardinal.hasSymptoms = true
                }
            ),
            .init(
                title: localize(.your_symptoms_first_no_option),
                accessibilityText: localize(.your_symptoms_first_no_option_accessibility_text),
                action: {
                    self.firstQuestionNotAnswerdError.view.isHidden = true
                    self.noQuestionsAnswerdError.view.isHidden = true
                    self.symptomsQuestionnaire.noncardinal.hasSymptoms = false
                }
            ),
        ]
        
        var firstButtonState: RadioButtonGroup.State {
            guard let hasSymptoms = symptomsQuestionnaire.noncardinal.hasSymptoms else {
                return RadioButtonGroup.State()
            }
            
            return RadioButtonGroup.State(selectedID: firstYesNoOptions[hasSymptoms ? 0 : 1].id)
        }
      
        let firstRadioButtonGroup = UIHostingController(
            rootView: RadioButtonGroup(
                buttonViewModels: firstYesNoOptions,
                state: firstButtonState
            )
        )
        firstRadioButtonGroup.view.backgroundColor = .clear
        
        let secondHeading = BaseLabel()
        secondHeading.text = symptomsQuestionnaire.cardinal.heading
        secondHeading.styleAsPageHeader()
        
        let secondYesNoOptions: [RadioButtonGroup.ButtonViewModel] = [
            .init(
                title: localize(.your_symptoms_second_yes_option),
                accessibilityText: localize(.your_symptoms_second_yes_option_accessibility_text),
                action: {
                    self.secondQuestionNotAnswerdError.view.isHidden = true
                    self.noQuestionsAnswerdError.view.isHidden = true
                    self.symptomsQuestionnaire.cardinal.hasSymptoms = true
                }
            ),
            .init(
                title: localize(.your_symptoms_second_no_option),
                accessibilityText: localize(.your_symptoms_second_no_option_accessibility_text),
                action: {
                    self.secondQuestionNotAnswerdError.view.isHidden = true
                    self.noQuestionsAnswerdError.view.isHidden = true
                    self.symptomsQuestionnaire.cardinal.hasSymptoms = false
                }
            ),
        ]
        
        var secondButtonState: RadioButtonGroup.State {
            guard let hasSymptoms = symptomsQuestionnaire.cardinal.hasSymptoms else {
                return RadioButtonGroup.State()
            }
            
            return RadioButtonGroup.State(selectedID: secondYesNoOptions[hasSymptoms ? 0 : 1].id)
        }
        
        let secondRadioButtonGroup = UIHostingController(
            rootView: RadioButtonGroup(
                buttonViewModels: secondYesNoOptions,
                state: secondButtonState
            )
        )
        secondRadioButtonGroup.view.backgroundColor = .clear
        
        firstQuestionNotAnswerdError.view.backgroundColor = .clear
        secondQuestionNotAnswerdError.view.backgroundColor = .clear
        noQuestionsAnswerdError.view.backgroundColor = .clear
        
        let errorStack = UIStackView(arrangedSubviews: [firstQuestionNotAnswerdError.view, secondQuestionNotAnswerdError.view, noQuestionsAnswerdError.view])
        
        let mainStack = UIStackView(arrangedSubviews: [errorStack, stepLabel, firstHeading, nonCardinalSymptomsStack, firstRadioButtonGroup.view, secondHeading, secondRadioButtonGroup.view])
        mainStack.axis = .vertical
        mainStack.isLayoutMarginsRelativeArrangement = true
        mainStack.spacing = .bigSpacing
        
        let reportButton = UIButton()
        reportButton.styleAsPrimary()
        reportButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        reportButton.setTitle(localize(.your_symptoms_continue_button), for: .normal)
        reportButton.addTarget(self, action: #selector(didTapReportButton), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [mainStack, reportButton])
        stack.axis = .vertical
        stack.spacing = .bigSpacing
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .standard
        
        scrollView.addFillingSubview(stack)
        view.addAutolayoutSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            stack.widthAnchor.constraint(equalTo: view.readableContentGuide.widthAnchor, multiplier: 1),
        ])
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        firstQuestionNotAnswerdError.view.isHidden = true
        secondQuestionNotAnswerdError.view.isHidden = true
        noQuestionsAnswerdError.view.isHidden = true
    }
    
    @objc func didTapReportButton() {
        let hasNonCardinalSymptoms = symptomsQuestionnaire.noncardinal.hasSymptoms
        let hasCardinalSymptoms = symptomsQuestionnaire.cardinal.hasSymptoms
        
        if hasNonCardinalSymptoms == nil && hasCardinalSymptoms == nil {
            noQuestionsAnswerdError.view.isHidden = false
            UIAccessibility.post(notification: .layoutChanged, argument: noQuestionsAnswerdError)
            scrollView.setContentOffset(.zero, animated: true)
            return
        }
        
        guard let hasNonCardinalSymptoms = hasNonCardinalSymptoms else {
            firstQuestionNotAnswerdError.view.isHidden = false
            UIAccessibility.post(notification: .layoutChanged, argument: firstQuestionNotAnswerdError)
            scrollView.setContentOffset(.zero, animated: true)
            return
        }
        
        guard let hasCardinalSymptoms = hasCardinalSymptoms else {
            secondQuestionNotAnswerdError.view.isHidden = false
            UIAccessibility.post(notification: .layoutChanged, argument: secondQuestionNotAnswerdError)
            scrollView.setContentOffset(.zero, animated: true)
            return
        }
        
        interactor.didTapReportButton(hasNonCardinalSymptoms: hasNonCardinalSymptoms, hasCardinalSymptoms: hasCardinalSymptoms)
    }

    @objc func didTapCancel() {
        interactor.didTapCancel()
    }
}
