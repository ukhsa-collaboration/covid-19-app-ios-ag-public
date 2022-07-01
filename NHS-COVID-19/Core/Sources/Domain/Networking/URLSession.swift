//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

extension URLSessionConfiguration {
    func secure() {
        tlsMinimumSupportedProtocolVersion = .TLSv12
        httpCookieAcceptPolicy = .never
        httpShouldSetCookies = false
        httpCookieStorage = nil
        if #available(iOS 13, *) {
            requestCachePolicy = .reloadRevalidatingCacheData
        } else {
            requestCachePolicy = .useProtocolCachePolicy // If-None-Match is not properly implemented in iOS < 13
        }
        // 4 MB memory, 15 MB disk capacity
        urlCache = URLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 15 * 1024 * 1024, directory: nil)
    }
}

public extension URLSession {

    convenience init(trustValidator: TrustValidating) {
        let configuration: URLSessionConfiguration = .default
        configuration.secure()

        let delegate = TrustValidatingURLSessionDelegate(validator: trustValidator)
        self.init(configuration: configuration, delegate: delegate, delegateQueue: nil)
    }
}
