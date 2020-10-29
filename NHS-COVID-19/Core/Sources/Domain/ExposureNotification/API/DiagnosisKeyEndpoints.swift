//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct DiagnosisKeyDailyEndpoint: HTTPEndpoint {
    
    func request(for input: Increment) throws -> HTTPRequest {
        HTTPRequest(
            method: .get,
            path: "/distribution/daily/\(input.parse()).zip",
            body: nil
        )
    }
    
    func parse(_ response: HTTPResponse) throws -> Data {
        response.body.content
    }
}

struct DiagnosisKeyTwoHourlyEndpoint: HTTPEndpoint {
    
    func request(for input: Increment) throws -> HTTPRequest {
        HTTPRequest(
            method: .get,
            path: "/distribution/two-hourly/\(input.parse()).zip",
            body: nil
        )
    }
    
    func parse(_ response: HTTPResponse) throws -> Data {
        response.body.content
    }
}

extension Increment {
    func parse() -> String {
        switch self {
        case .twoHourly(let day, let hour):
            return String(format: "%4d%02d%02d%02d", day.year, day.month, day.day, hour.value)
        case .daily(let day):
            return String(format: "%4d%02d%02d00", day.year, day.month, day.day)
        }
    }
}
