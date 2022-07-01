//
// Copyright © 2022 DHSC. All rights reserved.
//

import Foundation
import Interface
import Localization

struct AdviceForIndexCasesEnglandInteractor: AdviceForIndexCasesEnglandViewController.Interacting {
    let openURL: (URL) -> Void
    var didTapPrimaryButton: () -> Void

    init(openURL: @escaping (URL) -> Void, didTapPrimaryButton: @escaping () -> Void) {
        self.openURL = openURL
        self.didTapPrimaryButton = didTapPrimaryButton
    }

    func didTapCommonQuestions() {
        openURL(ExternalLink.faq.url)
    }

    func didTapNHSOnline() {
        openURL(ExternalLink.nhs111Online.url)
    }

    func didTapContinue() {
        didTapPrimaryButton()
    }
}
