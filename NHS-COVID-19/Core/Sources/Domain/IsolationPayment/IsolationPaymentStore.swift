//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

private struct IsolationPaymentInfo: Codable, DataConvertible, Equatable {
    var isEnabled: Bool
    var ipcToken: String?
}

class IsolationPaymentStore {
    @Encrypted private var isolationPaymentInfo: IsolationPaymentInfo? {
        didSet {
            isolationPaymentState = _isolationPaymentInfo.wrappedValue.flatMap { IsolationPaymentRawState($0) }
        }
    }
    
    @Published var isolationPaymentState: IsolationPaymentRawState?
    
    init(store: EncryptedStoring) {
        _isolationPaymentInfo = store.encrypted("isolation_payment_store")
        isolationPaymentState = _isolationPaymentInfo.wrappedValue.flatMap { IsolationPaymentRawState($0) }
    }
    
    func load() -> IsolationPaymentRawState? {
        return isolationPaymentState
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
