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
            store = IsolationStateStore(store: configuration.encryptedStore) { .default }
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
    
    func testLoadingEmptyIndexCaseInfo() throws {
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
                selfDiagnosisDay: selfDiagnosisDay,
                onsetDay: onsetDay,
                testInfo: IndexCaseInfo.TestInfo(result: .positive, receivedOnDay: testReceivedDay)
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
                selfDiagnosisDay: selfDiagnosisDay,
                onsetDay: onsetDay,
                testInfo: IndexCaseInfo.TestInfo(result: .positive, receivedOnDay: testReceivedDay)
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
    
    func testStoreTestResult() throws {
        let selfDiagnosisDay = GregorianDay(year: 2020, month: 7, day: 12)
        let testDay = GregorianDay(year: 2020, month: 7, day: 13)
        
        store.set(IndexCaseInfo(
            selfDiagnosisDay: selfDiagnosisDay,
            onsetDay: nil,
            testInfo: nil
        ))
        
        store.set(testResult: .positive, receivedOn: testDay)
        
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.result, TestResult.positive)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.receivedOnDay, testDay)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.selfDiagnosisDay, selfDiagnosisDay)
    }
    
    func testNotOverwriteNegativeTestResult() throws {
        let selfDiagnosisDay = GregorianDay(year: 2020, month: 7, day: 12)
        let testDay = GregorianDay(year: 2020, month: 7, day: 13)
        
        store.set(IndexCaseInfo(
            selfDiagnosisDay: selfDiagnosisDay,
            onsetDay: nil,
            testInfo: nil
        ))
        
        store.set(testResult: .negative, receivedOn: testDay)
        store.set(testResult: .positive, receivedOn: testDay)
        
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.result, TestResult.negative)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.receivedOnDay, testDay)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.selfDiagnosisDay, selfDiagnosisDay)
    }
    
    func testProvidingOnsetDate() throws {
        let onsetDay = GregorianDay(year: 2020, month: 7, day: 12)
        let selfDiagnosisDay = GregorianDay(year: 2020, month: 7, day: 14)
        let testReceivedDay = GregorianDay(year: 2020, month: 7, day: 14)
        
        store.set(IndexCaseInfo(
            selfDiagnosisDay: selfDiagnosisDay,
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
            selfDiagnosisDay: selfDiagnosisDay,
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
                isolationFromStartOfDay: .today
            )
        )
        
        store.set(isolationInfo.contactCaseInfo!)
        let providedExposureDate = try XCTUnwrap(store.provideEncounterDate())
        let expectedExposureDate = LocalDay(gregorianDay: exposureDay, timeZone: .current).startOfDay
        
        XCTAssertEqual(expectedExposureDate, providedExposureDate)
    }
    
}
