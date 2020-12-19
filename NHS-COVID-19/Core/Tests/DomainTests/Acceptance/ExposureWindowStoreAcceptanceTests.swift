//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import ExposureNotification
import TestSupport
import XCTest
@testable import Domain
@testable import Integration
@testable import Scenarios

@available(iOS 13.7, *)
class ExposureWindowStoreAcceptanceTests: AcceptanceTestCase {
    private var cancellables = [AnyCancellable]()
    
    private let startDate = GregorianDay(year: 2020, month: 1, day: 1).startDate(in: .utc)
    private var riskyContact: RiskyContact!
    
    override func setUp() {
        $instance.exposureNotificationManager = MockWindowsExposureNotificationManager()
        currentDateProvider.setDate(startDate)
        try! completeRunning()
        
        riskyContact = RiskyContact(configuration: $instance)
    }
    
    func testExposureWindowsStoring() throws {
        let exposureWindowStore = ExposureWindowStore(store: $instance.encryptedStore)
        XCTAssertNil(exposureWindowStore.load())
        
        // Mock a Risky Contact and call Background Task
        riskyContact.trigger(exposureDate: currentDateProvider.currentDate) {
            self.coordinator.performBackgroundTask(task: NoOpBackgroundTask())
        }
        
        guard let storedExposureInfos = exposureWindowStore.load() else {
            throw TestError("Exposure window store data should not be nil")
        }
        
        XCTAssertEqual(storedExposureInfos.exposureWindowsInfo.count, 1)
    }
}
