//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest
@testable import Domain

class TrustValidatingURLSessionDelegateTests: XCTestCase {
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
    
    func testAcceptingTrust() {
        let delegate = TrustValidatingURLSessionDelegate(validator: MockTrustValidator(canAccept: true))
        var disposition: URLSession.AuthChallengeDisposition?
        var credential: URLCredential?
        delegate.urlSession(.shared, didReceive: challenge) {
            disposition = $0
            credential = $1
        }
        
        XCTAssertNil(credential)
        XCTAssertEqual(disposition, .performDefaultHandling)
    }
    
    func testRejectingTrust() {
        let delegate = TrustValidatingURLSessionDelegate(validator: MockTrustValidator(canAccept: false))
        var disposition: URLSession.AuthChallengeDisposition?
        var credential: URLCredential?
        delegate.urlSession(.shared, didReceive: challenge) {
            disposition = $0
            credential = $1
        }
        
        XCTAssertNil(credential)
        XCTAssertEqual(disposition, .cancelAuthenticationChallenge)
    }
    
}
