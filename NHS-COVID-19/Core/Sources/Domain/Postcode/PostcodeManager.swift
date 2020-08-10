//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation

struct PostcodeManager {
    var postcodeStoreLoad: () -> String?
    var updateRisk: (PostcodeRisk) -> Void
    var fetchRiskyPostcodes: () -> AnyPublisher<[String: PostcodeRisk], NetworkRequestError>
    
    func evaluatePostcodeRisk() -> AnyPublisher<Void, Never> {
        guard let postcode = postcodeStoreLoad() else {
            return Just(()).eraseToAnyPublisher()
        }
        return fetchRiskyPostcodes()
            .map { dict in
                guard let riskLevel = dict[postcode.uppercased()] else {
                    return PostcodeRisk.low
                }
                return riskLevel
            }
            .handleEvents(receiveOutput: updateRisk)
            .replaceError(with: PostcodeRisk.low)
            .map { _ in }
            .eraseToAnyPublisher()
    }
}

extension PostcodeManager {
    init(postcodeStore: PostcodeStore, httpClient: HTTPClient) {
        self.init(
            postcodeStoreLoad: postcodeStore.load,
            updateRisk: {
                postcodeStore.riskLevel = $0
            },
            fetchRiskyPostcodes: { httpClient.fetch(RiskyPostcodesEndpoint()) }
        )
    }
}
