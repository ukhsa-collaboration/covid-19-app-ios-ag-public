//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

class MockURLAuthenticationChallengeSender: NSObject, URLAuthenticationChallengeSender {
    
    func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {}
    
    func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {}
    
    func cancel(_ challenge: URLAuthenticationChallenge) {}
    
    func performDefaultHandling(for challenge: URLAuthenticationChallenge) {}
    
    func rejectProtectionSpaceAndContinue(with challenge: URLAuthenticationChallenge) {}
    
}
