//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest

class URLSessionTests: XCTestCase {
    private let protectionSpace = URLProtectionSpace(
        host: "example.com",
        port: 443,
        protocol: NSURLProtectionSpaceHTTPS,
        realm: nil,
        authenticationMethod: NSURLAuthenticationMethodServerTrust
    )
    
    private lazy var challenge = URLAuthenticationChallenge(
        protectionSpace: protectionSpace,
        proposedCredential: nil,
        previousFailureCount: 0,
        failureResponse: nil,
        error: nil,
        sender: MockURLAuthenticationChallengeSender()
    )
    
    func test_has_correct_security_configuration() throws {
        let configuration = URLSession(trustValidator: MockTrustValidator(canAccept: true)).configuration
        
        XCTAssertEqual(configuration.tlsMinimumSupportedProtocolVersion, .TLSv12)
        XCTAssertEqual(configuration.httpCookieAcceptPolicy, .never)
        XCTAssertFalse(configuration.httpShouldSetCookies)
        XCTAssertNil(configuration.httpCookieStorage)
        XCTAssertNil(configuration.urlCache)
    }
    
    func test_trust_validtor_is_used_to_configure_delegate() throws {
        let session = URLSession(trustValidator: MockTrustValidator(canAccept: false))
        
        var disposition: URLSession.AuthChallengeDisposition?
        var credential: URLCredential?
        session.delegate?.urlSession?(session, didReceive: challenge) {
            disposition = $0
            credential = $1
        }
        
        XCTAssertNil(credential)
        XCTAssertEqual(disposition, .cancelAuthenticationChallenge)
    }
}
