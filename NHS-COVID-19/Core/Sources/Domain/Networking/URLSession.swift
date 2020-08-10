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
        urlCache = nil
    }
}

public extension URLSession {
    
    convenience init(trustValidator: TrustValidating) {
        // Use of `ephemeral` here is a precaution. We are disabling all caching manually anyway, but using this instead
        // of `default` means if we miss something (especially as new properties are added over time) we’ll inherit the
        // `ephemeral` value instead of the `default` one.
        let configuration: URLSessionConfiguration = .ephemeral
        configuration.secure()
        
        let delegate = TrustValidatingURLSessionDelegate(validator: trustValidator)
        self.init(configuration: configuration, delegate: delegate, delegateQueue: nil)
    }
}
