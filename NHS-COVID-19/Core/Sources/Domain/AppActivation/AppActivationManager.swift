//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation

private struct ActivationInfo: Codable, DataConvertible {
    var isActivated: Bool
}

class AppActivationManager {
    
    private let httpClient: HTTPClient
    
    @Encrypted
    private var info: ActivationInfo?
    
    @Published
    private(set) var isActivated: Bool {
        didSet {
            info = ActivationInfo(isActivated: isActivated)
        }
    }
    
    init(store: EncryptedStoring, httpClient: HTTPClient) {
        self.httpClient = httpClient
        _info = store.encrypted("activation")
        isActivated = _info.wrappedValue?.isActivated ?? false
    }
    
    func activate(with code: String) -> AnyPublisher<Void, Error> {
        httpClient
            .fetch(AppActivationEndpoint(), with: code)
            .handleEvents(receiveOutput: didActivate)
            .mapError { $0 }
            .eraseToAnyPublisher()
    }
    
    private func didActivate() {
        isActivated = true
    }
    
}
