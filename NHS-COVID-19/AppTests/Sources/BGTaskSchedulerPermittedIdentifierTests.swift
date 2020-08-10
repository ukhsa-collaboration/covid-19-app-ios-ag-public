//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import XCTest

class BGTaskSchedulerPermittedIdentifiersTests: XCTestCase {
    
    func testBGTaskSchedulerPermittedIdentifierRetrieval() {
        let bundle = Bundle(for: BackgroundTaskIdentifiers.self)
        let backgroundTaskIdentifiers = BackgroundTaskIdentifiers(in: bundle)
        XCTAssertNotNil(backgroundTaskIdentifiers.all)
        XCTAssertNotNil(backgroundTaskIdentifiers.exposureNotification)
    }
}
