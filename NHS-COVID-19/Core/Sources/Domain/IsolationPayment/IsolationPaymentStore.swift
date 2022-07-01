//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Foundation

private struct IsolationPaymentInfo: Codable, DataConvertible, Equatable {
    var isEnabled: Bool
    var ipcToken: String?
}

class IsolationPaymentStore {
    @PublishedEncrypted private var isolationPaymentInfo: IsolationPaymentInfo?

    private(set) lazy var isolationPaymentRawState: DomainProperty<IsolationPaymentRawState?> = {
        $isolationPaymentInfo
            .map { $0.flatMap(IsolationPaymentRawState.init) }
    }()

    init(store: EncryptedStoring) {
        _isolationPaymentInfo = store.encrypted("isolation_payment_store")
    }

    @available(*, deprecated, message: "Use isolationPaymentRawState instead.")
    func load() -> IsolationPaymentRawState? {
        isolationPaymentRawState.currentValue
    }

    func save(_ state: IsolationPaymentRawState) {
        switch state {
        case .disabled:
            isolationPaymentInfo = IsolationPaymentInfo(isEnabled: false)
        case .ipcToken(let token):
            isolationPaymentInfo = IsolationPaymentInfo(isEnabled: true, ipcToken: token)
        }
    }

    func delete() {
        isolationPaymentInfo = nil
    }
}

extension IsolationPaymentRawState {
    fileprivate init?(_ info: IsolationPaymentInfo) {
        if info.isEnabled {
            if let tokenString = info.ipcToken {
                self = .ipcToken(tokenString)
            } else {
                return nil
            }
        } else {
            self = .disabled
        }
    }
}
