//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Foundation

private struct HomeAnimationsEnabledInfo: Codable, DataConvertible {
    var homeAnimationsEnabled: Bool
}

public protocol HomeAnimationsEnabledProtocol {
    var homeAnimationsEnabled: DomainProperty<Bool> { get }
    func save(enabled: Bool)
    func delete()
}

class HomeAnimationsStore: HomeAnimationsEnabledProtocol {
    @PublishedEncrypted private var homeAnimationsEnabledInfo: HomeAnimationsEnabledInfo?

    private(set) lazy var homeAnimationsEnabled: DomainProperty<Bool> = {
        $homeAnimationsEnabledInfo
            .map { $0?.homeAnimationsEnabled ?? true }
    }()

    init(store: EncryptedStoring) {
        _homeAnimationsEnabledInfo = store.encrypted("userSettingsInfo")
    }

    func save(enabled: Bool) {
        homeAnimationsEnabledInfo = HomeAnimationsEnabledInfo(homeAnimationsEnabled: enabled)
    }

    func delete() {
        homeAnimationsEnabledInfo = nil
    }
}
