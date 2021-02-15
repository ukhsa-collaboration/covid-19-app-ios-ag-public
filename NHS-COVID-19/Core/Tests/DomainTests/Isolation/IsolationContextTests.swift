//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Scenarios
import TestSupport
import XCTest
@testable import Domain

class IsolationContextTests: XCTestCase {
    private var isolationContext: IsolationContext!
    private var currentDate: Date!
    private var client: MockHTTPClient!
    private var removedNotificaton = false
    
    override func setUp() {
        currentDate = Date()
        client = MockHTTPClient()
        
        isolationContext = IsolationContext(
            isolationConfiguration: CachedResponse(
                httpClient: client,
                endpoint: IsolationConfigurationEndpoint(),
                storage: FileStorage(forNewCachesOf: .random()),
                name: "isolation_configuration",
                initialValue: IsolationConfiguration(
                    maxIsolation: 21,
                    contactCase: 14,
                    indexCaseSinceSelfDiagnosisOnset: 8,
                    indexCaseSinceSelfDiagnosisUnknownOnset: 9,
                    housekeepingDeletionPeriod: 14,
                    indexCaseSinceNPEXDayNoSelfDiagnosis: IsolationConfiguration.default.indexCaseSinceNPEXDayNoSelfDiagnosis
                )
            ),
            encryptedStore: MockEncryptedStore(),
            notificationCenter: NotificationCenter(),
            currentDateProvider: MockDateProvider { self.currentDate },
            removeExposureDetectionNotifications: { self.removedNotificaton = true }
        )
    }
    
    func testMakeIsolationAcknowledgementStatePublishesState() throws {
        let isolation = Isolation(fromDay: .today, untilStartOfDay: .today, reason: Isolation.Reason(indexCaseInfo: IsolationIndexCaseInfo(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false), isContactCase: true))
        isolationContext.isolationStateManager.state = .isolationFinishedButNotAcknowledged(isolation)
        
        let ackState = try isolationContext.makeIsolationAcknowledgementState().await().get()
        
        guard case .neededForEnd(isolation, _) = ackState else {
            throw TestError("Unexpected state \(ackState)")
        }
    }
    
    func testMakeBackgroundJobs() throws {
        let backgroundJobs = isolationContext.makeBackgroundJobs(
            metricsFrequency: 1.0,
            housekeepingFrequency: 1.0
        )
        
        XCTAssertEqual(backgroundJobs.count, 3)
        
        client.response = Result.success(.ok(with: .json("""
        {
          "durationDays": {
            "indexCaseSinceSelfDiagnosisOnset": 1,
            "indexCaseSinceSelfDiagnosisUnknownOnset": 2,
            "contactCase": 3,
            "maxIsolation": 4
          }
        }
        
        """)))
        
        try backgroundJobs.forEach { job in
            try job.work().await().get()
        }
        
        let request = try XCTUnwrap(client.lastRequest)
        let expectedRequest = try IsolationConfigurationEndpoint().request(for: ())
        XCTAssertEqual(request, expectedRequest)
    }
    
    func testRemoveExposureDetectionNotificationOnContactCaseAcknowledgement() throws {
        let isolation = Isolation(fromDay: .today, untilStartOfDay: .today, reason: .init(indexCaseInfo: nil, isContactCase: true))
        isolationContext.isolationStateManager.state = .isolating(isolation, endAcknowledged: false, startAcknowledged: false)
        
        let ackState = try isolationContext.makeIsolationAcknowledgementState().await().get()
        
        if case .neededForStart(isolation, acknowledge: let ack) = ackState {
            ack()
            
            XCTAssertTrue(removedNotificaton)
        }
    }
    
    // The notification should only be removed if a user acknowledges his isolation due to a risky contact
    // This is currently only possible as contact case only.
    // Revisit this test after changing the logic when to show the "isolate due to risky contact" screen
    func testDoNotRemoveExposureDetectionNotificationOnBothCases() throws {
        let isolation = Isolation(
            fromDay: .today,
            untilStartOfDay: .today,
            reason: .init(
                indexCaseInfo: .init(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false),
                isContactCase: false
            )
        )
        isolationContext.isolationStateManager.state = .isolating(isolation, endAcknowledged: false, startAcknowledged: false)
        
        let ackState = try isolationContext.makeIsolationAcknowledgementState().await().get()
        
        if case .neededForStart(isolation, acknowledge: let ack) = ackState {
            ack()
            XCTAssertFalse(removedNotificaton)
        }
    }
    
    // The notification should only be removed if a user acknowledges his isolation due to a risky contact
    // This is currently only possible as contact case only.
    // Revisit this test after changing the logic when to show the "isolate due to risky contact" screen
    func testDoNotRemoveExposureDetectionNotificationOnIndexCase() throws {
        let isolation = Isolation(
            fromDay: .today,
            untilStartOfDay: .today,
            reason: .init(
                indexCaseInfo: .init(hasPositiveTestResult: false, testKitType: nil, isSelfDiagnosed: true, isPendingConfirmation: false),
                isContactCase: false
            )
        )
        isolationContext.isolationStateManager.state = .isolating(isolation, endAcknowledged: false, startAcknowledged: false)
        
        let ackState = try isolationContext.makeIsolationAcknowledgementState().await().get()
        
        if case .neededForStart(isolation, acknowledge: let ack) = ackState {
            ack()
            XCTAssertFalse(removedNotificaton)
        }
    }
    
}
