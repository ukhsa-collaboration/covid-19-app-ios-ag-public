//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation
import TestSupport
import XCTest
@testable import Domain

class VirologyTokenHousekeeperTests: XCTestCase {
    
    var deletedVirologyTestTokens: [VirologyTestTokens] = []
    
    override func setUp() {
        deletedVirologyTestTokens = []
    }
    
    private func createHousekeeper(tokens: [VirologyTestTokens]?,
                                   deletionPeriod: DayDuration,
                                   today: GregorianDay) -> VirologyTokenHousekeeper {
        VirologyTokenHousekeeper(
            getTokenDeletionPeriod: { deletionPeriod },
            getToday: { today },
            getTokens: { tokens },
            deleteToken: { self.deletedVirologyTestTokens.append($0) }
        )
    }
    
    // MARK: Housekeeper does nothing
    
    func testHousekeeperDoesNothingIfNoTokens() {
        let housekeeper = createHousekeeper(
            tokens: nil,
            deletionPeriod: 28,
            today: GregorianDay(year: 2021, month: 8, day: 16)
        )
        _ = housekeeper.executeHousekeeping()
        
        XCTAssertTrue(deletedVirologyTestTokens.isEmpty)
    }
    
    // MARK: Housekeeper throws out expired tokens
    
    func testHousekeeperThrowsOutSingleExpiredToken() {
        let tokens = [
            makeToken(for: GregorianDay(year: 2021, month: 8, day: 1)),
        ]
        
        let housekeeper = createHousekeeper(
            tokens: tokens,
            deletionPeriod: 28,
            today: GregorianDay(year: 2021, month: 8, day: 30)
        )
        
        _ = housekeeper.executeHousekeeping()
        
        XCTAssertEqual(deletedVirologyTestTokens.count, 1)
        
        XCTAssertEqual(deletedVirologyTestTokens[0].diagnosisKeySubmissionToken.value, tokens[0].diagnosisKeySubmissionToken.value)
    }
    
    func testHousekeeperThrowsOutMultipleExpiredTokens() {
        let tokens = [
            makeToken(for: GregorianDay(year: 2021, month: 8, day: 29)),
            makeToken(for: GregorianDay(year: 2021, month: 8, day: 13)),
            makeToken(for: GregorianDay(year: 2021, month: 8, day: 19)),
            makeToken(for: GregorianDay(year: 2021, month: 8, day: 3)),
            makeToken(for: GregorianDay(year: 2021, month: 8, day: 19)),
            makeToken(for: GregorianDay(year: 2021, month: 8, day: 7)),
            makeToken(for: GregorianDay(year: 2021, month: 8, day: 7)),
        ]
        
        let housekeeper = createHousekeeper(
            tokens: tokens,
            deletionPeriod: 14,
            today: GregorianDay(year: 2021, month: 8, day: 30)
        )
        
        _ = housekeeper.executeHousekeeping()
        
        XCTAssertEqual(deletedVirologyTestTokens.count, 4)
        
        XCTAssertEqual(deletedVirologyTestTokens[0].diagnosisKeySubmissionToken.value, tokens[1].diagnosisKeySubmissionToken.value)
        XCTAssertEqual(deletedVirologyTestTokens[1].diagnosisKeySubmissionToken.value, tokens[3].diagnosisKeySubmissionToken.value)
        XCTAssertEqual(deletedVirologyTestTokens[2].diagnosisKeySubmissionToken.value, tokens[5].diagnosisKeySubmissionToken.value)
        XCTAssertEqual(deletedVirologyTestTokens[3].diagnosisKeySubmissionToken.value, tokens[6].diagnosisKeySubmissionToken.value)
    }
    
    private func makeToken(for day: GregorianDay) -> VirologyTestTokens {
        VirologyTestTokens(
            pollingToken: PollingToken(value: UUID().uuidString),
            creationDay: day,
            diagnosisKeySubmissionToken: DiagnosisKeySubmissionToken(value: UUID().uuidString)
        )
    }
}
