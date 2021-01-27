//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import TestSupport
import XCTest
@testable import Domain

class ExposureDetectionEndpointManagerTests: XCTestCase {
    var httpClient: MockHTTPClient!
    var manager: ExposureDetectionEndpointManager!
    var fileStorage: FileStorage!
    
    override func setUp() {
        httpClient = MockHTTPClient()
        fileStorage = FileStorage(forNewCachesOf: .random())
        manager = ExposureDetectionEndpointManager(distributionClient: httpClient, fileStorage: fileStorage)
    }
    
    func testGetDailyKeysFetchesFromCorrectEndpoint() throws {
        let increment = Increment.daily(.init(year: 2020, month: 6, day: 26))
        
        _ = manager.getExposureKeys(for: increment)
        let request = try XCTUnwrap(httpClient.lastRequest)
        XCTAssertEqual("/distribution/daily/2020062600.zip", request.path)
    }
    
    func testGetTwoHourlyKeysFetchesFromCorrectEndpoint() throws {
        let increment = Increment.twoHourly(.init(year: 2020, month: 6, day: 26), .init(value: 1))
        
        _ = manager.getExposureKeys(for: increment)
        let request = try XCTUnwrap(httpClient.lastRequest)
        XCTAssertEqual("/distribution/two-hourly/2020062601.zip", request.path)
    }
    
    func testGetDailyKeysLoadsFromCache() throws {
        let increment = Increment.daily(.init(year: 2020, month: 6, day: 26))
        fileStorage.save(.random(), to: increment.identifier)
        
        _ = try manager.getExposureKeys(for: increment).await().get()
        XCTAssertNil(httpClient.lastRequest)
    }
    
    func testGetTwoHourlyKeysLoadsFromCache() throws {
        let increment = Increment.twoHourly(.init(year: 2020, month: 6, day: 26), .init(value: 1))
        fileStorage.save(.random(), to: increment.identifier)
        
        _ = try manager.getExposureKeys(for: increment).await().get()
        XCTAssertNil(httpClient.lastRequest)
    }
    
    func testSaveDailyKeysResponseToCache() throws {
        let increment = Increment.daily(.init(year: 2020, month: 6, day: 26))
        httpClient.response = Result.success(.ok(with: .untyped(.random())))
        _ = try manager.getExposureKeys(for: increment).await().get()
        
        XCTAssertTrue(fileStorage.hasContent(for: increment.identifier))
    }
    
    func testSaveTwoHourlyKeysResponseToCache() throws {
        let increment = Increment.twoHourly(.init(year: 2020, month: 6, day: 26), .init(value: 1))
        httpClient.response = Result.success(.ok(with: .untyped(.random())))
        _ = try manager.getExposureKeys(for: increment).await().get()
        
        XCTAssertTrue(fileStorage.hasContent(for: increment.identifier))
    }
}
