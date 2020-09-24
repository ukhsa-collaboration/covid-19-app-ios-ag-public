//
// Copyright © 2020 NHSX. All rights reserved.
//

import StoreKit

public protocol StoreReviewControlling {
    func requestAppReview()
}

public struct StoreReviewController: StoreReviewControlling {
    
    public init() {}
    
    public func requestAppReview() {
        SKStoreReviewController.requestReview()
    }
}
