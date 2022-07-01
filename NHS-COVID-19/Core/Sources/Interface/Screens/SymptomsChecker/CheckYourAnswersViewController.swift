//
// Copyright © 2022 DHSC. All rights reserved.
//

import Common
import Localization
import SwiftUI
import UIKit

public protocol CheckYourAnswersInteracting {
    func changeYourSymptoms()
    func changeHowYouFeel()
    func confirmAnswers()
    func didTapBackButton()

    var firstChangeButtonId: String { get }
    var secondChangeButtonId: String { get }
}

public class SummaryCardInfo {
    let questionTitle: String
    let listRows: [String]?
    let hasSymptoms: Bool?

    public init(questionTitle: String, listRows: [String]? = nil, hasSymptoms: Bool?) {
        self.questionTitle = questionTitle
        self.listRows = listRows
        self.hasSymptoms = hasSymptoms
    }
}

public class CheckYourAnswersViewController: UIViewController {
    public typealias Interacting = CheckYourAnswersInteracting

    private let symptomsQuestionnaire: InterfaceSymptomsQuestionnaire
    private let interactor: Interacting
    private let doYouFeelWell: Bool?

    public init(symptomsQuestionnaire: InterfaceSymptomsQuestionnaire, doYouFeelWell: Bool?, interactor: Interacting) {
        self.symptomsQuestionnaire = symptomsQuestionnaire
        self.interactor = interactor
        self.doYouFeelWell = doYouFeelWell
        super.init(nibName: nil, bundle: nil)
        title = localize(.check_answers_heading)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func summaryCard(changeAction: Selector, changeButtonIdentifier: String, title: String, sectionInfo: [SummaryCardInfo]) -> UIView {
        let yourSymptomsChangeButton = UIButton()
        yourSymptomsChangeButton.setTitle(localize(.check_answers_change_button), for: .normal)
        yourSymptomsChangeButton.setTitleColor(UIColor(.nhsBlue), for: .normal)
        yourSymptomsChangeButton.addTarget(self, action: changeAction, for: .touchUpInside)
        yourSymptomsChangeButton.setContentHuggingPriority(.almostRequest, for: .horizontal)
        yourSymptomsChangeButton.setContentCompressionResistancePriority(.almostRequest, for: .horizontal)
        yourSymptomsChangeButton.accessibilityIdentifier = changeButtonIdentifier

        var cardContent: [UIView] = []

        let cardHeading = UIStackView(arrangedSubviews: [
            BaseLabel().styleAsTertiaryTitle().set(text: title),
            yourSymptomsChangeButton
        ])
        cardHeading.axis = .horizontal

        cardContent.append(cardHeading)
        cardContent.append(divider())

        for (i, info) in sectionInfo.enumerated() {
            cardContent.append(BaseLabel().styleAsBoldBody().set(text: info.questionTitle))
            if let rows = info.listRows {
                let symptomsList = BulletedList(
                    symbolProperties: SymbolProperties(
                        type: .fullCircle,
                        size: .hairSpacing,
                        color: .primaryText
                    ),
                    rows: rows,
                    stackSpaceing: .hairSpacing,
                    boldText: true
                )
                cardContent.append(layoutStack(children: [symptomsList]))
            }
            cardContent.append(answerView(hasSymptoms: info.hasSymptoms))
            if i != sectionInfo.endIndex - 1 {
                cardContent.append(divider())
            }
        }

        let yourSymptomsCard = UIView()
        yourSymptomsCard.backgroundColor = UIColor(.surface)
        yourSymptomsCard.layer.cornerRadius = .buttonCornerRadius

        yourSymptomsCard.addFillingSubview(layoutStack(children: cardContent))

        return yourSymptomsCard
    }

    func divider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = UIColor(.background)
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return divider
    }

    func answerView(hasSymptoms: Bool?) -> UIStackView {
        let hasSymptoms: Bool = hasSymptoms ?? false
        let image = UIImageView(image: UIImage(systemName: hasSymptoms ? "checkmark" : "xmark"))
        image.tintColor = UIColor(hasSymptoms ? .nhsButtonGreen : .errorRed)
        image.contentMode = .scaleAspectFit
        let text = BaseLabel().styleAsBody().set(text: localize(hasSymptoms ? .your_symptoms_first_yes_option : .your_symptoms_first_no_option))

        let stack = UIStackView(arrangedSubviews: [image, text])
        stack.axis = .horizontal
        stack.spacing = .halfSpacing
        stack.alignment = .leading
        stack.distribution = .fillProportionally

        return stack
    }

    private lazy var confirmButton: UIButton = {
        let confirmButton = UIButton()
        confirmButton.styleAsPrimary()
        confirmButton.setTitle(localize(.check_answers_submit_button), for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmAnswers), for: .touchUpInside)
        return confirmButton
    }()

    let scrollView = UIScrollView()

    func layoutStack(children: [UIView]) -> UIStackView {
        mutating(UIStackView(arrangedSubviews: children)) {
            $0.axis = .vertical
            $0.spacing = .standardSpacing
            $0.isLayoutMarginsRelativeArrangement = true
            $0.layoutMargins = .standard
        }
    }

    private var symptomCardHeightConstraints = [(UIView, NSLayoutConstraint)]()

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        symptomCardHeightConstraints.forEach { view, constraint in
            view.sizeToFit()
            constraint.constant = view.bounds.height
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: localize(.back), style: .plain, target: self, action: #selector(didTapBackButton))

        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)

        let stepLabel = BaseLabel().styleAsCaption().set(text: localize(.step_label(index: 3, count: 3)))
        stepLabel.accessibilityLabel = localize(.step_accessibility_label(index: 3, count: 3))

        let heading = BaseLabel().styleAsPageHeader().set(text: localize(.check_answers_heading))

        let yourSymptomsCard = summaryCard(
            changeAction: #selector(changeYourSymptoms),
            changeButtonIdentifier: interactor.firstChangeButtonId,
            title: localize(.your_symptoms_title),
            sectionInfo: [
                SummaryCardInfo(
                    questionTitle: symptomsQuestionnaire.noncardinal.heading,
                    listRows: symptomsQuestionnaire.noncardinal.content,
                    hasSymptoms: symptomsQuestionnaire.noncardinal.hasSymptoms
                ),
                SummaryCardInfo(
                    questionTitle: symptomsQuestionnaire.cardinal.heading,
                    hasSymptoms: symptomsQuestionnaire.cardinal.hasSymptoms
                )
            ]
        )

        let howYouFeelCard = summaryCard(
            changeAction: #selector(changeHowYouFeel),
            changeButtonIdentifier: interactor.secondChangeButtonId,
            title: localize(.how_you_feel_header),
            sectionInfo: [
                SummaryCardInfo(
                    questionTitle: localize(.how_you_feel_description),
                    hasSymptoms: doYouFeelWell
                )
            ]
        )

        let headingStack = layoutStack(children: [stepLabel, heading])
        let answerCards = layoutStack(children: [yourSymptomsCard, howYouFeelCard])
        let buttonStack = layoutStack(children: [confirmButton])

        let stack = UIStackView(arrangedSubviews: [
            headingStack,
            answerCards,
            buttonStack
        ])
        stack.axis = .vertical

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

    @objc func confirmAnswers() {
        interactor.confirmAnswers()
    }

    @objc func changeYourSymptoms() {
        interactor.changeYourSymptoms()
    }

    @objc func changeHowYouFeel() {
        interactor.changeHowYouFeel()
    }

    @objc func didTapBackButton() {
        interactor.didTapBackButton()
    }
}
