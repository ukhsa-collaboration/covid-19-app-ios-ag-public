//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import UIKit

public protocol SelfDiagnosisAfterPositiveTestIsolatingViewControllerInteracting {
    func didTapReturnHome()
    func didTapNHS111Link()
}

private class Content: PrimaryButtonStickyFooterScrollingContent {
    public typealias Interacting = SelfDiagnosisAfterPositiveTestIsolatingViewControllerInteracting
    
    public init(interactor: Interacting, symptomState: SelfDiagnosisAfterPositiveTestIsolatingViewController.SymptomState) {
        super.init(
            scrollingViews: [
                UIImageView(.isolationContinue).styleAsDecoration(),
                BaseLabel().set(text: symptomState.title).styleAsPageHeader(),
                InformationBox.indication.badNews(symptomState.infobox),
                symptomState.body
                    .map { BaseLabel().set(text: $0).styleAsBody() },
                BaseLabel().set(text: symptomState.furtherAdvice).styleAsBody(),
                LinkButton(title: symptomState.link, action: interactor.didTapNHS111Link),
            ],
            primaryButton: (
                title: symptomState.button,
                action: interactor.didTapReturnHome
            )
        )
    }
}

public class SelfDiagnosisAfterPositiveTestIsolatingViewController: StickyFooterScrollingContentViewController {
    public enum SymptomState {
        case discardSymptoms, noSymptoms
    }
    
    public typealias Interacting = SelfDiagnosisAfterPositiveTestIsolatingViewControllerInteracting
    
    public init(interactor: Interacting, symptomState: SymptomState) {
        super.init(content: Content(interactor: interactor, symptomState: symptomState))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

extension SelfDiagnosisAfterPositiveTestIsolatingViewController.SymptomState {
    
    var title: String {
        switch self {
        case .discardSymptoms:
            return localize(.self_diagnosis_symptoms_after_positive_discarded_title)
        case .noSymptoms:
            return localize(.self_diagnosis_no_symptoms_after_positive_title)
        }
    }
    
    var infobox: String {
        switch self {
        case .discardSymptoms:
            return localize(.self_diagnosis_symptoms_after_positive_discarded_info)
        case .noSymptoms:
            return localize(.self_diagnosis_no_symptoms_after_positive_info)
        }
    }
    
    var body: [String] {
        switch self {
        case .discardSymptoms:
            return localizeAndSplit(.self_diagnosis_symptoms_after_positive_discarded_body)
        case .noSymptoms:
            return localizeAndSplit(.self_diagnosis_no_symptoms_after_positive_body)
        }
    }
    
    var furtherAdvice: String {
        switch self {
        case .discardSymptoms:
            return localize(.self_diagnosis_symptoms_after_positive_discarded_advice)
        case .noSymptoms:
            return localize(.self_diagnosis_no_symptoms_after_positive_advice)
        }
    }
    
    var link: String {
        switch self {
        case .discardSymptoms:
            return localize(.self_diagnosis_symptoms_after_positive_discarded_link)
        case .noSymptoms:
            return localize(.self_diagnosis_no_symptoms_after_positive_link)
        }
    }
    
    var button: String {
        switch self {
        case .discardSymptoms:
            return localize(.self_diagnosis_symptoms_after_positive_discarded_button_title)
        case .noSymptoms:
            return localize(.self_diagnosis_no_symptoms_after_positive_button_title)
        }
    }
}
