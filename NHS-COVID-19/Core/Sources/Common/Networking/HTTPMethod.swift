//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

public enum HTTPMethod: String, Equatable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case options = "OPTIONS"
    case connect = "CONNECT"
    case head = "HEAD"
    case patch = "PATCH"
    case trace = "TRACE"
}

extension HTTPMethod {
    // See: https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods

    private enum BodyRequirment {
        case mustHave
        case mustNotHave
        case mayHave
    }

    private var bodyRequirement: BodyRequirment {
        switch self {
        case .get: return .mustNotHave
        case .post: return .mustHave
        case .put: return .mustHave
        case .delete: return .mayHave
        case .options: return .mustNotHave
        case .connect: return .mustNotHave
        case .head: return .mustNotHave
        case .patch: return .mustHave
        case .trace: return .mustNotHave
        }
    }

    var mustHaveBody: Bool {
        bodyRequirement == .mustHave
    }

    var mustNotHaveBody: Bool {
        bodyRequirement == .mustNotHave
    }

}
