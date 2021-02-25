//
// Copyright © 2021 DHSC. All rights reserved.
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
                housekeepingDeletionPeriod: 14,
                indexCaseSinceNPEXDayNoSelfDiagnosis: IsolationConfiguration.default.indexCaseSinceNPEXDayNoSelfDiagnosis
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
    
    func testLoadingConfigurationDefaultsTo10DaysNPEXIfValueMissing() {
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
                "hasAcknowledgedEndOfIsolation": false,
                "hasAcknowledgedStartOfIsolation": false,
            }
        }
        """# .data(using: .utf8)!
        
        let expected = IsolationConfiguration(
            maxIsolation: 21,
            contactCase: 14,
            indexCaseSinceSelfDiagnosisOnset: 7,
            indexCaseSinceSelfDiagnosisUnknownOnset: 5,
            housekeepingDeletionPeriod: 14,
            indexCaseSinceNPEXDayNoSelfDiagnosis: 10
        )
        
        TS.assert(store.configuration, equals: expected)
    }
    
    func testLoadingConfigurationUsesStoredNPEXValueIfProvided() {
        $instance.encryptedStore.stored["isolation_state_info"] = #"""
        {
            "configuration" : {
                "indexCaseSinceSelfDiagnosisOnset" : 7,
                "maxIsolation" : 21,
                "contactCase" : 14,
                "indexCaseSinceSelfDiagnosisUnknownOnset" : 5,
                "housekeepingDeletionPeriod" : 14,
                "indexCaseSinceNPEXDayNoSelfDiagnosis": 35
            },
            "isolationInfo" : {
                "hasAcknowledgedEndOfIsolation": false,
                "hasAcknowledgedStartOfIsolation": false,
            }
        }
        """# .data(using: .utf8)!
        
        let expected = IsolationConfiguration(
            maxIsolation: 21,
            contactCase: 14,
            indexCaseSinceSelfDiagnosisOnset: 7,
            indexCaseSinceSelfDiagnosisUnknownOnset: 5,
            housekeepingDeletionPeriod: 14,
            indexCaseSinceNPEXDayNoSelfDiagnosis: 35
        )
        
        TS.assert(store.configuration, equals: expected)
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
                testInfo: IndexCaseInfo.TestInfo(result: .positive, requiresConfirmatoryTest: false, receivedOnDay: testReceivedDay)
            ),
            contactCaseInfo: ContactCaseInfo(
                exposureDay: exposureDay,
                isolationFromStartOfDay: isolationFromStartOfDay
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
                        "requiresConfirmatoryTest": false,
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
                testInfo: IndexCaseInfo.TestInfo(result: .positive, requiresConfirmatoryTest: false, receivedOnDay: testReceivedDay)
            ),
            contactCaseInfo: ContactCaseInfo(
                exposureDay: exposureDay,
                isolationFromStartOfDay: isolationFromStartOfDay
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
                testInfo: IndexCaseInfo.TestInfo(result: .positive, testKitType: .labResult, requiresConfirmatoryTest: false, receivedOnDay: testReceivedDay)
            ),
            contactCaseInfo: ContactCaseInfo(
                exposureDay: exposureDay,
                isolationFromStartOfDay: .today
            )
        )
        
        store.set(isolationInfo.indexCaseInfo!)
        store.set(isolationInfo.contactCaseInfo!)
        
        let storedData = try XCTUnwrap($instance.encryptedStore.stored["isolation_state_info"])
        let isolationStateInfo = try JSONDecoder().decode(IsolationStateInfo.self, from: storedData)
        
        XCTAssertEqual(isolationStateInfo.isolationInfo, isolationInfo)
    }
    
    func testProvidingOnsetDate() throws {
        let onsetDay = GregorianDay(year: 2020, month: 7, day: 12)
        let selfDiagnosisDay = GregorianDay(year: 2020, month: 7, day: 14)
        let testReceivedDay = GregorianDay(year: 2020, month: 7, day: 14)
        
        store.set(IndexCaseInfo(
            isolationTrigger: .selfDiagnosis(selfDiagnosisDay),
            onsetDay: onsetDay,
            testInfo: IndexCaseInfo.TestInfo(result: .positive, testKitType: .labResult, requiresConfirmatoryTest: false, receivedOnDay: testReceivedDay)
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
            testInfo: IndexCaseInfo.TestInfo(result: .positive, testKitType: .labResult, requiresConfirmatoryTest: false, receivedOnDay: testReceivedDay)
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
                isolationFromStartOfDay: .today
            )
        )
        
        store.set(isolationInfo.contactCaseInfo!)
        let providedExposureDate = try XCTUnwrap(store.provideExposureDetails()?.encounterDate)
        let expectedExposureDate = LocalDay(gregorianDay: exposureDay, timeZone: .current).startOfDay
        
        XCTAssertEqual(expectedExposureDate, providedExposureDate)
    }
    
    // MARK: - Operation
    
    func testClearingContactCaseInfoOnReceivingPositiveResult() throws {
        let selfDiagnosisDay = GregorianDay(year: 2020, month: 7, day: 12)
        let exposureDay = GregorianDay(year: 2020, month: 7, day: 11)
        let testDay = GregorianDay(year: 2020, month: 7, day: 13)
        let npexDay = GregorianDay(year: 2020, month: 7, day: 16)
        
        // Given
        let isolationInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: false,
            hasAcknowledgedStartOfIsolation: false,
            indexCaseInfo: IndexCaseInfo(
                isolationTrigger: .selfDiagnosis(selfDiagnosisDay),
                onsetDay: nil,
                testInfo: nil
            ),
            contactCaseInfo: ContactCaseInfo(
                exposureDay: exposureDay,
                isolationFromStartOfDay: .today
            )
        )
        
        // When
        store.isolationStateInfo = store.newIsolationStateInfo(
            from: isolationInfo,
            for: .positive,
            testKitType: .labResult,
            requiresConfirmatoryTest: false,
            receivedOn: testDay,
            npexDay: npexDay,
            operation: .update
        )
        
        // Then
        XCTAssertNil(store.isolationInfo.contactCaseInfo)
    }
    
    func testStoreTestResultUpdateOperation() throws {
        let selfDiagnosisDay = GregorianDay(year: 2020, month: 7, day: 12)
        let testDay = GregorianDay(year: 2020, month: 7, day: 13)
        let npexDay = GregorianDay(year: 2020, month: 7, day: 16)
        
        // Given
        let isolationInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: false,
            hasAcknowledgedStartOfIsolation: false,
            indexCaseInfo: IndexCaseInfo(
                isolationTrigger: .selfDiagnosis(selfDiagnosisDay),
                onsetDay: nil,
                testInfo: nil
            ),
            contactCaseInfo: nil
        )
        
        // When
        store.isolationStateInfo = store.newIsolationStateInfo(
            from: isolationInfo,
            for: .positive,
            testKitType: .labResult,
            requiresConfirmatoryTest: false,
            receivedOn: testDay,
            npexDay: npexDay,
            operation: .update
        )
        
        // Then
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.result, TestResult.positive)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.receivedOnDay, testDay)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.isolationTrigger.startDay, selfDiagnosisDay)
    }
    
    func testStoreTestResultNothingOperation() throws {
        let testDay = GregorianDay(year: 2020, month: 7, day: 16)
        
        // Given
        let isolationInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: false,
            hasAcknowledgedStartOfIsolation: false,
            indexCaseInfo: nil,
            contactCaseInfo: nil
        )
        
        // When
        store.isolationStateInfo = store.newIsolationStateInfo(
            from: isolationInfo,
            for: .void,
            testKitType: .labResult,
            requiresConfirmatoryTest: false,
            receivedOn: testDay,
            npexDay: testDay.advanced(by: -2),
            operation: .nothing
        )
        
        // Then
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo, nil)
    }
    
    func testStoreTestResultOverwriteOperation() throws {
        let testDay = GregorianDay(year: 2020, month: 7, day: 16)
        let selfDiagnosisDay = testDay.advanced(by: -6)
        
        // Given
        let isolationInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: false,
            hasAcknowledgedStartOfIsolation: false,
            indexCaseInfo: IndexCaseInfo(
                isolationTrigger: .manualTestEntry(npexDay: selfDiagnosisDay),
                onsetDay: nil,
                testInfo: IndexCaseInfo.TestInfo(result: .void, testKitType: .labResult, requiresConfirmatoryTest: false, receivedOnDay: testDay.advanced(by: -4))
            ),
            contactCaseInfo: nil
        )
        
        // When
        store.isolationStateInfo = store.newIsolationStateInfo(
            from: isolationInfo,
            for: .positive,
            testKitType: .labResult,
            requiresConfirmatoryTest: false,
            receivedOn: testDay,
            npexDay: testDay.advanced(by: -2),
            operation: .overwrite
        )
        
        // Then
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.result, TestResult.positive)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.receivedOnDay, testDay)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.isolationTrigger.startDay, testDay.advanced(by: -2))
    }
    
    func testStoreTestResultOverwriteUpdateOperation() throws {
        let testDay = GregorianDay(year: 2020, month: 7, day: 16)
        
        // Given
        let isolationInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: false,
            hasAcknowledgedStartOfIsolation: false,
            indexCaseInfo: nil,
            contactCaseInfo: nil
        )
        
        // When
        store.isolationStateInfo = store.newIsolationStateInfo(
            from: isolationInfo,
            for: .positive,
            testKitType: .labResult,
            requiresConfirmatoryTest: false,
            receivedOn: testDay,
            npexDay: testDay.advanced(by: -2),
            operation: .update
        )
        
        // Then
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.result, TestResult.positive)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.receivedOnDay, testDay)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.isolationTrigger.startDay, testDay.advanced(by: -2))
    }
    
    func testConfirmTestResultOperation() {
        let exposureDay = GregorianDay(year: 2020, month: 7, day: 11)
        let testDay = GregorianDay(year: 2020, month: 7, day: 16)
        let npexDayConfirmed = GregorianDay(year: 2020, month: 7, day: 20)
        
        // Given
        let isolationInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: false,
            hasAcknowledgedStartOfIsolation: false,
            indexCaseInfo: IndexCaseInfo(
                isolationTrigger: .manualTestEntry(npexDay: testDay),
                onsetDay: nil,
                testInfo: IndexCaseInfo.TestInfo(result: .positive, testKitType: .rapidResult, requiresConfirmatoryTest: true, receivedOnDay: testDay.advanced(by: -4))
            ),
            contactCaseInfo: ContactCaseInfo(
                exposureDay: exposureDay,
                isolationFromStartOfDay: .today
            )
        )
        
        // When
        store.isolationStateInfo = store.newIsolationStateInfo(
            from: isolationInfo,
            for: .positive,
            testKitType: .labResult,
            requiresConfirmatoryTest: false,
            receivedOn: testDay,
            npexDay: npexDayConfirmed,
            operation: .confirm
        )
        
        // THEN
        XCTAssertNil(store.isolationStateInfo?.isolationInfo.contactCaseInfo)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.receivedOnDay, testDay.advanced(by: -4))
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.requiresConfirmatoryTest, true)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.confirmedOnDay, npexDayConfirmed)
    }
    
    func testIgnoreTestResultOperation() {
        let exposureDay = GregorianDay(year: 2020, month: 7, day: 11)
        let testDay = GregorianDay(year: 2020, month: 7, day: 16)
        let npexDayConfirmed = GregorianDay(year: 2020, month: 7, day: 20)
        
        // Given
        let isolationInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: false,
            hasAcknowledgedStartOfIsolation: false,
            indexCaseInfo: nil,
            contactCaseInfo: ContactCaseInfo(
                exposureDay: exposureDay,
                isolationFromStartOfDay: .today
            )
        )
        
        // When
        store.isolationStateInfo = store.newIsolationStateInfo(
            from: isolationInfo,
            for: .positive,
            testKitType: .labResult,
            requiresConfirmatoryTest: false,
            receivedOn: testDay,
            npexDay: npexDayConfirmed,
            operation: .ignore
        )
        
        // THEN
        XCTAssertNotNil(store.isolationStateInfo?.isolationInfo.contactCaseInfo)
        XCTAssertNil(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo)
    }
    
    func testOverwriteAndConfirmTestResultOperation() {
        let exposureDay = GregorianDay(year: 2020, month: 7, day: 11)
        let testDay = GregorianDay(year: 2020, month: 7, day: 13)
        let npexDay = GregorianDay(year: 2020, month: 7, day: 16)
        let newNpexDay = GregorianDay(year: 2020, month: 7, day: 18)
        
        // Given
        let isolationInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: false,
            hasAcknowledgedStartOfIsolation: false,
            indexCaseInfo: IndexCaseInfo(
                isolationTrigger: .manualTestEntry(npexDay: npexDay),
                onsetDay: nil,
                testInfo: nil
            ),
            contactCaseInfo: ContactCaseInfo(
                exposureDay: exposureDay,
                isolationFromStartOfDay: .today
            )
        )
        
        // When
        store.isolationStateInfo = store.newIsolationStateInfo(
            from: isolationInfo,
            for: .positive,
            testKitType: .labResult,
            requiresConfirmatoryTest: false,
            receivedOn: testDay,
            npexDay: newNpexDay,
            operation: .overwriteAndConfirm
        )
        
        // Then
        XCTAssertNil(store.isolationInfo.contactCaseInfo)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.isolationTrigger, .manualTestEntry(npexDay: newNpexDay))
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.receivedOnDay, testDay)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.requiresConfirmatoryTest, false)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.confirmedOnDay, npexDay)
    }
    
    func testUpdateAndConfirmTestResultOperation() {
        let selfDiagnosisDay = GregorianDay(year: 2020, month: 7, day: 12)
        let exposureDay = GregorianDay(year: 2020, month: 7, day: 11)
        let testDay = GregorianDay(year: 2020, month: 7, day: 13)
        let npexDay = GregorianDay(year: 2020, month: 7, day: 16)
        
        // Given
        let isolationInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: false,
            hasAcknowledgedStartOfIsolation: false,
            indexCaseInfo: IndexCaseInfo(
                isolationTrigger: .selfDiagnosis(selfDiagnosisDay),
                onsetDay: selfDiagnosisDay,
                testInfo: nil
            ),
            contactCaseInfo: ContactCaseInfo(
                exposureDay: exposureDay,
                isolationFromStartOfDay: .today
            )
        )
        
        // When
        store.isolationStateInfo = store.newIsolationStateInfo(
            from: isolationInfo,
            for: .positive,
            testKitType: .labResult,
            requiresConfirmatoryTest: false,
            receivedOn: testDay,
            npexDay: npexDay,
            operation: .updateAndConfirm
        )
        
        // Then
        XCTAssertNil(store.isolationInfo.contactCaseInfo)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.isolationTrigger, .selfDiagnosis(selfDiagnosisDay))
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.receivedOnDay, testDay)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.requiresConfirmatoryTest, false)
    }
}
