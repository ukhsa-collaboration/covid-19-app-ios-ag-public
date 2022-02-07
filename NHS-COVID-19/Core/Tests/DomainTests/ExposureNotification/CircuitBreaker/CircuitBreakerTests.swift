//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Scenarios
import TestSupport
import XCTest
@testable import Domain

class CircuitBreakerTests: XCTestCase {
    typealias ApprovalEndpoint = CircuitBreakerClient.ApprovalEndpoint
    typealias ResolutionEndpoint = CircuitBreakerClient.ResolutionEndpoint
    typealias ApprovalToken = CircuitBreakerClient.ApprovalToken
    
    struct Instance: TestProp {
        struct Configuration: TestPropConfiguration {
            var encryptedStore = MockEncryptedStore()
            var client = MockCircuitBreakerClient()
            var store: ExposureDetectionStore {
                ExposureDetectionStore(store: encryptedStore)
            }
            
            fileprivate var checkInsStore = NoOpRiskyCheckinsProvider()
            
            var handleContactCase: (RiskInfo) -> Void = { _ in }
            var handleDontWorryNotification: () -> Void = {}
            var exposureNotificationProcessingBehaviour: () -> ExposureNotificationProcessingBehaviour = { .allExposures }
        }
        
        let circuitBreaker: CircuitBreaker
        
        init(configuration: Configuration) {
            circuitBreaker = CircuitBreaker(
                client: configuration.client,
                exposureInfoProvider: configuration.store,
                riskyCheckinsProvider: configuration.checkInsStore,
                currentDateProvider: MockDateProvider { DateComponents(calendar: .gregorian, timeZone: .utc, year: 2020, month: 5, day: 8).date! },
                contactCaseIsolationDuration: DayDuration(11),
                handleContactCase: configuration.handleContactCase,
                handleDontWorryNotification: configuration.handleDontWorryNotification,
                exposureNotificationProcessingBehaviour: configuration.exposureNotificationProcessingBehaviour
            )
        }
    }
    
    @Propped
    private var instance: Instance
    private var store: ExposureDetectionStore { $instance.store }
    private var circuitBreaker: CircuitBreaker { instance.circuitBreaker }
    private var client: MockCircuitBreakerClient { $instance.client }
    private var handleContactCase: (RiskInfo) -> Void {
        get { $instance.handleContactCase }
        set { $instance.handleContactCase = newValue }
    }
    
    private var handleDontWorryNotification: () -> Void {
        get { $instance.handleDontWorryNotification }
        set { $instance.handleDontWorryNotification = newValue }
    }
    
    private func processPendingApprovals() throws {
        _ = try circuitBreaker.processPendingApprovals().prepend(()).await(timeout: 0.001)
    }
    
    func testApprovalEndpointNotCalledIfRiskScoreDoesNotExist() throws {
        try processPendingApprovals()
        XCTAssertNil(client.approvalType)
    }
    
    func testApprovalEndpointNotCalledAndRiskClearedIfNotInterestedInEN() throws {
        $instance.exposureNotificationProcessingBehaviour = { .doNotProcessExposures }
        store.save(riskInfo: RiskInfo(riskScore: 7.5, riskScoreVersion: 1, day: .init(year: 2020, month: 5, day: 5)))
        try processPendingApprovals()
        XCTAssertNil(client.approvalType)
        XCTAssertNil(store.exposureInfo)
    }
    
    func testApprovalEndpointShowsDontWorryAlertIfAskedToWhenDroppingRisks() throws {
        $instance.exposureNotificationProcessingBehaviour = { .doNotProcessExposures }
        store.save(riskInfo: RiskInfo(riskScore: 7.5, riskScoreVersion: 1, day: .init(year: 2020, month: 5, day: 5)))
        
        var handledDontWorryNotification = false
        handleDontWorryNotification = { handledDontWorryNotification = true }
        circuitBreaker.showDontWorryNotificationIfNeeded = true
        
        try processPendingApprovals()
        XCTAssertTrue(handledDontWorryNotification)
    }
    
    func testApprovalTokenIsStoredIfRiskScoreExistsAndRespondIsPending() throws {
        store.save(riskInfo: RiskInfo(riskScore: 7.5, riskScoreVersion: 1, day: .init(year: 2020, month: 5, day: 5)))
        let approvalTokenString = CircuitBreakerApprovalToken(.random())
        
        client.approvalResponse = .init(approvalToken: approvalTokenString, approval: .pending)
        try processPendingApprovals()
        XCTAssertEqual(store.exposureInfo?.approvalToken, approvalTokenString)
    }
    
    func testRiskIsClearedIsNotStoredIfRiskScoreExistsAndRespondIsYes() throws {
        store.save(riskInfo: RiskInfo(riskScore: 7.5, riskScoreVersion: 1, day: .init(year: 2020, month: 5, day: 5)))
        let approvalTokenString = CircuitBreakerApprovalToken(.random())
        
        client.approvalResponse = .init(approvalToken: approvalTokenString, approval: .yes)
        try processPendingApprovals()
        XCTAssertNil(store.exposureInfo)
    }
    
    func testRiskIsClearedIsNotStoredIfRiskScoreExistsAndRespondIsNo() throws {
        store.save(riskInfo: RiskInfo(riskScore: 7.5, riskScoreVersion: 1, day: .init(year: 2020, month: 5, day: 5)))
        let approvalTokenString = CircuitBreakerApprovalToken(.random())
        
        client.approvalResponse = .init(approvalToken: approvalTokenString, approval: .no)
        try processPendingApprovals()
        XCTAssertNil(store.exposureInfo)
    }
    
    func testResolutionEndpointIsCalledIfApprovalTokenExists() throws {
        let riskInfo = RiskInfo(riskScore: 7.5, riskScoreVersion: 1, day: .init(year: 2020, month: 5, day: 5))
        store.exposureInfo = ExposureInfo(approvalToken: .init(UUID().uuidString), riskInfo: riskInfo)
        try processPendingApprovals()
        XCTAssertNotNil(client.resolutionRequest)
    }
    
    func testSecondCircuitBreakerCheckCallsResolutionEndpointIfApprovalIsPending() throws {
        store.save(riskInfo: RiskInfo(riskScore: 7.5, riskScoreVersion: 1, day: .init(year: 2020, month: 5, day: 5)))
        
        client.approvalResponse = .init(approvalToken: .init(UUID().uuidString), approval: .pending)
        try processPendingApprovals()
        XCTAssertNil(client.resolutionRequest)
        
        try processPendingApprovals()
        XCTAssertNotNil(client.resolutionRequest)
    }
    
    func testSecondCircuitBreakerCheckCallsResolutionEndpointIfApprovalIsYes() throws {
        let riskInfo = RiskInfo(riskScore: 7.5, riskScoreVersion: 1, day: .init(year: 2020, month: 5, day: 5))
        store.save(riskInfo: riskInfo)
        
        client.approvalResponse = .init(approvalToken: .init(UUID().uuidString), approval: .yes)
        try processPendingApprovals()
        
        client.approvalResponse = nil
        
        try processPendingApprovals()
        XCTAssertEqual(client.approvalType, .exposureNotification(riskInfo))
    }
    
    func testSecondCircuitBreakerCheckCallsResolutionEndpointIfApprovalIsNo() throws {
        let riskInfo = RiskInfo(riskScore: 7.5, riskScoreVersion: 1, day: .init(year: 2020, month: 5, day: 5))
        store.save(riskInfo: riskInfo)
        
        client.approvalResponse = .init(approvalToken: .init(UUID().uuidString), approval: .no)
        try processPendingApprovals()
        
        client.approvalResponse = nil
        
        try processPendingApprovals()
        XCTAssertEqual(client.approvalType, .exposureNotification(riskInfo))
    }
    
    func testThirdCircuitBreakerCheckCallsResolutionEndpointIfApprovalIsStillPending() throws {
        store.save(riskInfo: RiskInfo(riskScore: 7.5, riskScoreVersion: 1, day: .init(year: 2020, month: 5, day: 5)))
        
        client.approvalResponse = .init(approvalToken: .init(UUID().uuidString), approval: .pending)
        try processPendingApprovals()
        
        client.resolutionResponse = .init(approval: .pending)
        try processPendingApprovals()
        
        client.resolutionResponse = nil
        try processPendingApprovals()
        
        XCTAssertNotNil(client.resolutionRequest)
    }
    
    func testHasRiskScoreAndImmediateApprovalNotifiesOfRisk() {
        var handledContactCase = false
        handleContactCase = { _ in handledContactCase = true }
        
        XCTAssertFalse(handledContactCase)
        
        let riskInfo = RiskInfo(riskScore: 7.5, riskScoreVersion: 1, day: .init(year: 2020, month: 5, day: 5))
        store.exposureInfo = ExposureInfo(approvalToken: nil, riskInfo: riskInfo)
        XCTAssertFalse(handledContactCase)
        
        client.approvalResponse = .init(approvalToken: .init(UUID().uuidString), approval: .yes)
        XCTAssertFalse(handledContactCase)
        
        let cancellable = circuitBreaker.processPendingApprovals().sink { _ in }
        defer { cancellable.cancel() }
        
        XCTAssertTrue(handledContactCase)
        XCTAssertNil(store.exposureInfo)
    }
    
    func testNoDontWorryNotificationWithApprovalYes() throws {
        let riskInfo = RiskInfo(riskScore: 7.5, riskScoreVersion: 1, day: .init(year: 2020, month: 5, day: 5))
        store.exposureInfo = ExposureInfo(approvalToken: nil, riskInfo: riskInfo)
        
        var handledDontWorryNotification = false
        handleDontWorryNotification = { handledDontWorryNotification = true }
        circuitBreaker.showDontWorryNotificationIfNeeded = true
        
        XCTAssertFalse(handledDontWorryNotification)
        
        client.approvalResponse = .init(approvalToken: .init(UUID().uuidString), approval: .yes)
        try processPendingApprovals()
        
        XCTAssertFalse(handledDontWorryNotification)
    }
    
    func testShowDontWorryNotificationWithApprovalPending() throws {
        let riskInfo = RiskInfo(riskScore: 7.5, riskScoreVersion: 1, day: .init(year: 2020, month: 5, day: 5))
        store.exposureInfo = ExposureInfo(approvalToken: nil, riskInfo: riskInfo)
        
        var handledDontWorryNotification = false
        handleDontWorryNotification = { handledDontWorryNotification = true }
        circuitBreaker.showDontWorryNotificationIfNeeded = true
        
        XCTAssertFalse(handledDontWorryNotification)
        
        client.approvalResponse = .init(approvalToken: .init(UUID().uuidString), approval: .pending)
        try processPendingApprovals()
        
        XCTAssertTrue(handledDontWorryNotification)
    }
    
    func testShowDontWorryNotificationWithApprovalNo() throws {
        let riskInfo = RiskInfo(riskScore: 7.5, riskScoreVersion: 1, day: .init(year: 2020, month: 5, day: 5))
        store.exposureInfo = ExposureInfo(approvalToken: nil, riskInfo: riskInfo)
        
        var handledDontWorryNotification = false
        handleDontWorryNotification = { handledDontWorryNotification = true }
        circuitBreaker.showDontWorryNotificationIfNeeded = true
        
        XCTAssertFalse(handledDontWorryNotification)
        
        client.approvalResponse = .init(approvalToken: .init(UUID().uuidString), approval: .no)
        try processPendingApprovals()
        
        XCTAssertTrue(handledDontWorryNotification)
    }
    
    func testShowDontWorryNotificationWithApprovalPendingDoNotShow() throws {
        let riskInfo = RiskInfo(riskScore: 7.5, riskScoreVersion: 1, day: .init(year: 2020, month: 5, day: 5))
        store.exposureInfo = ExposureInfo(approvalToken: nil, riskInfo: riskInfo)
        
        var handledDontWorryNotification = false
        handleDontWorryNotification = { handledDontWorryNotification = true }
        circuitBreaker.showDontWorryNotificationIfNeeded = false
        
        XCTAssertFalse(handledDontWorryNotification)
        
        client.approvalResponse = .init(approvalToken: .init(UUID().uuidString), approval: .pending)
        try processPendingApprovals()
        
        XCTAssertFalse(handledDontWorryNotification)
    }
    
    func testShowDontWorryNotificationWithApprovalNoDoNotShow() throws {
        let riskInfo = RiskInfo(riskScore: 7.5, riskScoreVersion: 1, day: .init(year: 2020, month: 5, day: 5))
        store.exposureInfo = ExposureInfo(approvalToken: nil, riskInfo: riskInfo)
        
        var handledDontWorryNotification = false
        handleDontWorryNotification = { handledDontWorryNotification = true }
        circuitBreaker.showDontWorryNotificationIfNeeded = false
        
        XCTAssertFalse(handledDontWorryNotification)
        
        client.approvalResponse = .init(approvalToken: .init(UUID().uuidString), approval: .no)
        try processPendingApprovals()
        
        XCTAssertFalse(handledDontWorryNotification)
    }
    
    func testShowDontWorryNotificationWithError() throws {
        let riskInfo = RiskInfo(riskScore: 7.5, riskScoreVersion: 1, day: .init(year: 2020, month: 5, day: 5))
        store.exposureInfo = ExposureInfo(approvalToken: nil, riskInfo: riskInfo)
        
        var handledDontWorryNotification = false
        handleDontWorryNotification = { handledDontWorryNotification = true }
        circuitBreaker.showDontWorryNotificationIfNeeded = true
        
        XCTAssertFalse(handledDontWorryNotification)
        
        client.shouldShowError = true
        try processPendingApprovals()
        
        XCTAssertTrue(handledDontWorryNotification)
    }
    
    /// Asserts that `store.exposureInfo` is not thrown away if there is an error from the circuit
    /// breaker, and that the exposure is handled later.
    func testRetainsRiskyExposuresIfCallFailed() throws {
        let handledContactCaseExpectation = expectation(description: "contact case passed off for handling")
        handleContactCase = { _ in handledContactCaseExpectation.fulfill() }
        
        let riskInfo = RiskInfo(riskScore: 7.5, riskScoreVersion: 1, day: .init(year: 2020, month: 5, day: 5))
        store.exposureInfo = ExposureInfo(approvalToken: nil, riskInfo: riskInfo)
        
        client.shouldShowError = true
        try processPendingApprovals()
        XCTAssertEqual(store.exposureInfo?.riskInfo, riskInfo)
        
        client.shouldShowError = false
        client.approvalResponse = .init(approvalToken: CircuitBreakerApprovalToken(.random()), approval: .yes)
        try processPendingApprovals()
        XCTAssertNil(store.exposureInfo)
        
        waitForExpectations(timeout: 1)
    }
    
    func testShowDontWorryNotificationWithErrorDoNotShow() throws {
        let riskInfo = RiskInfo(riskScore: 7.5, riskScoreVersion: 1, day: .init(year: 2020, month: 5, day: 5))
        store.exposureInfo = ExposureInfo(approvalToken: nil, riskInfo: riskInfo)
        
        var handledDontWorryNotification = false
        handleDontWorryNotification = { handledDontWorryNotification = true }
        circuitBreaker.showDontWorryNotificationIfNeeded = false
        
        XCTAssertFalse(handledDontWorryNotification)
        
        client.shouldShowError = true
        try processPendingApprovals()
        
        XCTAssertFalse(handledDontWorryNotification)
    }
    
    func testNotifiesForNonExpiredIsolation() throws {
        let handledContactCaseExpectation = expectation(description: "contact case passed off for handling")
        handleContactCase = { _ in handledContactCaseExpectation.fulfill() }
        
        store.save(riskInfo: RiskInfo(riskScore: 7.5, riskScoreVersion: 2, day: .init(year: 2020, month: 4, day: 28)))
        let approvalTokenString = CircuitBreakerApprovalToken(.random())
        
        client.approvalResponse = .init(approvalToken: approvalTokenString, approval: .yes)
        try processPendingApprovals()
        
        waitForExpectations(timeout: 1)
    }
    
    func testDoesNotNotifyForExpiredIsolation() throws {
        var handledContactCase = false
        handleContactCase = { _ in handledContactCase = true }
        
        store.save(riskInfo: RiskInfo(riskScore: 7.5, riskScoreVersion: 2, day: .init(year: 2020, month: 4, day: 27)))
        let approvalTokenString = CircuitBreakerApprovalToken(.random())
        
        client.approvalResponse = .init(approvalToken: approvalTokenString, approval: .yes)
        try processPendingApprovals()
        XCTAssertFalse(handledContactCase)
    }
}

private class NoOpRiskyCheckinsProvider: RiskyCheckinsProvider {
    var riskyCheckIns = [CheckIn]()
    var riskApprovalTokens = [String: CircuitBreakerApprovalToken]()
    func set(_ approval: CircuitBreakerApproval, for venueId: String) {}
}
