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
    
    override func setUp() {
        currentDate = Date()
        client = MockHTTPClient()
        
        isolationContext = IsolationContext(
            isolationConfiguration: CachedResponse(
                httpClient: client,
                endpoint: IsolationConfigurationEndpoint(),
                storage: FileStorage(forCachesOf: .random()),
                name: "isolation_configuration",
                initialValue: IsolationConfiguration(
                    maxIsolation: 21,
                    contactCase: 14,
                    indexCaseSinceSelfDiagnosisOnset: 8,
                    indexCaseSinceSelfDiagnosisUnknownOnset: 9,
                    housekeepingDeletionPeriod: 14
                )
            ),
            encryptedStore: MockEncryptedStore(),
            notificationCenter: NotificationCenter(),
            currentDateProvider: MockDateProvider { self.currentDate }
        )
    }
    
    func testMakeIsolationAcknowledgementStatePublishesState() throws {
        let isolation = Isolation(fromDay: .today, untilStartOfDay: .today, reason: .bothCases(hasPositiveTestResult: false, isSelfDiagnosed: true))
        isolationContext.isolationStateManager.state = .isolationFinishedButNotAcknowledged(isolation)
        
        let ackState = try isolationContext.makeIsolationAcknowledgementState().await().get()
        
        guard case .neededForEnd(isolation, _) = ackState else {
            throw TestError("Unexpected state \(ackState)")
        }
    }
    
    func testMakeBackgroundJobs() throws {
        let backgroundJobs = isolationContext.makeBackgroundJobs(
            metricsFrequency: 1.0,
            housekeepingFrequenzy: 1.0
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
    
}
