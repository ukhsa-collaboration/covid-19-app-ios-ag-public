//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct AppStoreVersionLookupEndpoint: HTTPEndpoint {

    private enum Errors: Error {
        case noResults(bundleId: String)
    }

    var bundleId: String

    func request(for input: Void) throws -> HTTPRequest {
        .get("/lookup", queryParameters: ["bundleId": bundleId])
    }

    func parse(_ response: HTTPResponse) throws -> Version {
        let decoder = JSONDecoder()
        let payload = try decoder.decode(Payload.self, from: response.body.content)
        guard let app = payload.results.first(where: { $0.bundleId == bundleId }) else {
            throw Errors.noResults(bundleId: bundleId)
        }
        return try Version(app.version)
    }

}

private struct Payload: Codable {

    struct App: Codable {
        var bundleId: String
        var version: String
    }

    var results: [App]

}
