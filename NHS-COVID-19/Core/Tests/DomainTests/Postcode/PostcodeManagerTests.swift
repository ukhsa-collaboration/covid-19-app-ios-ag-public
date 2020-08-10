//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Scenarios
import TestSupport
import XCTest
@testable import Domain

class PostcodeManagerTests: XCTestCase {
    var postcodeManager: PostcodeManager!
    
    var riskyPostcodes = [String: PostcodeRisk]()
    
    var receivedRisk: PostcodeRisk?
    
    func fetchRiskyPostcodes() -> AnyPublisher<[String: PostcodeRisk], NetworkRequestError> {
        Result.success(riskyPostcodes).publisher.eraseToAnyPublisher()
    }
    
    var postcode: String?
    
    func mockPostcodeLoad() -> String? {
        postcode
    }
    
    override func setUp() {
        receivedRisk = nil
        postcodeManager = PostcodeManager(postcodeStoreLoad: mockPostcodeLoad, updateRisk: { self.receivedRisk = $0 }, fetchRiskyPostcodes: fetchRiskyPostcodes)
    }
    
    func testIsPostcodeHighRiskDoesNotReturnAValueWithNoPostcode() throws {
        postcode = nil
        try postcodeManager.evaluatePostcodeRisk().await().get()
        XCTAssertNil(receivedRisk)
    }
    
    func testPostcodeEvaluationReturnsHighWhenPostCodeIsMarkedAsHighRisk() throws {
        postcode = "B44"
        riskyPostcodes = ["B44": .high]
        try postcodeManager.evaluatePostcodeRisk().await().get()
        XCTAssertEqual(receivedRisk, .high)
    }
    
    func testPostcodeEvaluationReturnsMediumWhenPostCodeIsMarkedAsMediumRisk() throws {
        postcode = "B44"
        riskyPostcodes = ["B44": .medium]
        try postcodeManager.evaluatePostcodeRisk().await().get()
        XCTAssertEqual(receivedRisk, .medium)
    }
    
    func testPostcodeEvaluationReturnsLowWhenPostCodeIsMarkedAsLowRisk() throws {
        postcode = "B44"
        riskyPostcodes = ["B44": .low]
        try postcodeManager.evaluatePostcodeRisk().await().get()
        XCTAssertEqual(receivedRisk, .low)
    }
    
    func testPostcodeEvaluationReturnsLowWhenPostCodeIsNotFetchedFromBackend() throws {
        postcode = "AR"
        riskyPostcodes = ["B44": .high]
        try postcodeManager.evaluatePostcodeRisk().await().get()
        XCTAssertEqual(receivedRisk, .low)
    }
    
    func testPostcodeEvaluationWorksWithLowerCaseUserPostcode() throws {
        postcode = "b44"
        riskyPostcodes = ["B44": .high]
        try postcodeManager.evaluatePostcodeRisk().await().get()
        XCTAssertEqual(receivedRisk, .high)
    }
}
