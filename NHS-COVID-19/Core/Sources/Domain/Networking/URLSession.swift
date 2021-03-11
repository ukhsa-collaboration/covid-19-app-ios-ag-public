//
// Copyright © 2020 NHSX. All rights reserved.
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
