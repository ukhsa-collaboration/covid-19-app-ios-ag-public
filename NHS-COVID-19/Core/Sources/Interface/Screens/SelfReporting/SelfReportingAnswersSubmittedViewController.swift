//
// Copyright © 2022 DHSC. All rights reserved.
//

import Localization
import SwiftUI
import UIKit
import Common

public protocol SelfReportingAnswersSubmittedViewControllerInteracting {
    func didTapPrimaryButton()
}

private class Content {
    var views: [StackViewContentProvider]

    public typealias Interacting = SelfReportingAnswersSubmittedViewControllerInteracting

    public init(interactor: Interacting, state: SelfReportingAnswersSubmittedViewController.State) {

        let headerLabel = BaseLabel().set(text: state.headerLabel).styleAsPageHeader().centralized()

        let description = BaseLabel().set(text: state.description).styleAsBody()

        let infoBox = InformationBox.indication.warning(state.infoLabel)

        let primaryButton = PrimaryButton(
            title: localize(.continue_button_label),
            action: {
                interactor.didTapPrimaryButton()
            }
        )

        switch state {
        case .shared(let reportedResult):
            if reportedResult {
                infoBox.isHidden(true)
            }
        case .notShared(let reportedResult):
            if reportedResult {
                infoBox.isHidden(true)
            }
        }

        let contentStack = UIStackView(arrangedSubviews: [headerLabel, description, infoBox])
        contentStack.axis = .vertical
        contentStack.spacing = .doubleSpacing

        let stackView = UIStackView(arrangedSubviews: [SpacerView(), contentStack, primaryButton, SpacerView()])
        stackView.axis = .vertical
        stackView.spacing = .tripleSpacing

        views = [stackView]
    }
}

public class SelfReportingAnswersSubmittedViewController: ScrollingContentViewController {
    public enum State {
        case shared(reportedResult: Bool)
        case notShared(reportedResult: Bool)
    }

    public typealias Interacting = SelfReportingAnswersSubmittedViewControllerInteracting
    private let interactor: Interacting

    public init(interactor: Interacting, state: State) {
        UIAccessibility.post(notification: .screenChanged, argument: localize(.self_report_answers_submitted_accessibility_title))
        self.interactor = interactor
        super.init(views: Content(interactor: interactor, state: state).views)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

extension SelfReportingAnswersSubmittedViewController.State {

    var headerLabel: String {
        switch self {
        case .shared(_):
            return localize(.self_report_answers_submitted_shared_keys_header)
        case .notShared(_):
            return localize(.self_report_answers_submitted_not_shared_keys_header)
        }
    }

    var description: String {
        switch self {
        case .shared(let reportedResult):
            if reportedResult {
                return localize(.self_report_answers_submitted_shared_keys_reported_description)
            } else {
                return localize(.self_report_answers_submitted_shared_keys_not_reported_description)
            }
        case .notShared(let reportedResult):
            if reportedResult {
                return localize(.self_report_answers_submitted_not_shared_keys_reported_description)
            } else {
                return localize(.self_report_answers_submitted_not_shared_keys_not_reported_description)
            }
        }
    }

    var infoLabel: String {
        switch self {
        case .shared(let reportedResult):
            if reportedResult {
                return ""
            } else {
                return localize(.self_report_answers_submitted_not_reported_info_label)
            }
        case .notShared(let reportedResult):
            if reportedResult {
                return ""
            } else {
                return localize(.self_report_answers_submitted_not_reported_info_label)
            }
        }
    }

}
