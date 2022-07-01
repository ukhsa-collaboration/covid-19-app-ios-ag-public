//
// Copyright © 2022 DHSC. All rights reserved.
//

import Localization
import SwiftUI
import UIKit
import Common

public protocol HowDoYouFeelViewControllerInteracting {
    func didTapContinueButton(_ doYouFeelWell: Bool)
    func didTapBackButton()
}

struct HowDoYouFeelContent {
    public typealias Interacting = HowDoYouFeelViewControllerInteracting
    var views: [StackViewContentProvider]

    init(interactor: Interacting, doYouFeelWell: Bool?) {
        let emptyError = UIHostingController(
            rootView: ErrorBox(
                localize(.how_you_feel_error_title),
                description: localize(.how_you_feel_error_description)
            )
        )
        emptyError.view.backgroundColor = .clear
        emptyError.view.isHidden(true)

        var doYouFeelWell: Bool? = doYouFeelWell
        let yesNoOptions: [RadioButtonGroup.ButtonViewModel] = [
            .init(
                title: localize(.how_you_feel_yes_option),
                accessibilityText: localize(.how_you_feel_yes_option_accessibility_text),
                action: {
                        emptyError.view.isHidden = true
                        doYouFeelWell = true
                    }
            ),
            .init(
                title: localize(.how_you_feel_no_option),
                accessibilityText: localize(.how_you_feel_no_option_accessibility_text),
                action: {
                        emptyError.view.isHidden = true
                        doYouFeelWell = false
                }
            ),
        ]

        var yesNoButtonState: RadioButtonGroup.State {
            guard let doYouFeelWell = doYouFeelWell else {
                return RadioButtonGroup.State()
            }

            return RadioButtonGroup.State(selectedID: yesNoOptions[doYouFeelWell ? 0 : 1].id)
        }

        let stepLabel = BaseLabel()
        stepLabel.text = localize(.step_label(index: 2, count: 3))
        stepLabel.accessibilityLabel = localize(.step_accessibility_label(index: 2, count: 3))
        stepLabel.textColor = UIColor(.secondaryText)
        stepLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        stepLabel.numberOfLines = 0
        stepLabel.adjustsFontForContentSizeCategory = true

        let radioButtonGroup = UIHostingController(
            rootView: RadioButtonGroup(
                buttonViewModels: yesNoOptions,
                state: yesNoButtonState
            )
        )
        radioButtonGroup.view.backgroundColor = .clear

        let stackedViews: [UIView] = [
            emptyError.view,
            UIImageView(.isolationContinue).styleAsDecoration(),
            stepLabel,
            BaseLabel().set(text: localize(.how_you_feel_description)).styleAsPageHeader(),
            radioButtonGroup.view
        ]
        let contentStack = UIStackView(arrangedSubviews: stackedViews.flatMap { $0.content })
        contentStack.axis = .vertical
        contentStack.spacing = .standardSpacing

        let button = PrimaryButton(
            title: localize(.how_you_feel_continue_button),
            action: {
                if let unwrapped = doYouFeelWell {
                    interactor.didTapContinueButton(unwrapped)
                }
                else {
                    emptyError.view.isHidden = false
                }
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

public class HowDoYouFeelViewController: ScrollingContentViewController {
    public typealias Interacting = HowDoYouFeelViewControllerInteracting
    private let interactor: Interacting

    public init(interactor: Interacting, doYouFeelWell: Bool?) {
        self.interactor = interactor
        let content = HowDoYouFeelContent(
            interactor: interactor,
            doYouFeelWell: doYouFeelWell
        )
        super.init(views: content.views)
        title = localize(.how_you_feel_header)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: localize(.back), style: .plain, target: self, action: #selector(didTapBackButton))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    @objc private func didTapBackButton() {
        interactor.didTapBackButton()
    }
}
