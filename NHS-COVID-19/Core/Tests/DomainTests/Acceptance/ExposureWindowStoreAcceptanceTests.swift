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
    
    func testSubmitExposureWindowsAfterPositveTestResults() throws {
        let exposureWindowStore = ExposureWindowStore(store: $instance.encryptedStore)
        XCTAssertNil(exposureWindowStore.load())
        
        let exposureWindow = ExposureWindowInfo(
            date: GregorianDay(year: 2020, month: 11, day: 12),
            infectiousness: .high,
            scanInstances: [
                ExposureWindowInfo.ScanInstance(
                    minimumAttenuation: 97,
                    typicalAttenuation: 0,
                    secondsSinceLastScan: 201
                ),
            ],
            riskScore: 131.44555790888523,
            riskCalculationVersion: 2
        )
        
        exposureWindowStore.append([exposureWindow])
        
        let result = VirologyTestResult(
            testResult: .positive,
            testKitType: .labResult,
            endDate: Date()
        )
        
        let testResults = TestResult(result.testResult)
        
        exposureNotificationContext.postExposureWindows(result: testResults, testKitType: .labResult, requiresConfirmatoryTest: false)
        
        let endpoint = ExposureWindowEventEndpoint(latestAppVersion: $instance.appInfo.version, postcode: postcode.value, localAuthority: localAuthority.id.value, eventType: .exposureWindowPositiveTest(testKitType: .labResult, requiresConfirmatoryTest: false))
        let expectedRequest = try endpoint.request(for: exposureWindow)
        
        var isRequestSent = false
        
        let requests = $instance.apiClient.requests
        for request in requests {
            if request.body == expectedRequest.body {
                isRequestSent = true
            }
        }
        XCTAssertEqual(isRequestSent, true)
    }
}
