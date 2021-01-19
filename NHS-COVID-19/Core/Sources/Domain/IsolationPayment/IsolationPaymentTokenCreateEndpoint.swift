//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct IsolationPaymentTokenCreateEndpoint: HTTPEndpoint {
    func request(for country: Country) throws -> HTTPRequest {
        let countryString: String = {
            switch country {
            case .england: return "England"
            case .wales: return "Wales"
            }
        }()
        let payload = RequestPayload(country: countryString)
        let encoder = JSONEncoder()
        let data = try encoder.encode(payload)
        return .post("/isolation-payment/ipc-token/create", body: .json(data))
    }
    
    func parse(_ response: HTTPResponse) throws -> IsolationPaymentRawState {
        return try IsolationPaymentRawState(try Response.parse(response))
    }
}

private struct RequestPayload: Codable {
    var country: String
}

private extension IsolationPaymentTokenCreateEndpoint {
    struct Response: Decodable, Equatable {
        var isEnabled: Bool
        var ipcToken: String?
        
        fileprivate static func parse(_ response: HTTPResponse) throws -> Self {
            let jsonDecoder = JSONDecoder()
            return try jsonDecoder.decode(Self.self, from: response.body.content)
        }
    }
}

extension IsolationPaymentRawState {
    enum ResponseError: Error {
        case noToken
    }
    
    fileprivate init(_ response: IsolationPaymentTokenCreateEndpoint.Response) throws {
        if response.isEnabled {
            if let tokenString = response.ipcToken {
                self = .ipcToken(tokenString)
                Metrics.signpost(.receivedActiveIpcToken)
            } else {
                throw ResponseError.noToken
            }
        } else {
            self = .disabled
        }
    }
}
