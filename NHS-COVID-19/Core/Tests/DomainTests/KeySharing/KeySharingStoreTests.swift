//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Scenarios
import TestSupport
import XCTest
@testable import Domain

class KeySharingStoreTests: XCTestCase {
    
    private var encryptedStore: MockEncryptedStore!
    
    override func setUp() {
        super.setUp()
        
        encryptedStore = MockEncryptedStore()
    }
    
    func testEmptyStore() throws {
        let store = KeySharingStore(store: encryptedStore)
        XCTAssertEqual(store.state.currentValue, .empty)
    }
    
    func testLoadingKeySharingInfoBeforeFinishingInitialFlow() throws {
        let ackTime = UTCHour(day: GregorianDay(year: 2020, month: 5, day: 15), hour: 7)
        let expected = KeySharingInfo(
            diagnosisKeySubmissionToken: .init(value: .random()),
            testResultAcknowledgmentTime: ackTime,
            hasFinishedInitialKeySharingFlow: false,
            hasTriggeredReminderNotification: false
        )
        encryptedStore.stored["key_sharing"] = Data(#"""
        {
            "keySharingInfo": {
                "diagnosisKeySubmissionToken": "\#(expected.diagnosisKeySubmissionToken.value)",
                "testResultAcknowledgmentTime": {
                        "day" : {
                            "year" : 2020,
                            "month" : 5,
                            "day" : 15
                        },
                        "hour" : 7,
                        "minutes": 0
                    },
                "hasFinishedInitialKeySharingFlow": false,
                "hasTriggeredReminderNotification": false
            }
        }
        """# .utf8)
        let store = KeySharingStore(store: encryptedStore)
        TS.assert(store.info.currentValue, equals: expected)
    }
    
    func testLoadingKeySharingInfoAfterFinishingInitialFlow() throws {
        let ackTime = UTCHour(day: GregorianDay(year: 2020, month: 5, day: 15), hour: 7)
        let expected = KeySharingInfo(
            diagnosisKeySubmissionToken: .init(value: .random()),
            testResultAcknowledgmentTime: ackTime,
            hasFinishedInitialKeySharingFlow: true,
            hasTriggeredReminderNotification: true
        )
        encryptedStore.stored["key_sharing"] = Data(#"""
        {
            "keySharingInfo": {
                "diagnosisKeySubmissionToken": "\#(expected.diagnosisKeySubmissionToken.value)",
                "testResultAcknowledgmentTime": {
                        "day" : {
                            "year" : 2020,
                            "month" : 5,
                            "day" : 15
                        },
                        "hour" : 7,
                        "minutes": 0
                    },
                "hasFinishedInitialKeySharingFlow": true,
                "hasTriggeredReminderNotification": true,
            }
        }
        """# .utf8)
        let store = KeySharingStore(store: encryptedStore)
        TS.assert(store.info.currentValue, equals: expected)
    }
    
    func testSaveToken() throws {
        let token = DiagnosisKeySubmissionToken(value: UUID().uuidString)
        let store = KeySharingStore(store: encryptedStore)
        
        let ackTime = UTCHour(day: GregorianDay(year: 2020, month: 12, day: 31), hour: 1)
        
        store.save(token: token, acknowledgmentTime: ackTime)
        XCTAssertEqual(store.state.currentValue, .hasNotReminded(token: token.value, time: ackTime))
    }
    
    func testDidRemindToSubmitKeys() {
        let store = KeySharingStore(store: encryptedStore)
        
        let token = UUID().uuidString
        let ackTime = UTCHour(containing: Date())
        store.save(token: DiagnosisKeySubmissionToken(value: token), acknowledgmentTime: ackTime)
        XCTAssertEqual(store.state.currentValue, .hasNotReminded(token: token, time: ackTime))
        
        store.didFinishInitialKeySharingFlow()
        XCTAssertEqual(store.state.currentValue, .hasReminded(token: token, time: ackTime))
    }
    
    func testResetStore() {
        let store = KeySharingStore(store: encryptedStore)
        
        let token = UUID().uuidString
        let ackTime = UTCHour(containing: Date())
        store.save(token: DiagnosisKeySubmissionToken(value: token), acknowledgmentTime: ackTime)
        XCTAssertEqual(store.state.currentValue, .hasNotReminded(token: token, time: ackTime))
        
        store.reset()
        XCTAssertEqual(store.state.currentValue, .empty)
    }
    
    func testTokenCanBeOverwritten() {
        let store = KeySharingStore(store: encryptedStore)
        
        let token1 = UUID().uuidString
        let date1 = UTCHour(day: GregorianDay(year: 2020, month: 12, day: 31), hour: 1)
        store.save(token: DiagnosisKeySubmissionToken(value: token1), acknowledgmentTime: date1)
        XCTAssertEqual(store.state.currentValue, .hasNotReminded(token: token1, time: date1))
        
        let token2 = UUID().uuidString
        let date2 = UTCHour(day: GregorianDay(year: 2020, month: 12, day: 31), hour: 1)
        store.save(token: DiagnosisKeySubmissionToken(value: token2), acknowledgmentTime: date2)
        XCTAssertEqual(store.state.currentValue, .hasNotReminded(token: token2, time: date2))
    }
    
    func testDidTriggerReminderNotificationToSubmitKeys() {
        let store = KeySharingStore(store: encryptedStore)
        
        let token = UUID().uuidString
        let ackTime = UTCHour(containing: Date())
        store.save(token: DiagnosisKeySubmissionToken(value: token), acknowledgmentTime: ackTime)
        XCTAssertEqual(store.state.currentValue, .hasNotReminded(token: token, time: ackTime))
        
        store.didTriggerReminderNotification()
        XCTAssertTrue(store.info.currentValue!.hasTriggeredReminderNotification)
    }
}
