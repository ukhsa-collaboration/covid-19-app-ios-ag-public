//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain

public class MockStoreReviewController: StoreReviewControlling {
    public var requestedReview: Bool = false

    public init() {}

    public func requestAppReview() {
        requestedReview = true
    }
}
