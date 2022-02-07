//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Domain
import Foundation

class SandboxEncryptedStore: EncryptedStoring {
    
    fileprivate var stored = [String: Data]()
    private let host: SandboxHost
    
    init(host: SandboxHost) {
        self.host = host
        
        if let postcode = host.initialState.postcode,
            let localAuthorityId = host.initialState.localAuthorityId {
            stored["postcode"] = """
            {
                "postcode": "\(postcode)",
                "localAuthorityId": "\(localAuthorityId)"
            }
            """.data(using: .utf8)!
        } else if let postcode = host.initialState.postcode {
            stored["postcode"] = """
            { "postcode": "\(postcode)" }
            """.data(using: .utf8)!
        }
        
        let endDate = host.initialState.testResultEndDateString ?? "610531200"
        
        if let testResult = host.initialState.testResult {
            if testResult == "positive" {
                stored["virology_testing"] = #"""
                {
                    "unacknowledgedTestResults":[
                        {
                            "result":"\#(testResult)",
                            "endDate":\#(endDate),
                            "diagnosisKeySubmissionToken":"\#(UUID().uuidString)",
                            "requiresConfirmatoryTest": \#(host.initialState.requiresConfirmatoryTest)
                        }
                    ]
                }
                """# .data(using: .utf8)
            } else {
                stored["virology_testing"] = #"""
                {
                    "unacknowledgedTestResults":[
                        {
                            "result":"\#(testResult)",
                            "endDate":\#(endDate),
                            "requiresConfirmatoryTest": \#(host.initialState.requiresConfirmatoryTest)
                        }
                    ]
                }
                """# .data(using: .utf8)
            }
        }
        
        stored["policy_version"] = """
        { "lastAcceptedWithAppVersion": "\(host.initialState.lastAcceptedWithAppVersion)" }
        """.data(using: .utf8)!
        
        saveIsolationState()
        saveIsolationPaymentState()
        
        if host.initialState.riskyVenueMessageType != nil {
            saveRiskyVenue()
        }
        
        if host.initialState.hasCheckIns {
            saveCheckIns()
        }
    }
    
    func saveIsolationState() {
        guard let isolationCase = Sandbox.Text.IsolationCase(rawValue: host.initialState.isolationCase) else { return }
        switch isolationCase {
        case .none:
            return
        case .index:
            let selfDiagnosisDay = GregorianDay.today.advanced(by: -1)
            stored["isolation_state_info"] = #"""
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
                    "hasAcknowledgedStartOfIsolation": true,
                    "indexCaseInfo" : {
                        "selfDiagnosisDay" : {
                            "day" : \#(selfDiagnosisDay.day),
                            "month" : \#(selfDiagnosisDay.month),
                            "year" : \#(selfDiagnosisDay.year)
                        }
                    }
                }
            }
            """# .data(using: .utf8)!
        case .indexWithPositiveTest:
            let testEndDay = GregorianDay.today.advanced(by: -2)
            stored["isolation_state_info"] = #"""
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
                "test" : {
                    "testResult" : "positive",
                    "requiresConfirmatoryTest" : false,
                    "acknowledgedDay" : {
                        "day" : \#(testEndDay.day),
                        "month" : \#(testEndDay.month),
                        "year" : \#(testEndDay.year)
                    },
                    "testEndDay" : {
                        "day" : \#(testEndDay.day),
                        "month" : \#(testEndDay.month),
                        "year" : \#(testEndDay.year)
                    }
                }
            }
            """# .data(using: .utf8)!
        case .contact:
            let exposureDay = GregorianDay.today.advanced(by: -Sandbox.Config.Isolation.daysSinceReceivingExposureNotification)
            let isolationFromStartOfDay = GregorianDay.today.advanced(by: -1)
            stored["isolation_state_info"] = #"""
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
                    "hasAcknowledgedStartOfIsolation": \#(host.initialState.hasAcknowledgedStartOfIsolation),
                    "contactCaseInfo" : {
                        "exposureDay" : {
                            "day" : \#(exposureDay.day),
                            "month" : \#(exposureDay.month),
                            "year" : \#(exposureDay.year)
                        },
                        "isolationFromStartOfDay":{
                            "year": \#(isolationFromStartOfDay.year),
                            "month": \#(isolationFromStartOfDay.month),
                            "day": \#(isolationFromStartOfDay.day)
                        }
                    }
                }
            }
            """# .data(using: .utf8)!
        case .indexAndContact:
            let startOfIsolationday = GregorianDay.today.advanced(by: -Sandbox.Config.Isolation.daysSinceReceivingExposureNotification)
            
            stored["isolation_state_info"] = #"""
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
                    "hasAcknowledgedStartOfIsolation": \#(host.initialState.hasAcknowledgedStartOfIsolation),
                    "indexCaseInfo" : {
                        "selfDiagnosisDay" : {
                            "day" : \#(startOfIsolationday.day),
                            "month" : \#(startOfIsolationday.month),
                            "year" : \#(startOfIsolationday.year)
                        }
                    },
                    "contactCaseInfo" : {
                        "exposureDay" : {
                            "day" : \#(startOfIsolationday.day),
                            "month" : \#(startOfIsolationday.month),
                            "year" : \#(startOfIsolationday.year)
                        },
                        "isolationFromStartOfDay":{
                            "year": \#(startOfIsolationday.year),
                            "month": \#(startOfIsolationday.month),
                            "day": \#(startOfIsolationday.day)
                        }
                    }
                }
            }
            """# .data(using: .utf8)!
        }
    }
    
    func saveIsolationPaymentState() {
        guard let isolationPaymentState = Sandbox.Text.IsolationPaymentState(rawValue: host.initialState.isolationPaymentState) else { return }
        switch isolationPaymentState {
        case .disabled: break
        case .enabled:
            stored["isolation_payment_store"] = #"""
            {
                "isEnabled" : true,
                "ipcToken": "\#(UUID().uuidString)"
            }
            """# .data(using: .utf8)!
        }
    }
    
    func saveRiskyVenue() {
        guard let messageType = host.initialState.riskyVenueMessageType else {
            return
        }
        
        let checkInDay = GregorianDay.today
        let venueId = UUID().uuidString
        stored["checkins"] = #"""
        {
            "checkIns": [
                {
                    "venueId" : "\#(venueId)",
                    "venueName" : "Venue",
                    "checkedIn" : {
                        "day" : {
                            "year" : \#(checkInDay.year),
                            "month" : \#(checkInDay.month),
                            "day" : \#(checkInDay.day)
                        },
                        "hour" : 5,
                        "minutes": 0
                    },
                    "checkedOut" : {
                        "day" : {
                            "year" : \#(checkInDay.year),
                            "month" : \#(checkInDay.month),
                            "day" : \#(checkInDay.day)
                        },
                        "hour" : 7,
                        "minutes": 0
                    },
                    "circuitBreakerApproval" : "pending",
                    "isRisky" : true,
                    "id": "\#(UUID().uuidString)",
                    "venueMessageType": "\#(messageType)",
                }
            ],
            "riskApprovalTokens": {},
            "unacknowldegedRiskyVenueIds": ["\#(venueId)"],
        }
        """# .data(using: .utf8)!
    }
    
    func saveCheckIns() {
        let checkInDay = GregorianDay.today
        
        stored["checkins"] = #"""
        {
            "checkIns": [
                {
                    "venueId" : "12345",
                    "venueName" : "Venue 1",
                    "venuePostcode" : "S1",
                    "checkedIn" : {
                        "day" : {
                            "year" : \#(checkInDay.year),
                            "month" : \#(checkInDay.month),
                            "day" : \#(checkInDay.day)
                        },
                        "hour" : 5,
                        "minutes": 0
                    },
                    "checkedOut" : {
                        "day" : {
                            "year" : \#(checkInDay.year),
                            "month" : \#(checkInDay.month),
                            "day" : \#(checkInDay.day)
                        },
                        "hour" : 7,
                        "minutes": 0
                    },
                    "circuitBreakerApproval" : "pending",
                    "isRisky" : false,
                    "id": "\#(UUID().uuidString)",
                }
            ],
            "riskApprovalTokens": {},
            "unacknowldegedRiskyVenueIds": [],
        }
        """# .data(using: .utf8)!
    }
    
    func dataEncryptor(_ name: String) -> DataEncrypting {
        SandboxEncryptor(store: self, name: name)
    }
    
}

private struct SandboxEncryptor: DataEncrypting {
    
    var store: SandboxEncryptedStore
    var name: String
    
    var wrappedValue: Data? {
        get {
            store.stored[name]
        }
        nonmutating set {
            store.stored[name] = newValue
        }
    }
    
    var hasValue: Bool {
        wrappedValue != nil
    }
    
}
