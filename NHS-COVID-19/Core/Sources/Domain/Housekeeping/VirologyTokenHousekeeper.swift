//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation
import Logging

class VirologyTokenHousekeeper {
    private static let logger = Logger(label: "VirologyTokenHousekeeper")

    private let getTokenDeletionPeriod: () -> DayDuration
    private let getToday: () -> GregorianDay
    private let getTokens: () -> [VirologyTestTokens]?
    private let deleteToken: (VirologyTestTokens) -> Void

    init(getTokenDeletionPeriod: @escaping () -> DayDuration,
         getToday: @escaping () -> GregorianDay,
         getTokens: @escaping () -> [VirologyTestTokens]?,
         deleteToken: @escaping (VirologyTestTokens) -> Void) {
        self.getTokenDeletionPeriod = getTokenDeletionPeriod
        self.getToday = getToday
        self.getTokens = getTokens
        self.deleteToken = deleteToken
    }

    convenience init(
        virologyTestingStateStore: VirologyTestingStateStore,
        getTokenDeletionPeriod: @escaping () -> DayDuration,
        getToday: @escaping () -> GregorianDay
    ) {
        self.init(
            getTokenDeletionPeriod: getTokenDeletionPeriod,
            getToday: getToday,
            getTokens: { virologyTestingStateStore.virologyTestTokens },
            deleteToken: { virologyTestingStateStore.removeTestTokens($0) }
        )
    }

    func executeHousekeeping() -> AnyPublisher<Void, Never> {
        guard let tokens = getTokens() else {
            return Empty().eraseToAnyPublisher()
        }

        let tokenExpiryDate = getToday().advanced(by: -getTokenDeletionPeriod().days)

        let expiredTokens = tokens.filter { $0.creationDay < tokenExpiryDate }

        for expiredToken in expiredTokens {
            deleteToken(expiredToken)
        }

        return Empty().eraseToAnyPublisher()

    }
}
