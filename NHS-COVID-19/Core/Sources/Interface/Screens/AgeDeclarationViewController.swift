//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import SwiftUI
import UIKit

public protocol AgeDeclarationViewControllerInteracting {
    func didTapContinueButton(_ isOverAgeLimit: Bool)
}

struct AgeDeclarationContent {
    public typealias Interacting = AgeDeclarationViewControllerInteracting
    var views: [StackViewContentProvider]

    init(interactor: Interacting, birthThresholdDate: Date, isIndexCase: Bool) {
        let emptyError = UIHostingController(
            rootView: ErrorBox(
                localize(.age_declaration_error_title),
                description: localize(.age_declaration_error_description)
            )
        )
        emptyError.view.backgroundColor = .clear
        emptyError.view.isHidden(true)

        var isOverAgeLimit: Bool?
        let yesNoOptions: [RadioButtonGroup.ButtonViewModel] = [
            .init(
                title: localize(.age_declaration_yes_option),
                accessibilityText: localize(.age_declaration_yes_option_accessibility_text(date: birthThresholdDate)),
                action: { isOverAgeLimit = true }
            ),
            .init(
                title: localize(.age_declaration_no_option),
                accessibilityText: localize(.age_declaration_no_option_accessibility_text(date: birthThresholdDate)),
                action: { isOverAgeLimit = false }
            ),
        ]

        let radioButtonGroup = UIHostingController(
            rootView: RadioButtonGroup(buttonViewModels: yesNoOptions)
        )
        radioButtonGroup.view.backgroundColor = .clear

        var stackedViews: [UIView] = [
            UIImageView(.isolationContinue).styleAsDecoration(),
            BaseLabel().set(text: localize(.age_declaration_heading)).styleAsPageHeader().centralized(),
        ]

        if !isIndexCase {
            stackedViews.append(contentsOf: [
                BaseLabel().set(text: localize(.age_declaration_description)).styleAsBody(),
            ])
        }

        stackedViews.append(contentsOf: [
            emptyError.view,
            BaseLabel().set(text: localize(.age_declaration_question(date: birthThresholdDate))).styleAsSecondaryTitle(),
            radioButtonGroup.view,
        ])

        let contentStack = UIStackView(arrangedSubviews: stackedViews.flatMap { $0.content })
        contentStack.axis = .vertical
        contentStack.spacing = .standardSpacing

        let button = PrimaryButton(
            title: localize(.age_declaration_primary_button_title),
            action: {
                guard let isOverAgeLimit = isOverAgeLimit else {
                    emptyError.view.isHidden(false)
                    UIAccessibility.post(notification: .layoutChanged, argument: emptyError)
                    return
                }

                emptyError.view.isHidden(true)
                interactor.didTapContinueButton(isOverAgeLimit)
            }
        )

        let stackContent = [contentStack, button]
        let stackView = UIStackView(arrangedSubviews: stackContent)
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = .standardSpacing

        views = [stackView]
    }
}

public class AgeDeclarationViewController: ScrollingContentViewController {
    public typealias Interacting = AgeDeclarationViewControllerInteracting
    private let interactor: Interacting

    public init(interactor: Interacting, birthThresholdDate: Date, isIndexCase: Bool) {
        self.interactor = interactor
        let content = AgeDeclarationContent(
            interactor: interactor,
            birthThresholdDate: birthThresholdDate,
            isIndexCase: isIndexCase
        )
        super.init(views: content.views)
        title = localize(.age_declaration_title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
