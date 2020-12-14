//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Scenarios
import TestSupport
import XCTest
@testable import Domain

class IsolationStateStoreTests: XCTestCase {
    struct Instance: TestProp {
        struct Configuration: TestPropConfiguration {
            var encryptedStore = MockEncryptedStore()
            var isolationInfo = IsolationInfo(indexCaseInfo: nil, contactCaseInfo: nil)
            var isolationConfiguration = IsolationConfiguration(
                maxIsolation: 21,
                contactCase: 14,
                indexCaseSinceSelfDiagnosisOnset: 8,
                indexCaseSinceSelfDiagnosisUnknownOnset: 9,
                housekeepingDeletionPeriod: 14
            )
            
            public init() {}
        }
        
        let store: IsolationStateStore
        
        init(configuration: Configuration) {
            store = IsolationStateStore(store: configuration.encryptedStore, latestConfiguration: { .default }, currentDateProvider: MockDateProvider())
        }
    }
    
    @Propped
    var instance: Instance
    
    var store: IsolationStateStore {
        instance.store
    }
    
    func testLoadingEmptyStore() throws {
        $instance.encryptedStore.stored["isolation_state_info"] = nil
        XCTAssertEqual(store.isolationInfo, IsolationInfo(indexCaseInfo: nil, contactCaseInfo: nil))
        TS.assert(store.configuration, equals: IsolationConfiguration.default)
    }
    
    func testLoadingEmptyIsolationStateInfo() {
        $instance.encryptedStore.stored["isolation_state_info"] = #"""
        {
            "configuration" : {
                "indexCaseSinceSelfDiagnosisOnset" : 7,
                "maxIsolation" : 21,
                "contactCase" : 14,
                "indexCaseSinceSelfDiagnosisUnknownOnset" : 5,
                "housekeepingDeletionPeriod" : 14
            },
            "isolationInfo" : {}
        }
        """# .data(using: .utf8)!
        
        TS.assert(store.isolationInfo, equals: IsolationInfo(indexCaseInfo: nil, contactCaseInfo: nil))
    }
    
    func testLoadingOldData() throws {
        $instance.encryptedStore.stored["isolation_state_info"] = #"""
        {
            "configuration" : {
                "indexCaseSinceSelfDiagnosisOnset" : 7,
                "maxIsolation" : 21,
                "contactCase" : 14,
                "indexCaseSinceSelfDiagnosisUnknownOnset" : 5,
                "housekeepingDeletionPeriod" : 14
            },
            "isolationInfo" : {
                "hasAcknowledgedEndOfIsolation": true,
                "hasAcknowledgedStartOfIsolation": false,
                "contactCaseInfo" : {
                    "exposureDay" : {
                        "day" : 11,
                        "month" : 7,
                        "year" : 2020
                    },
                    "isolationFromStartOfDay":{
                        "year": 2020,
                        "month": 7,
                        "day": 13
                    }
                },
                "indexCaseInfo" : {
                    "selfDiagnosisDay" : {
                        "day" : 12,
                        "month" : 7,
                        "year" : 2020
                    },
                    "onsetDay" : {
                        "day" : 10,
                        "month" : 7,
                        "year" : 2020
                    },
                    "testInfo": {
                        "result" : "positive",
                        "receivedOnDay" : {
                            "day" : 14,
                            "month" : 7,
                            "year" : 2020
                        }
                    }
                }
            }
        }
        """# .data(using: .utf8)!
        
        let onsetDay = GregorianDay(year: 2020, month: 7, day: 10)
        let exposureDay = GregorianDay(year: 2020, month: 7, day: 11)
        let selfDiagnosisDay = GregorianDay(year: 2020, month: 7, day: 12)
        let isolationFromStartOfDay = GregorianDay(year: 2020, month: 7, day: 13)
        let testReceivedDay = GregorianDay(year: 2020, month: 7, day: 14)
        
        let expectedIsolationInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: true,
            indexCaseInfo: IndexCaseInfo(
                isolationTrigger: .selfDiagnosis(selfDiagnosisDay),
                onsetDay: onsetDay,
                testInfo: IndexCaseInfo.TestInfo(result: .positive, receivedOnDay: testReceivedDay)
            ),
            contactCaseInfo: ContactCaseInfo(
                exposureDay: exposureDay,
                isolationFromStartOfDay: isolationFromStartOfDay,
                trigger: .exposureDetection
            )
        )
        
        TS.assert(store.isolationInfo, equals: expectedIsolationInfo)
    }
    
    func testLoadingNewData() throws {
        $instance.encryptedStore.stored["isolation_state_info"] = #"""
        {
            "configuration" : {
                "indexCaseSinceSelfDiagnosisOnset" : 7,
                "maxIsolation" : 21,
                "contactCase" : 14,
                "indexCaseSinceSelfDiagnosisUnknownOnset" : 5,
                "housekeepingDeletionPeriod" : 14
            },
            "isolationInfo" : {
                "hasAcknowledgedEndOfIsolation": true,
                "hasAcknowledgedStartOfIsolation": false,
                "contactCaseInfo" : {
                    "exposureDay" : {
                        "day" : 11,
                        "month" : 7,
                        "year" : 2020
                    },
                    "isolationFromStartOfDay":{
                        "year": 2020,
                        "month": 7,
                        "day": 13
                    },
                    "trigger": "exposureDetection"
                },
                "indexCaseInfo" : {
                    "selfDiagnosisDay" : {
                        "day" : 12,
                        "month" : 7,
                        "year" : 2020
                    },
                    "onsetDay" : {
                        "day" : 10,
                        "month" : 7,
                        "year" : 2020
                    },
                    "testInfo": {
                        "result" : "positive",
                        "receivedOnDay" : {
                            "day" : 14,
                            "month" : 7,
                            "year" : 2020
                        }
                    }
                }
            }
        }
        """# .data(using: .utf8)!
        
        let onsetDay = GregorianDay(year: 2020, month: 7, day: 10)
        let exposureDay = GregorianDay(year: 2020, month: 7, day: 11)
        let selfDiagnosisDay = GregorianDay(year: 2020, month: 7, day: 12)
        let isolationFromStartOfDay = GregorianDay(year: 2020, month: 7, day: 13)
        let testReceivedDay = GregorianDay(year: 2020, month: 7, day: 14)
        
        let expectedIsolationInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: true,
            indexCaseInfo: IndexCaseInfo(
                isolationTrigger: .selfDiagnosis(selfDiagnosisDay),
                onsetDay: onsetDay,
                testInfo: IndexCaseInfo.TestInfo(result: .positive, receivedOnDay: testReceivedDay)
            ),
            contactCaseInfo: ContactCaseInfo(
                exposureDay: exposureDay,
                isolationFromStartOfDay: isolationFromStartOfDay,
                trigger: .exposureDetection
            )
        )
        
        TS.assert(store.isolationInfo, equals: expectedIsolationInfo)
    }
    
    func testSavingEmptyIsolationStateInfo() throws {
        let onsetDay = GregorianDay(year: 2020, month: 7, day: 10)
        let exposureDay = GregorianDay(year: 2020, month: 7, day: 11)
        let selfDiagnosisDay = GregorianDay(year: 2020, month: 7, day: 12)
        let testReceivedDay = GregorianDay(year: 2020, month: 7, day: 14)
        
        let isolationInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: false,
            hasAcknowledgedStartOfIsolation: true,
            indexCaseInfo: IndexCaseInfo(
                isolationTrigger: .selfDiagnosis(selfDiagnosisDay),
                onsetDay: onsetDay,
                testInfo: IndexCaseInfo.TestInfo(result: .positive, receivedOnDay: testReceivedDay)
            ),
            contactCaseInfo: ContactCaseInfo(
                exposureDay: exposureDay,
                isolationFromStartOfDay: .today,
                trigger: .exposureDetection
            )
        )
        
        store.set(isolationInfo.indexCaseInfo!)
        store.set(isolationInfo.contactCaseInfo!)
        
        let storedData = try XCTUnwrap($instance.encryptedStore.stored["isolation_state_info"])
        let isolationStateInfo = try JSONDecoder().decode(IsolationStateInfo.self, from: storedData)
        
        XCTAssertEqual(isolationStateInfo.isolationInfo, isolationInfo)
    }
    
    func testStoreTestResult() throws {
        let selfDiagnosisDay = GregorianDay(year: 2020, month: 7, day: 12)
        let testDay = GregorianDay(year: 2020, month: 7, day: 13)
        let npexDay = GregorianDay(year: 2020, month: 7, day: 16)
        
        store.set(IndexCaseInfo(
            isolationTrigger: .selfDiagnosis(selfDiagnosisDay),
            onsetDay: nil,
            testInfo: nil
        ))
        
        store.isolationStateInfo = store.newIsolationStateInfo(for: .positive, receivedOn: testDay, npexDay: npexDay)
        
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.result, TestResult.positive)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.receivedOnDay, testDay)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.isolationTrigger.startDay, selfDiagnosisDay)
    }
    
    func testNotOverwritePositiveTestResult() throws {
        let selfDiagnosisDay = GregorianDay(year: 2020, month: 7, day: 12)
        let testDay = GregorianDay(year: 2020, month: 7, day: 13)
        
        store.set(IndexCaseInfo(
            isolationTrigger: .selfDiagnosis(selfDiagnosisDay),
            onsetDay: nil,
            testInfo: nil
        ))
        
        store.isolationStateInfo = store.newIsolationStateInfo(for: .positive, receivedOn: testDay, npexDay: GregorianDay(year: 2020, month: 7, day: 16))
        store.isolationStateInfo = store.newIsolationStateInfo(for: .negative, receivedOn: testDay, npexDay: GregorianDay(year: 2020, month: 7, day: 17))
        
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.result, TestResult.positive)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.receivedOnDay, testDay)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.isolationTrigger.startDay, selfDiagnosisDay)
    }
    
    func testNewTestResultShouldBeIgnoredWhenNewTestResultIsVoidAndPreviousTestResultIsNil() throws {
        let testDay = GregorianDay(year: 2020, month: 7, day: 16)
        
        // When
        store.isolationStateInfo = store.newIsolationStateInfo(
            for: .void,
            receivedOn: testDay,
            npexDay: testDay.advanced(by: -2)
        )
        
        // Then
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo, nil)
    }
    
    func testNewTestResultShouldBeIgnoredWhenNewTestResultIsVoidAndPreviousTestResultIsNegative() throws {
        let testDay = GregorianDay(year: 2020, month: 7, day: 16)
        
        // Given
        store.isolationStateInfo = store.newIsolationStateInfo(
            for: .negative,
            receivedOn: testDay,
            npexDay: GregorianDay(year: 2020, month: 7, day: 14)
        )
        
        // When
        store.isolationStateInfo = store.newIsolationStateInfo(
            for: .void,
            receivedOn: GregorianDay(year: 2020, month: 7, day: 20),
            npexDay: GregorianDay(year: 2020, month: 7, day: 18)
        )
        
        // Then
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.result, TestResult.negative)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.receivedOnDay, testDay)
    }
    
    func testNewTestResultShouldBeIgnoredWhenNewTestResultIsVoidAndPreviousTestResultIsVoid() throws {
        let testDay = GregorianDay(year: 2020, month: 7, day: 16)
        
        // Given
        store.set(IndexCaseInfo(
            isolationTrigger: .selfDiagnosis(testDay),
            onsetDay: nil,
            testInfo: IndexCaseInfo.TestInfo(result: .void, receivedOnDay: testDay)
        ))
        
        // When
        store.isolationStateInfo = store.newIsolationStateInfo(
            for: .void,
            receivedOn: testDay.advanced(by: 2),
            npexDay: GregorianDay(year: 2020, month: 7, day: 14)
        )
        
        // Then
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.result, TestResult.void)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.receivedOnDay, testDay)
    }
    
    func testNewTestResultShouldBeIgnoredWhenNewTestResultIsVoidAndPreviousTestResultIsPositive() throws {
        let testDay = GregorianDay(year: 2020, month: 7, day: 16)
        
        // Given
        store.set(IndexCaseInfo(
            isolationTrigger: .selfDiagnosis(testDay.advanced(by: -2)),
            onsetDay: nil,
            testInfo: IndexCaseInfo.TestInfo(result: .positive, receivedOnDay: testDay)
        ))
        
        // When
        store.isolationStateInfo = store.newIsolationStateInfo(
            for: .void,
            receivedOn: testDay.advanced(by: 2),
            npexDay: GregorianDay(year: 2020, month: 7, day: 14)
        )
        
        // Then
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.result, TestResult.positive)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.receivedOnDay, testDay)
    }
    
    func testNewTestResultShouldBeSavedWhenNewTestResultIsPositiveAndPreviousTestResultIsNegative() throws {
        let testReceivedDay = GregorianDay(year: 2020, month: 7, day: 16)
        let testReadyDay = GregorianDay(year: 2020, month: 7, day: 14)
        
        // Given
        store.set(IndexCaseInfo(
            isolationTrigger: .selfDiagnosis(testReceivedDay.advanced(by: -2)),
            onsetDay: nil,
            testInfo: IndexCaseInfo.TestInfo(result: .negative, receivedOnDay: testReceivedDay.advanced(by: -1))
        ))
        
        // When
        store.isolationStateInfo = store.newIsolationStateInfo(
            for: .positive,
            receivedOn: testReceivedDay,
            npexDay: testReadyDay
        )
        
        // Then
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.result, TestResult.positive)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.receivedOnDay, testReceivedDay)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.isolationTrigger.startDay, testReadyDay)
    }
    
    func testNewTestResultShouldBeIgnoredWhenNewTestResultIsPositiveAndPreviousTestResultIsPositive() throws {
        let testDay = GregorianDay(year: 2020, month: 7, day: 16)
        let selfDiagnosisDay = testDay.advanced(by: -6)
        
        // Given
        store.set(IndexCaseInfo(
            isolationTrigger: .manualTestEntry(npexDay: selfDiagnosisDay),
            onsetDay: nil,
            testInfo: IndexCaseInfo.TestInfo(result: .positive, receivedOnDay: testDay.advanced(by: -4))
        ))
        
        // When
        store.isolationStateInfo = store.newIsolationStateInfo(
            for: .positive,
            receivedOn: testDay,
            npexDay: testDay.advanced(by: -2)
        )
        
        // Then
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.result, TestResult.positive)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.receivedOnDay, testDay.advanced(by: -4))
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.isolationTrigger.startDay, selfDiagnosisDay)
    }
    
    func testNewTestResultShouldBeSavedWhenNewTestResultIsPositiveAndPreviousTestResultIsVoid() throws {
        let testDay = GregorianDay(year: 2020, month: 7, day: 16)
        let selfDiagnosisDay = testDay.advanced(by: -6)
        
        // Given
        store.set(IndexCaseInfo(
            isolationTrigger: .manualTestEntry(npexDay: selfDiagnosisDay),
            onsetDay: nil,
            testInfo: IndexCaseInfo.TestInfo(result: .void, receivedOnDay: testDay.advanced(by: -4))
        ))
        
        // When
        store.isolationStateInfo = store.newIsolationStateInfo(for: .positive, receivedOn: testDay, npexDay: testDay.advanced(by: -2))
        
        // Then
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.result, TestResult.positive)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.receivedOnDay, testDay)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.isolationTrigger.startDay, testDay.advanced(by: -2))
    }
    
    func testNewTestResultShouldBeSavedWhenNewTestResultIsPositiveAndPreviousTestResultIsNil() throws {
        let testDay = GregorianDay(year: 2020, month: 7, day: 16)
        let npexDay = testDay.advanced(by: -6)
        
        // When
        store.isolationStateInfo = store.newIsolationStateInfo(for: .positive, receivedOn: testDay, npexDay: npexDay)
        
        // Then
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.result, TestResult.positive)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.receivedOnDay, testDay)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.isolationTrigger.startDay, npexDay)
    }
    
    func testNewTestResultShouldBeIgnoredWhenNewTestResultIsNegativeAndPreviousTestResultIsNegative() throws {
        let testDay = GregorianDay(year: 2020, month: 7, day: 16)
        
        // Given
        store.isolationStateInfo = store.newIsolationStateInfo(
            for: .negative,
            receivedOn: testDay.advanced(by: -2),
            npexDay: testDay.advanced(by: -5)
        )
        
        // When
        store.isolationStateInfo = store.newIsolationStateInfo(
            for: .negative,
            receivedOn: testDay,
            npexDay: testDay.advanced(by: -1)
        )
        
        // Then
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.result, TestResult.negative)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.receivedOnDay, testDay)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.isolationTrigger.startDay, testDay.advanced(by: -5))
    }
    
    func testNewTestResultShouldBeSavedWhenNewTestResultIsNegativeAndPreviousTestResultIsVoid() throws {
        let testDay = GregorianDay(year: 2020, month: 7, day: 16)
        let npexDay = testDay.advanced(by: -6)
        
        // Given
        store.set(IndexCaseInfo(
            isolationTrigger: .manualTestEntry(npexDay: npexDay),
            onsetDay: nil,
            testInfo: IndexCaseInfo.TestInfo(result: .void, receivedOnDay: testDay.advanced(by: -4))
        ))
        
        // When
        store.isolationStateInfo = store.newIsolationStateInfo(
            for: .negative,
            receivedOn: testDay,
            npexDay: testDay.advanced(by: -1)
        )
        
        // Then
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.result, TestResult.negative)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.receivedOnDay, testDay)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.isolationTrigger.startDay, testDay.advanced(by: -1))
    }
    
    func testNewTestResultShouldBeIgnoredWhenNewTestResultIsNegativeAndPreviousTestResultIsPositive() throws {
        let testDay = GregorianDay(year: 2020, month: 7, day: 16)
        let npexDay = testDay.advanced(by: -6)
        
        // Given
        store.set(IndexCaseInfo(
            isolationTrigger: .selfDiagnosis(npexDay),
            onsetDay: nil,
            testInfo: IndexCaseInfo.TestInfo(result: .positive, receivedOnDay: testDay.advanced(by: -4))
        ))
        
        // When
        store.isolationStateInfo = store.newIsolationStateInfo(
            for: .negative,
            receivedOn: testDay,
            npexDay: testDay.advanced(by: -1)
        )
        
        // Then
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.result, TestResult.positive)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.receivedOnDay, testDay.advanced(by: -4))
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.isolationTrigger.startDay, npexDay)
        
    }
    
    func testNewTestResultShouldBeSavedWhenNewTestResultIsNegativeAndPreviousTestResultIsNil() throws {
        let testDay = GregorianDay(year: 2020, month: 7, day: 16)
        
        // When
        store.isolationStateInfo = store.newIsolationStateInfo(
            for: .negative,
            receivedOn: testDay,
            npexDay: testDay.advanced(by: -1)
        )
        
        // Then
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.result, TestResult.negative)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.receivedOnDay, testDay)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.isolationTrigger.startDay, testDay.advanced(by: -1))
    }
    
    func testProvidingOnsetDate() throws {
        let onsetDay = GregorianDay(year: 2020, month: 7, day: 12)
        let selfDiagnosisDay = GregorianDay(year: 2020, month: 7, day: 14)
        let testReceivedDay = GregorianDay(year: 2020, month: 7, day: 14)
        
        store.set(IndexCaseInfo(
            isolationTrigger: .selfDiagnosis(selfDiagnosisDay),
            onsetDay: onsetDay,
            testInfo: IndexCaseInfo.TestInfo(result: .positive, receivedOnDay: testReceivedDay)
        ))
        
        let providedOnsetDate = try XCTUnwrap(store.provideSymptomsOnsetDate())
        let expectedOnsetDate = LocalDay(gregorianDay: onsetDay, timeZone: .current).startOfDay
        XCTAssertEqual(expectedOnsetDate, providedOnsetDate)
    }
    
    func testProvidingOnsetDateUsingSelfDiagnosisDate() throws {
        let selfDiagnosisDay = GregorianDay(year: 2020, month: 7, day: 12)
        let expectedOnsetDay = GregorianDay(year: 2020, month: 7, day: 10)
        let testReceivedDay = GregorianDay(year: 2020, month: 7, day: 14)
        
        store.set(IndexCaseInfo(
            isolationTrigger: .selfDiagnosis(selfDiagnosisDay),
            onsetDay: nil,
            testInfo: IndexCaseInfo.TestInfo(result: .positive, receivedOnDay: testReceivedDay)
        ))
        
        let providedOnsetDate = try XCTUnwrap(store.provideSymptomsOnsetDate())
        let expectedOnsetDate = LocalDay(gregorianDay: expectedOnsetDay, timeZone: .current).startOfDay
        XCTAssertEqual(expectedOnsetDate, providedOnsetDate)
    }
    
    func testProvidingExposureDate() throws {
        let exposureDay = GregorianDay(year: 2020, month: 7, day: 11)
        
        let isolationInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: false,
            hasAcknowledgedStartOfIsolation: true,
            indexCaseInfo: nil,
            contactCaseInfo: ContactCaseInfo(
                exposureDay: exposureDay,
                isolationFromStartOfDay: .today,
                trigger: .exposureDetection
            )
        )
        
        store.set(isolationInfo.contactCaseInfo!)
        let providedExposureDate = try XCTUnwrap(store.provideExposureDetails()?.encounterDate)
        let expectedExposureDate = LocalDay(gregorianDay: exposureDay, timeZone: .current).startOfDay
        
        XCTAssertEqual(expectedExposureDate, providedExposureDate)
    }
}
