//
// Copyright © 2020 NHSX. All rights reserved.
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
            
            var checkInsStore = NoOpRiskyCheckinsProvider()
            
            var handleContactCase: (RiskInfo) -> Void = { _ in }
        }
        
        let circuitBreaker: CircuitBreaker
        
        init(configuration: Configuration) {
            circuitBreaker = CircuitBreaker(
                client: configuration.client,
                exposureInfoProvider: configuration.store,
                riskyCheckinsProvider: configuration.checkInsStore,
                handleContactCase: configuration.handleContactCase
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
    
    private func processPendingApprovals() throws {
        _ = try circuitBreaker.processPendingApprovals().prepend(()).await(timeout: 0.001)
    }
    
    func testApprovalEndpointNotCalledIfRiskScoreDoesNotExist() throws {
        try processPendingApprovals()
        XCTAssertNil(client.approvalType)
    }
    
    func testApprovalTokenIsStoredIfRiskScoreExistsAndRespondIsPending() throws {
        store.save(riskInfo: RiskInfo(riskScore: 7.5, day: .init(year: 2020, month: 5, day: 5)))
        let approvalTokenString = CircuitBreakerApprovalToken(.random())
        
        client.approvalResponse = .init(approvalToken: approvalTokenString, approval: .pending)
        try processPendingApprovals()
        XCTAssertEqual(store.exposureInfo?.approvalToken, approvalTokenString)
    }
    
    func testRiskIsClearedIsNotStoredIfRiskScoreExistsAndRespondIsYes() throws {
        store.save(riskInfo: RiskInfo(riskScore: 7.5, day: .init(year: 2020, month: 5, day: 5)))
        let approvalTokenString = CircuitBreakerApprovalToken(.random())
        
        client.approvalResponse = .init(approvalToken: approvalTokenString, approval: .yes)
        try processPendingApprovals()
        XCTAssertNil(store.exposureInfo)
    }
    
    func testRiskIsClearedIsNotStoredIfRiskScoreExistsAndRespondIsNo() throws {
        store.save(riskInfo: RiskInfo(riskScore: 7.5, day: .init(year: 2020, month: 5, day: 5)))
        let approvalTokenString = CircuitBreakerApprovalToken(.random())
        
        client.approvalResponse = .init(approvalToken: approvalTokenString, approval: .no)
        try processPendingApprovals()
        XCTAssertNil(store.exposureInfo)
    }
    
    func testResolutionEndpointIsCalledIfApprovalTokenExists() throws {
        let riskInfo = RiskInfo(riskScore: 7.5, day: .init(year: 2020, month: 5, day: 5))
        store.exposureInfo = ExposureInfo(approvalToken: .init(UUID().uuidString), riskInfo: riskInfo)
        try processPendingApprovals()
        XCTAssertNotNil(client.resolutionRequest)
    }
    
    func testSecondCircuitBreakerCheckCallsResolutionEndpointIfApprovalIsPending() throws {
        store.save(riskInfo: RiskInfo(riskScore: 7.5, day: .init(year: 2020, month: 5, day: 5)))
        
        client.approvalResponse = .init(approvalToken: .init(UUID().uuidString), approval: .pending)
        try processPendingApprovals()
        XCTAssertNil(client.resolutionRequest)
        
        try processPendingApprovals()
        XCTAssertNotNil(client.resolutionRequest)
    }
    
    func testSecondCircuitBreakerCheckCallsResolutionEndpointIfApprovalIsYes() throws {
        let riskInfo = RiskInfo(riskScore: 7.5, day: .init(year: 2020, month: 5, day: 5))
        store.save(riskInfo: riskInfo)
        
        client.approvalResponse = .init(approvalToken: .init(UUID().uuidString), approval: .yes)
        try processPendingApprovals()
        
        client.approvalResponse = nil
        
        try processPendingApprovals()
        XCTAssertEqual(client.approvalType, .exposureNotification(riskInfo))
    }
    
    func testSecondCircuitBreakerCheckCallsResolutionEndpointIfApprovalIsNo() throws {
        let riskInfo = RiskInfo(riskScore: 7.5, day: .init(year: 2020, month: 5, day: 5))
        store.save(riskInfo: riskInfo)
        
        client.approvalResponse = .init(approvalToken: .init(UUID().uuidString), approval: .no)
        try processPendingApprovals()
        
        client.approvalResponse = nil
        
        try processPendingApprovals()
        XCTAssertEqual(client.approvalType, .exposureNotification(riskInfo))
    }
    
    func testThirdCircuitBreakerCheckCallsResolutionEndpointIfApprovalIsStillPending() throws {
        store.save(riskInfo: RiskInfo(riskScore: 7.5, day: .init(year: 2020, month: 5, day: 5)))
        
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
        
        let riskInfo = RiskInfo(riskScore: 7.5, day: .init(year: 2020, month: 5, day: 5))
        store.exposureInfo = ExposureInfo(approvalToken: nil, riskInfo: riskInfo)
        XCTAssertFalse(handledContactCase)
        
        client.approvalResponse = .init(approvalToken: .init(UUID().uuidString), approval: .yes)
        XCTAssertFalse(handledContactCase)
        
        let cancellable = circuitBreaker.processPendingApprovals().sink { _ in }
        defer { cancellable.cancel() }
        
        XCTAssertTrue(handledContactCase)
        XCTAssertNil(store.exposureInfo)
    }
}
