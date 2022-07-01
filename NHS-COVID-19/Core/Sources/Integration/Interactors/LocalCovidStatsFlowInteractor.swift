//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Domain
import Foundation
import Interface
import UIKit

struct LocalCovidStatsFlowInteractor: LocalStatisticsFlowViewController.Interacting {

    var openURL: (URL) -> Void
    private weak var viewController: UINavigationController?
    var localStatsManager: LocalCovidStatsManaging
    private let country: DomainProperty<Country>
    private let localAuthorityId: DomainProperty<LocalAuthorityId?>

    init(
        viewController: UINavigationController?,
        localStatsManager: LocalCovidStatsManaging,
        country: DomainProperty<Country>,
        localAuthorityId: DomainProperty<LocalAuthorityId?>,
        openURL: @escaping (URL) -> Void
    ) {
        self.viewController = viewController
        self.localStatsManager = localStatsManager
        self.country = country
        self.localAuthorityId = localAuthorityId
        self.openURL = openURL
    }

    func fetchLocalDailyStats() -> AnyPublisher<InterfaceLocalCovidStatsDaily, Error> {
        guard let localAuthorityId = localAuthorityId.currentValue else {
            return Fail(error: InterfaceLocalCovidStatsDailyError()).eraseToAnyPublisher()
        }

        return localStatsManager.fetchLocalCovidStats().tryMap { localStatsDaily in
            try InterfaceLocalCovidStatsDaily(
                domainState: localStatsDaily,
                country: country.currentValue,
                localAuthorityId: localAuthorityId
            )
        }
        .mapError { $0 }
        .eraseToAnyPublisher()
    }

}
