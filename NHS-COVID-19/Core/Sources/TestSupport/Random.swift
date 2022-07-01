//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

public extension String {

    static func random() -> String {
        UUID().uuidString
    }

}

public extension URL {

    static func random() -> URL {
        URL(string: "https://\(String.random()).com/\(String.random())")!
    }

}

public extension Data {

    static func random() -> Data {
        String.random().data(using: .utf8)!
    }

}

public extension HTTPRequest {

    static func random() -> HTTPRequest {
        .post("/\(String.random())", body: .plain(Data.random()))
    }

}

public extension HTTPResponse {

    static func random() -> HTTPResponse {
        HTTPResponse(statusCode: .random(in: 200 ..< 599), body: .untyped(.random()))
    }

}
