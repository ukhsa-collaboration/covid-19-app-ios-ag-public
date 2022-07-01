//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Domain
import Foundation
import Interface

class VirologyTestingFlowInteractor: VirologyTestingFlowViewController.Interacting {
    var acknowledge: (() -> Void)?

    private let virologyTestOrderInfoProvider: VirologyTestingManaging
    private let openURL: (URL) -> Void

    private var referenceCode: ReferenceCode?
    private var orderWebsiteURL: URL?

    init(
        virologyTestOrderInfoProvider: VirologyTestingManaging,
        openURL: @escaping (URL) -> Void,
        acknowledge: (() -> Void)?
    ) {
        self.virologyTestOrderInfoProvider = virologyTestOrderInfoProvider
        self.openURL = openURL
        self.acknowledge = acknowledge
    }

    func fetchVirologyTestingInfo() -> AnyPublisher<InterfaceVirologyTestingInfo, NetworkRequestError> {
        virologyTestOrderInfoProvider.provideTestOrderInfo()
            .map { response in
                self.referenceCode = response.referenceCode
                self.orderWebsiteURL = response.testOrderWebsiteURL
                return InterfaceVirologyTestingInfo(referenceCode: response.referenceCode.value)
            }.eraseToAnyPublisher()
    }

    func didTapOrderTestLink() {
        if let orderWebsiteURL = orderWebsiteURL {
            Metrics.signpost(.launchedTestOrdering)
            openURL(orderWebsiteURL)
        }
    }
}
