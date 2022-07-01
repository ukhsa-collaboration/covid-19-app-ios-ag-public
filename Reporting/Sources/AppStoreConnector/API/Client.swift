//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

public final class Client {

    public let connection: Connection

    init(connection: Connection) {
        self.connection = connection
    }

}

public extension Client {

    convenience init(key: EC256PrivateKey, keyID: String, issuerID: String, networkingDelegate: NetworkingDelegate = URLSession.shared) {
        let tokenGenerator = AuthTokenGenerator(
            key: key,
            keyID: keyID,
            issuerID: issuerID
        )

        let requestGenerator = AuthenticatedRequestGenerator(host: "api.appstoreconnect.apple.com", path: "/v1") {
            let expiryDate = Date(timeIntervalSinceNow: 60)
            return try! tokenGenerator.token(expiryingAt: expiryDate)
        }

        let connection = Connection(
            requestGenerator: requestGenerator,
            networkingDelegate: networkingDelegate
        )

        self.init(connection: connection)
    }

}
