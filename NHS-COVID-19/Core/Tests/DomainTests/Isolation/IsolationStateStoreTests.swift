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
                indexCaseSinceNPEXDayNoSelfDiagnosis: IsolationConfiguration.default.indexCaseSinceNPEXDayNoSelfDiagnosis,
                testResultPollingTokenRetentionPeriod: 28
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
            "version" : 2,
            "configuration" : {
                "indexCaseSinceSelfDiagnosisOnset" : 7,
                "maxIsolation" : 21,
                "contactCase" : 14,
                "indexCaseSinceSelfDiagnosisUnknownOnset" : 5,
                "housekeepingDeletionPeriod" : 14
            },
            "hasAcknowledgedEndOfIsolation": false,
        }
        """# .data(using: .utf8)!
        
        let expected = IsolationConfiguration(
            maxIsolation: 21,
            contactCase: 14,
            indexCaseSinceSelfDiagnosisOnset: 7,
            indexCaseSinceSelfDiagnosisUnknownOnset: 5,
            housekeepingDeletionPeriod: 14,
            indexCaseSinceNPEXDayNoSelfDiagnosis: 10,
            testResultPollingTokenRetentionPeriod: 28
        )
        
        TS.assert(store.configuration, equals: expected)
    }
    
    func testLoadingConfigurationUsesStoredNPEXValueIfProvided() {
        $instance.encryptedStore.stored["isolation_state_info"] = #"""
        {
            "version" : 2,
            "configuration" : {
                "indexCaseSinceSelfDiagnosisOnset" : 7,
                "maxIsolation" : 21,
                "contactCase" : 14,
                "indexCaseSinceSelfDiagnosisUnknownOnset" : 5,
                "housekeepingDeletionPeriod" : 14,
                "indexCaseSinceNPEXDayNoSelfDiagnosis": 35
            },
            "hasAcknowledgedEndOfIsolation": false,
        }
        """# .data(using: .utf8)!
        
        let expected = IsolationConfiguration(
            maxIsolation: 21,
            contactCase: 14,
            indexCaseSinceSelfDiagnosisOnset: 7,
            indexCaseSinceSelfDiagnosisUnknownOnset: 5,
            housekeepingDeletionPeriod: 14,
            indexCaseSinceNPEXDayNoSelfDiagnosis: 35,
            testResultPollingTokenRetentionPeriod: 28
        )
        
        TS.assert(store.configuration, equals: expected)
    }
    
    func testLoadingDataWithoutTestEndDate() throws {
        $instance.encryptedStore.stored["isolation_state_info"] = #"""
        {
            "version" : 2,
            "configuration" : {
                "indexCaseSinceSelfDiagnosisOnset" : 7,
                "maxIsolation" : 21,
                "contactCase" : 14,
                "indexCaseSinceSelfDiagnosisUnknownOnset" : 5,
                "housekeepingDeletionPeriod" : 14
            },
            "hasAcknowledgedEndOfIsolation": true,
            "contact" : {
                "hasAcknowledgedStartOfIsolation": false,
                "exposureDay" : {
                    "day" : 11,
                    "month" : 7,
                    "year" : 2020
                },
                "notificationDay":{
                    "year": 2020,
                    "month": 7,
                    "day": 13
                }
            },
            "symptomatic": {
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
            },
            "test" : {
                "testResult" : "positive",
                "requiresConfirmatoryTest" : false,
                "acknowledgedDay" : {
                    "day" : 14,
                    "month" : 7,
                    "year" : 2020
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
                symptomaticInfo: IndexCaseInfo.SymptomaticInfo(selfDiagnosisDay: selfDiagnosisDay, onsetDay: onsetDay),
                testInfo: IndexCaseInfo.TestInfo(result: .positive, requiresConfirmatoryTest: false, receivedOnDay: testReceivedDay, testEndDay: nil)
            ),
            contactCaseInfo: ContactCaseInfo(
                exposureDay: exposureDay,
                isolationFromStartOfDay: isolationFromStartOfDay
            )
        )
        
        TS.assert(store.isolationInfo, equals: expectedIsolationInfo)
    }
    
    func testLoadingDataWithContactIsolationOptOut() throws {
        $instance.encryptedStore.stored["isolation_state_info"] = #"""
        {
            "version" : 2,
            "configuration" : {
                "indexCaseSinceSelfDiagnosisOnset" : 7,
                "maxIsolation" : 21,
                "contactCase" : 14,
                "indexCaseSinceSelfDiagnosisUnknownOnset" : 5,
                "housekeepingDeletionPeriod" : 14
            },
            "hasAcknowledgedEndOfIsolation": true,
            "contact" : {
                "hasAcknowledgedStartOfIsolation": false,
                "exposureDay" : {
                    "day" : 11,
                    "month" : 7,
                    "year" : 2020
                },
                "notificationDay":{
                    "year": 2020,
                    "month": 7,
                    "day": 13
                },
                "isolationOptOutInfo": {
                    "fromDay": {
                        "day" : 12,
                        "month" : 7,
                        "year" : 2020
                    }
                }
            },
            "symptomatic": {
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
            },
            "test" : {
                "testResult" : "positive",
                "requiresConfirmatoryTest" : false,
                "acknowledgedDay" : {
                    "day" : 14,
                    "month" : 7,
                    "year" : 2020
                }
            }
        }
        """# .data(using: .utf8)!
        
        let onsetDay = GregorianDay(year: 2020, month: 7, day: 10)
        let exposureDay = GregorianDay(year: 2020, month: 7, day: 11)
        let contactOptOutDay = GregorianDay(year: 2020, month: 7, day: 12)
        let selfDiagnosisDay = GregorianDay(year: 2020, month: 7, day: 12)
        let isolationFromStartOfDay = GregorianDay(year: 2020, month: 7, day: 13)
        let testReceivedDay = GregorianDay(year: 2020, month: 7, day: 14)
        
        let expectedIsolationInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: true,
            indexCaseInfo: IndexCaseInfo(
                symptomaticInfo: IndexCaseInfo.SymptomaticInfo(selfDiagnosisDay: selfDiagnosisDay, onsetDay: onsetDay),
                testInfo: IndexCaseInfo.TestInfo(result: .positive, requiresConfirmatoryTest: false, receivedOnDay: testReceivedDay, testEndDay: nil)
            ),
            contactCaseInfo: ContactCaseInfo(
                exposureDay: exposureDay,
                isolationFromStartOfDay: isolationFromStartOfDay,
                optOutOfIsolationDay: contactOptOutDay
            )
        )
        
        TS.assert(store.isolationInfo, equals: expectedIsolationInfo)
    }
    
    func testLoadingTestEndDayFromTestInfoTestEndDay() throws {
        $instance.encryptedStore.stored["isolation_state_info"] = #"""
        {
            "version" : 2,
            "configuration" : {
                "indexCaseSinceSelfDiagnosisOnset" : 7,
                "maxIsolation" : 21,
                "contactCase" : 14,
                "indexCaseSinceSelfDiagnosisUnknownOnset" : 5,
                "housekeepingDeletionPeriod" : 14
            },
            "hasAcknowledgedEndOfIsolation": true,
            "contact" : {
                "hasAcknowledgedStartOfIsolation": false,
                "exposureDay" : {
                    "day" : 11,
                    "month" : 7,
                    "year" : 2020
                },
                "notificationDay":{
                    "year": 2020,
                    "month": 7,
                    "day": 13
                }
            },
            "test" : {
                "testResult" : "positive",
                "requiresConfirmatoryTest" : false,
                "testEndDay" : {
                    "day" : 12,
                    "month" : 7,
                    "year" : 2020
                },
                "acknowledgedDay" : {
                    "day" : 14,
                    "month" : 7,
                    "year" : 2020
                }
            }
        }
        """# .data(using: .utf8)!
        
        let exposureDay = GregorianDay(year: 2020, month: 7, day: 11)
        let npexDay = GregorianDay(year: 2020, month: 7, day: 12)
        let isolationFromStartOfDay = GregorianDay(year: 2020, month: 7, day: 13)
        let testReceivedDay = GregorianDay(year: 2020, month: 7, day: 14)
        
        let expectedIsolationInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: true,
            indexCaseInfo: IndexCaseInfo(
                symptomaticInfo: nil,
                testInfo: IndexCaseInfo.TestInfo(result: .positive, requiresConfirmatoryTest: false, receivedOnDay: testReceivedDay, testEndDay: npexDay)
            ),
            contactCaseInfo: ContactCaseInfo(
                exposureDay: exposureDay,
                isolationFromStartOfDay: isolationFromStartOfDay
            )
        )
        
        TS.assert(store.isolationInfo, equals: expectedIsolationInfo)
    }
    
    func testLoadingConfirmedOnDayFromTestInfoPayloadV1() throws {
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
                    "npexDay" : {
                        "day" : 12,
                        "month" : 7,
                        "year" : 2020
                    },
                    "testInfo": {
                        "result" : "positive",
                        "requiresConfirmatoryTest" : true,
                        "receivedOnDay" : {
                            "day" : 14,
                            "month" : 7,
                            "year" : 2020
                        },
                        "confirmedOnDay" : {
                            "day" : 17,
                            "month" : 7,
                            "year" : 2020
                        }
                    }
                }
            }
        }
        """# .data(using: .utf8)!
        
        let exposureDay = GregorianDay(year: 2020, month: 7, day: 11)
        let npexDay = GregorianDay(year: 2020, month: 7, day: 12)
        let isolationFromStartOfDay = GregorianDay(year: 2020, month: 7, day: 13)
        let testReceivedDay = GregorianDay(year: 2020, month: 7, day: 14)
        let completedOnDay = GregorianDay(year: 2020, month: 7, day: 17)
        
        let expectedIsolationInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: true,
            indexCaseInfo: IndexCaseInfo(
                symptomaticInfo: nil,
                testInfo: IndexCaseInfo.TestInfo(
                    result: .positive,
                    requiresConfirmatoryTest: true,
                    receivedOnDay: testReceivedDay,
                    confirmedOnDay: completedOnDay,
                    completedOnDay: completedOnDay,
                    testEndDay: npexDay
                )
            ),
            contactCaseInfo: ContactCaseInfo(
                exposureDay: exposureDay,
                isolationFromStartOfDay: isolationFromStartOfDay
            )
        )
        
        TS.assert(store.isolationInfo, equals: expectedIsolationInfo)
    }
    
    func testLoadingConfirmedOnDayFromTestInfoPayloadV2() throws {
        $instance.encryptedStore.stored["isolation_state_info"] = #"""
        {
            "version" : 2,
            "configuration" : {
                "indexCaseSinceSelfDiagnosisOnset" : 7,
                "maxIsolation" : 21,
                "contactCase" : 14,
                "indexCaseSinceSelfDiagnosisUnknownOnset" : 5,
                "housekeepingDeletionPeriod" : 14
            },
            "hasAcknowledgedEndOfIsolation": true,
            "contact" : {
                "hasAcknowledgedStartOfIsolation": false,
                "exposureDay" : {
                    "day" : 11,
                    "month" : 7,
                    "year" : 2020
                },
                "notificationDay":{
                    "year": 2020,
                    "month": 7,
                    "day": 13
                }
            },
            "test" : {
                "testResult" : "positive",
                "requiresConfirmatoryTest" : true,
                "testEndDay" : {
                    "day" : 12,
                    "month" : 7,
                    "year" : 2020
                },
                "acknowledgedDay" : {
                    "day" : 14,
                    "month" : 7,
                    "year" : 2020
                },
                "confirmedDay" : {
                    "day" : 17,
                    "month" : 7,
                    "year" : 2020
                },
                "confirmatoryTestCompletionStatus": "completedAndConfirmed"
            }
        }
        """# .data(using: .utf8)!
        
        let exposureDay = GregorianDay(year: 2020, month: 7, day: 11)
        let npexDay = GregorianDay(year: 2020, month: 7, day: 12)
        let isolationFromStartOfDay = GregorianDay(year: 2020, month: 7, day: 13)
        let testReceivedDay = GregorianDay(year: 2020, month: 7, day: 14)
        let completedOnDay = GregorianDay(year: 2020, month: 7, day: 17)
        
        let expectedIsolationInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: true,
            indexCaseInfo: IndexCaseInfo(
                symptomaticInfo: nil,
                testInfo: IndexCaseInfo.TestInfo(
                    result: .positive,
                    requiresConfirmatoryTest: true,
                    receivedOnDay: testReceivedDay,
                    confirmedOnDay: completedOnDay,
                    completedOnDay: completedOnDay,
                    testEndDay: npexDay
                )
            ),
            contactCaseInfo: ContactCaseInfo(
                exposureDay: exposureDay,
                isolationFromStartOfDay: isolationFromStartOfDay
            )
        )
        
        TS.assert(store.isolationInfo, equals: expectedIsolationInfo)
    }
    
    func testLoadingCompletedOnDayFromTestInfoPayloadV2() throws {
        $instance.encryptedStore.stored["isolation_state_info"] = #"""
        {
            "version" : 2,
            "configuration" : {
                "indexCaseSinceSelfDiagnosisOnset" : 7,
                "maxIsolation" : 21,
                "contactCase" : 14,
                "indexCaseSinceSelfDiagnosisUnknownOnset" : 5,
                "housekeepingDeletionPeriod" : 14
            },
            "hasAcknowledgedEndOfIsolation": true,
            "contact" : {
                "hasAcknowledgedStartOfIsolation": false,
                "exposureDay" : {
                    "day" : 11,
                    "month" : 7,
                    "year" : 2020
                },
                "notificationDay":{
                    "year": 2020,
                    "month": 7,
                    "day": 13
                }
            },
            "test" : {
                "testResult" : "positive",
                "requiresConfirmatoryTest" : true,
                "testEndDay" : {
                    "day" : 12,
                    "month" : 7,
                    "year" : 2020
                },
                "acknowledgedDay" : {
                    "day" : 14,
                    "month" : 7,
                    "year" : 2020
                },
                "confirmedDay" : {
                    "day" : 17,
                    "month" : 7,
                    "year" : 2020
                },
                "confirmatoryTestCompletionStatus": "completed"
            }
        }
        """# .data(using: .utf8)!
        
        let exposureDay = GregorianDay(year: 2020, month: 7, day: 11)
        let npexDay = GregorianDay(year: 2020, month: 7, day: 12)
        let isolationFromStartOfDay = GregorianDay(year: 2020, month: 7, day: 13)
        let testReceivedDay = GregorianDay(year: 2020, month: 7, day: 14)
        let completedOnDay = GregorianDay(year: 2020, month: 7, day: 17)
        
        let expectedIsolationInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: true,
            indexCaseInfo: IndexCaseInfo(
                symptomaticInfo: nil,
                testInfo: IndexCaseInfo.TestInfo(
                    result: .positive,
                    requiresConfirmatoryTest: true,
                    receivedOnDay: testReceivedDay,
                    confirmedOnDay: nil,
                    completedOnDay: completedOnDay,
                    testEndDay: npexDay
                )
            ),
            contactCaseInfo: ContactCaseInfo(
                exposureDay: exposureDay,
                isolationFromStartOfDay: isolationFromStartOfDay
            )
        )
        
        TS.assert(store.isolationInfo, equals: expectedIsolationInfo)
    }
    
    func testLoadingConfigurationDefaultsTo10DaysNPEXIfValueMissingV1() {
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
            indexCaseSinceNPEXDayNoSelfDiagnosis: 10,
            testResultPollingTokenRetentionPeriod: 28
        )
        
        TS.assert(store.configuration, equals: expected)
    }
    
    func testLoadingConfigurationUsesStoredNPEXValueIfProvidedV1() {
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
            indexCaseSinceNPEXDayNoSelfDiagnosis: 35,
            testResultPollingTokenRetentionPeriod: 28
        )
        
        TS.assert(store.configuration, equals: expected)
    }
    
    func testLoadingDataV1() throws {
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
                symptomaticInfo: IndexCaseInfo.SymptomaticInfo(selfDiagnosisDay: selfDiagnosisDay, onsetDay: onsetDay),
                testInfo: IndexCaseInfo.TestInfo(result: .positive, requiresConfirmatoryTest: false, receivedOnDay: testReceivedDay, testEndDay: nil)
            ),
            contactCaseInfo: ContactCaseInfo(
                exposureDay: exposureDay,
                isolationFromStartOfDay: isolationFromStartOfDay
            )
        )
        
        TS.assert(store.isolationInfo, equals: expectedIsolationInfo)
    }
    
    func testLoadingNpexDayFromTestInfoTestEndDayV1() throws {
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
                    "npexDay" : {
                        "day" : 12,
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
        
        let exposureDay = GregorianDay(year: 2020, month: 7, day: 11)
        let npexDay = GregorianDay(year: 2020, month: 7, day: 12)
        let isolationFromStartOfDay = GregorianDay(year: 2020, month: 7, day: 13)
        let testReceivedDay = GregorianDay(year: 2020, month: 7, day: 14)
        
        let expectedIsolationInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: true,
            indexCaseInfo: IndexCaseInfo(
                symptomaticInfo: nil,
                testInfo: IndexCaseInfo.TestInfo(result: .positive, requiresConfirmatoryTest: false, receivedOnDay: testReceivedDay, testEndDay: npexDay)
            ),
            contactCaseInfo: ContactCaseInfo(
                exposureDay: exposureDay,
                isolationFromStartOfDay: isolationFromStartOfDay
            )
        )
        
        TS.assert(store.isolationInfo, equals: expectedIsolationInfo)
    }
    
    func testLoadingNewDataV1() throws {
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
                symptomaticInfo: IndexCaseInfo.SymptomaticInfo(selfDiagnosisDay: selfDiagnosisDay, onsetDay: onsetDay),
                testInfo: IndexCaseInfo.TestInfo(result: .positive, requiresConfirmatoryTest: false, receivedOnDay: testReceivedDay, testEndDay: nil)
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
            hasAcknowledgedStartOfContactIsolation: false,
            indexCaseInfo: IndexCaseInfo(
                symptomaticInfo: IndexCaseInfo.SymptomaticInfo(selfDiagnosisDay: selfDiagnosisDay, onsetDay: onsetDay),
                testInfo: IndexCaseInfo.TestInfo(result: .positive, testKitType: .labResult, requiresConfirmatoryTest: false, receivedOnDay: testReceivedDay, testEndDay: nil)
            ),
            contactCaseInfo: ContactCaseInfo(
                exposureDay: exposureDay,
                isolationFromStartOfDay: .today
            )
        )
        
        store.set(isolationInfo.indexCaseInfo!)
        
        XCTAssertFalse(store.isolationInfo.hasAcknowledgedStartOfContactIsolation) // index case does not change acknowledgment for contact isolation
        
        store.set(isolationInfo.contactCaseInfo!)
        
        XCTAssertFalse(store.isolationInfo.hasAcknowledgedStartOfContactIsolation) // contact after index keeps the acknowledgement flag
        
        let newStore = IsolationStateStore(
            store: $instance.encryptedStore,
            latestConfiguration: { .default },
            currentDateProvider: MockDateProvider()
        )
        
        TS.assert(newStore.isolationInfo, equals: isolationInfo)
    }
    
    func testProvidingOnsetDate() throws {
        let onsetDay = GregorianDay(year: 2020, month: 7, day: 12)
        let selfDiagnosisDay = GregorianDay(year: 2020, month: 7, day: 14)
        let testReceivedDay = GregorianDay(year: 2020, month: 7, day: 14)
        
        store.set(IndexCaseInfo(
            symptomaticInfo: IndexCaseInfo.SymptomaticInfo(selfDiagnosisDay: selfDiagnosisDay, onsetDay: onsetDay),
            testInfo: IndexCaseInfo.TestInfo(result: .positive, testKitType: .labResult, requiresConfirmatoryTest: false, receivedOnDay: testReceivedDay, testEndDay: nil)
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
            symptomaticInfo: IndexCaseInfo.SymptomaticInfo(selfDiagnosisDay: selfDiagnosisDay, onsetDay: nil),
            testInfo: IndexCaseInfo.TestInfo(result: .positive, testKitType: .labResult, requiresConfirmatoryTest: false, receivedOnDay: testReceivedDay, testEndDay: nil)
        ))
        
        let providedOnsetDate = try XCTUnwrap(store.provideSymptomsOnsetDate())
        let expectedOnsetDate = LocalDay(gregorianDay: expectedOnsetDay, timeZone: .current).startOfDay
        XCTAssertEqual(expectedOnsetDate, providedOnsetDate)
    }
    
    func testProvidingExposureDate() throws {
        let exposureDay = GregorianDay(year: 2020, month: 7, day: 11)
        
        let isolationInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: false,
            hasAcknowledgedStartOfContactIsolation: true,
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
            hasAcknowledgedStartOfContactIsolation: false,
            indexCaseInfo: IndexCaseInfo(
                symptomaticInfo: IndexCaseInfo.SymptomaticInfo(selfDiagnosisDay: selfDiagnosisDay, onsetDay: nil),
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
            hasAcknowledgedStartOfContactIsolation: false,
            indexCaseInfo: IndexCaseInfo(
                symptomaticInfo: IndexCaseInfo.SymptomaticInfo(selfDiagnosisDay: selfDiagnosisDay, onsetDay: nil),
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
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.startDay, selfDiagnosisDay)
    }
    
    func testStoreTestResultNothingOperation() throws {
        let testDay = GregorianDay(year: 2020, month: 7, day: 16)
        
        // Given
        let isolationInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: false,
            hasAcknowledgedStartOfContactIsolation: false,
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
        let testEndDay = testDay.advanced(by: -6)
        
        // Given
        let isolationInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: false,
            hasAcknowledgedStartOfContactIsolation: false,
            indexCaseInfo: IndexCaseInfo(
                symptomaticInfo: nil,
                testInfo: IndexCaseInfo.TestInfo(result: .negative, testKitType: .labResult, requiresConfirmatoryTest: false, receivedOnDay: testDay.advanced(by: -4), testEndDay: testEndDay)
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
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.startDay, testDay.advanced(by: -2))
    }
    
    func testStoreTestResultOverwriteUpdateOperation() throws {
        let testDay = GregorianDay(year: 2020, month: 7, day: 16)
        
        // Given
        let isolationInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: false,
            hasAcknowledgedStartOfContactIsolation: false,
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
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.startDay, testDay.advanced(by: -2))
    }
    
    func testConfirmTestResultOperation() {
        let exposureDay = GregorianDay(year: 2020, month: 7, day: 11)
        let testDay = GregorianDay(year: 2020, month: 7, day: 16)
        let npexDayConfirmed = GregorianDay(year: 2020, month: 7, day: 20)
        
        // Given
        let isolationInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: false,
            hasAcknowledgedStartOfContactIsolation: false,
            indexCaseInfo: IndexCaseInfo(
                symptomaticInfo: nil,
                testInfo: IndexCaseInfo.TestInfo(result: .positive, testKitType: .rapidResult, requiresConfirmatoryTest: true, receivedOnDay: testDay.advanced(by: -4), testEndDay: testDay)
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
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.completedOnDay, npexDayConfirmed)
    }
    
    func testCompleteTestResultOperation() {
        let exposureDay = GregorianDay(year: 2020, month: 7, day: 11)
        let testDay = GregorianDay(year: 2020, month: 7, day: 16)
        let npexDayCompleted = GregorianDay(year: 2020, month: 7, day: 20)
        
        // Given
        let isolationInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: false,
            hasAcknowledgedStartOfContactIsolation: false,
            indexCaseInfo: IndexCaseInfo(
                symptomaticInfo: nil,
                testInfo: IndexCaseInfo.TestInfo(result: .positive, testKitType: .rapidResult, requiresConfirmatoryTest: true, receivedOnDay: testDay.advanced(by: -4), testEndDay: testDay)
            ),
            contactCaseInfo: ContactCaseInfo(
                exposureDay: exposureDay,
                isolationFromStartOfDay: .today
            )
        )
        
        // When
        store.isolationStateInfo = store.newIsolationStateInfo(
            from: isolationInfo,
            for: .negative,
            testKitType: .labResult,
            requiresConfirmatoryTest: false,
            receivedOn: testDay,
            npexDay: npexDayCompleted,
            operation: .complete
        )
        
        // THEN
        XCTAssertNotNil(store.isolationStateInfo?.isolationInfo.contactCaseInfo)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.receivedOnDay, testDay.advanced(by: -4))
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.requiresConfirmatoryTest, true)
        XCTAssertNil(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.confirmedOnDay)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.completedOnDay, npexDayCompleted)
    }
    
    func testIgnoreTestResultOperation() {
        let exposureDay = GregorianDay(year: 2020, month: 7, day: 11)
        let testDay = GregorianDay(year: 2020, month: 7, day: 16)
        let npexDayConfirmed = GregorianDay(year: 2020, month: 7, day: 20)
        
        // Given
        let isolationInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: false,
            hasAcknowledgedStartOfContactIsolation: false,
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
            hasAcknowledgedStartOfContactIsolation: false,
            indexCaseInfo: IndexCaseInfo(
                symptomaticInfo: nil,
                testInfo: .init(result: .positive, requiresConfirmatoryTest: false, receivedOnDay: npexDay, testEndDay: npexDay)
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
            hasAcknowledgedStartOfContactIsolation: false,
            indexCaseInfo: IndexCaseInfo(
                symptomaticInfo: IndexCaseInfo.SymptomaticInfo(selfDiagnosisDay: selfDiagnosisDay, onsetDay: selfDiagnosisDay),
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
    
    func testDeleteSymptomsTestResultOperation() {
        let selfDiagnosisDay = GregorianDay(year: 2020, month: 7, day: 12)
        let exposureDay = GregorianDay(year: 2020, month: 7, day: 11)
        let testDay = GregorianDay(year: 2020, month: 7, day: 13)
        let npexDay = GregorianDay(year: 2020, month: 7, day: 16)
        
        // Given
        let isolationInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: false,
            hasAcknowledgedStartOfContactIsolation: false,
            indexCaseInfo: IndexCaseInfo(
                symptomaticInfo: IndexCaseInfo.SymptomaticInfo(selfDiagnosisDay: selfDiagnosisDay, onsetDay: selfDiagnosisDay),
                testInfo: .init(result: .positive, requiresConfirmatoryTest: false, receivedOnDay: npexDay, testEndDay: npexDay)
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
            operation: .deleteSymptoms
        )
        
        // Then
        XCTAssertNil(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.symptomaticInfo)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.isolationTrigger, .manualTestEntry(npexDay: npexDay))
    }
    
    func testDeleteTestTestResultOperation() {
        let selfDiagnosisDay = GregorianDay(year: 2020, month: 7, day: 12)
        let exposureDay = GregorianDay(year: 2020, month: 7, day: 11)
        let testDay = GregorianDay(year: 2020, month: 7, day: 13)
        let npexDay = GregorianDay(year: 2020, month: 7, day: 16)
        
        // Given
        let isolationInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: false,
            hasAcknowledgedStartOfContactIsolation: false,
            indexCaseInfo: IndexCaseInfo(
                symptomaticInfo: IndexCaseInfo.SymptomaticInfo(selfDiagnosisDay: selfDiagnosisDay, onsetDay: selfDiagnosisDay),
                testInfo: .init(result: .positive, requiresConfirmatoryTest: false, receivedOnDay: npexDay, testEndDay: npexDay)
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
            operation: .deleteTest
        )
        
        // Then
        XCTAssertNil(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.isolationTrigger, .selfDiagnosis(selfDiagnosisDay))
    }
    
    func testCompleteAndDeleteSymptomsTestResultOperation() {
        let selfDiagnosisDay = GregorianDay(year: 2020, month: 7, day: 12)
        let exposureDay = GregorianDay(year: 2020, month: 7, day: 11)
        let testDay = GregorianDay(year: 2020, month: 7, day: 16)
        let npexDayCompleted = GregorianDay(year: 2020, month: 7, day: 20)
        
        // Given
        let isolationInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: false,
            hasAcknowledgedStartOfContactIsolation: false,
            indexCaseInfo: IndexCaseInfo(
                symptomaticInfo: IndexCaseInfo.SymptomaticInfo(selfDiagnosisDay: selfDiagnosisDay, onsetDay: selfDiagnosisDay),
                testInfo: IndexCaseInfo.TestInfo(result: .positive, testKitType: .rapidResult, requiresConfirmatoryTest: true, receivedOnDay: testDay.advanced(by: -4), testEndDay: testDay)
            ),
            contactCaseInfo: ContactCaseInfo(
                exposureDay: exposureDay,
                isolationFromStartOfDay: .today
            )
        )
        
        // When
        store.isolationStateInfo = store.newIsolationStateInfo(
            from: isolationInfo,
            for: .negative,
            testKitType: .labResult,
            requiresConfirmatoryTest: false,
            receivedOn: testDay,
            npexDay: npexDayCompleted,
            operation: .completeAndDeleteSymptoms
        )
        
        // THEN
        XCTAssertNotNil(store.isolationStateInfo?.isolationInfo.contactCaseInfo)
        XCTAssertNil(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.symptomaticInfo)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.receivedOnDay, testDay.advanced(by: -4))
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.requiresConfirmatoryTest, true)
        XCTAssertNil(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.confirmedOnDay)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.completedOnDay, npexDayCompleted)
    }
    
    func testOverwriteAndCompleteTestResultOperation() {
        let negativeTestEndDay = GregorianDay(year: 2020, month: 7, day: 13)
        let positiveTestEndDay = GregorianDay(year: 2020, month: 7, day: 10)
        let selfDiagnosisDay = GregorianDay(year: 2020, month: 7, day: 9)
        
        // Given
        let isolationInfo = IsolationInfo(
            hasAcknowledgedEndOfIsolation: false,
            hasAcknowledgedStartOfContactIsolation: false,
            indexCaseInfo: IndexCaseInfo(
                symptomaticInfo: IndexCaseInfo.SymptomaticInfo(selfDiagnosisDay: selfDiagnosisDay, onsetDay: selfDiagnosisDay),
                testInfo: IndexCaseInfo.TestInfo(result: .negative, requiresConfirmatoryTest: false, receivedOnDay: negativeTestEndDay, testEndDay: negativeTestEndDay)
            ),
            contactCaseInfo: nil
        )
        
        // When
        store.isolationStateInfo = store.newIsolationStateInfo(
            from: isolationInfo,
            for: .positive,
            testKitType: .rapidResult,
            requiresConfirmatoryTest: true,
            receivedOn: negativeTestEndDay,
            npexDay: positiveTestEndDay,
            operation: .overwriteAndComplete
        )
        
        // Then
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.receivedOnDay, negativeTestEndDay)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.requiresConfirmatoryTest, true)
        XCTAssertNil(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.confirmedOnDay)
        XCTAssertNil(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.symptomaticInfo)
        XCTAssertEqual(store.isolationStateInfo?.isolationInfo.indexCaseInfo?.testInfo?.completedOnDay, negativeTestEndDay)
    }
}
