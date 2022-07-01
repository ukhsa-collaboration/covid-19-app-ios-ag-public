//
// Copyright © 2022 DHSC. All rights reserved. 
//

import Common
import Localization
import SwiftUI

public protocol SymptomaticCaseSummaryViewControllerInteracting {
    func didTapSymptomaticCase()
    func didTapReturnHome()
    func didTapCancel()
    func didTapOnlineServicesLink()
    func didTapSymptomCheckerNormalActivities()
}

public enum SymptomaticSummaryResult: Equatable {
    case tryStayHome
    case continueWithNormalActivities
}

class SymptomaticCaseSummaryContent {
    public typealias Interacting = SymptomaticCaseSummaryViewControllerInteracting

    private let interactor: Interacting
    private let adviseForSymptomaticCase: SymptomaticSummaryResult

    init(interactor: Interacting, adviseForSymptomaticCase: SymptomaticSummaryResult) {
        self.interactor = interactor
        self.adviseForSymptomaticCase = adviseForSymptomaticCase
    }

    func makeViews() -> [StackViewContentProvider] {

        switch adviseForSymptomaticCase {
        case .tryStayHome:
            let heading = BaseLabel().set(text: localize(.symptom_checker_advice_stay_at_home_header)).styleAsPageHeader()
            heading.textAlignment = .center

            let image = UIImageView(.isolationStartIndex).styleAsDecoration()

            let box = makeBoxStackView()
            box.addArrangedSubview(BaseLabel().set(text: localize(.symptom_checker_advice_notice_header)).styleAsHeading())
            box.addArrangedSubview(BaseLabel().set(text: localize(.symptom_checker_advice_notice_body_one)).styleAsBody())
            box.addArrangedSubview(LinkButton(title: localize(.symptom_checker_advice_notice_stay_at_home_link_text), action: interactor.didTapSymptomaticCase))
            box.addArrangedSubview(BaseLabel().set(text: localize(.symptom_checker_advice_notice_body_two)).styleAsBody())

            let imageInfo = WelcomePoint(image: .infoCircle, body: localize(.symptom_checker_advice_icon_header), setBoldText: true, hStackAlignment: .center)

            let infoText = BaseLabel().set(text: localize(.symptom_checker_advice_bulleted_paragraph_header)).styleAsBody()

            let bulletList = BulletedList(
                symbolProperties: SymbolProperties(type: .fullCircle, size: .halfSpacing, color: .primaryText),
                rows: localizeAndSplit(.symptom_checker_advice_bulleted_paragraph_body)
            )

            let externalLinkButtonNHS = LinkButton(title: localize(.nhs_111_online_service), action: interactor.didTapOnlineServicesLink)

            let emergencyText = BaseLabel().set(text: localize(.symptom_checker_advice_emergency_contact_body)).styleAsBody()

            let primaryButton = PrimaryButton(title: localize(.summary_page_go_home), action: interactor.didTapReturnHome)

            return [image, heading, box, imageInfo, infoText, bulletList, externalLinkButtonNHS, emergencyText, primaryButton].compactMap { $0 }

        case .continueWithNormalActivities:

            let heading = BaseLabel().set(text: localize(.symptom_checker_advice_continue_normal_activities_header)).styleAsPageHeader()
            heading.textAlignment = .center

            let image = UIImageView(.onboardingStart).styleAsDecoration()

            let box = makeBoxStackView()
            box.addArrangedSubview(BaseLabel().set(text: localize(.symptom_checker_advice_notice_header)).styleAsHeading())
            box.addArrangedSubview(BaseLabel().set(text: localize(.symptom_checker_advice_notice_body_one)).styleAsBody())
            box.addArrangedSubview(LinkButton(title: localize(.symptom_checker_advice_notice_continue_normal_activities_link_text), action: interactor.didTapSymptomCheckerNormalActivities))
            box.addArrangedSubview(BaseLabel().set(text: localize(.symptom_checker_advice_notice_body_two)).styleAsBody())

            let imageInfo = WelcomePoint(image: .infoCircle, body: localize(.symptom_checker_advice_icon_header), setBoldText: true, hStackAlignment: .center)

            let infoText = BaseLabel().set(text: localize(.symptom_checker_advice_bulleted_paragraph_header)).styleAsBody()

            let bulletList = BulletedList(
                symbolProperties: SymbolProperties(type: .fullCircle, size: .halfSpacing, color: .primaryText),
                rows: localizeAndSplit(.symptom_checker_advice_bulleted_paragraph_body)
            )

            let externalLinkButtonNHS = LinkButton(title: localize(.nhs_111_online_service), action: interactor.didTapOnlineServicesLink)

            let emergencyText = BaseLabel().set(text: localize(.symptom_checker_advice_emergency_contact_body)).styleAsBody()

            let primaryButton = PrimaryButton(title: localize(.summary_page_go_home), action: interactor.didTapReturnHome)

            return [image, heading, box, imageInfo, infoText, bulletList, externalLinkButtonNHS, emergencyText, primaryButton].compactMap { $0 }
        }
    }

    private func makeBoxStackView() -> UIStackView {
        let box = UIStackView()
        box.axis = .vertical
        box.alignment = .leading
        box.spacing = .halfSpacing
        box.backgroundColor = UIColor(.surface)
        box.layer.cornerRadius = .buttonCornerRadius
        box.layoutMargins = .standard
        box.isLayoutMarginsRelativeArrangement = true
        return box
    }
}

public class SymptomaticCaseSummaryViewController: ScrollingContentViewController {
    public typealias Interacting = SymptomaticCaseSummaryViewControllerInteracting

    private let interactor: Interacting
    public init(interactor: Interacting, adviseForSymptomaticCase: SymptomaticSummaryResult) {

        let content = SymptomaticCaseSummaryContent(
            interactor: interactor,
            adviseForSymptomaticCase: adviseForSymptomaticCase )

        self.interactor = interactor
        super.init(views: content.makeViews())
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: localize(.back), style: .plain, target: self, action: #selector(didTapCancel))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @objc private func didTapCancel() {
        interactor.didTapCancel()
    }
}
