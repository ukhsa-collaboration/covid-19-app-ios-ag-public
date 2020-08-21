//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Domain
import Foundation
import Interface

class VirologyTestingFlowInteractor: VirologyTestingFlowViewController.Interacting {
    private let virologyTestOrderInfoProvider: VirologyTestingTestOrderInfoProviding
    private let openURL: (URL) -> Void
    private let pasteboardCopier: PasteboardCopying
    
    private var referenceCode: ReferenceCode?
    private var orderWebsiteURL: URL?
    
    init(virologyTestOrderInfoProvider: VirologyTestingTestOrderInfoProviding,
         openURL: @escaping (URL) -> Void,
         pasteboardCopier: PasteboardCopying) {
        self.virologyTestOrderInfoProvider = virologyTestOrderInfoProvider
        self.openURL = openURL
        self.pasteboardCopier = pasteboardCopier
    }
    
    func fetchVirologyTestingInfo() -> AnyPublisher<InterfaceVirologyTestingInfo, NetworkRequestError> {
        virologyTestOrderInfoProvider.provideTestOrderInfo()
            .map { response in
                self.referenceCode = response.referenceCode
                self.orderWebsiteURL = response.testOrderWebsiteURL
                return InterfaceVirologyTestingInfo(referenceCode: response.referenceCode.value)
            }.eraseToAnyPublisher()
    }
    
    func didTapCopyReferenceCode() {
        if let referenceCode = referenceCode {
            pasteboardCopier.copyToPasteboard(value: referenceCode.value)
        }
    }
    
    func didTapOrderTestLink() {
        if let orderWebsiteURL = orderWebsiteURL {
            openURL(orderWebsiteURL)
        }
    }
}
