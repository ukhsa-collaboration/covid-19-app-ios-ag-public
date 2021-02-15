//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Domain
import Foundation

class SandboxEncryptedStore: EncryptedStoring {
    
    fileprivate var stored = [String: Data]()
    private let host: SandboxHost
    
    init(host: SandboxHost) {
        self.host = host
        if host.initialState.isPilotActivated {
            stored["activation"] = """
            { "isActivated": true }
            """.data(using: .utf8)
        }
        
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
        }
        
        stored["policy_version"] = """
        { "lastAcceptedWithAppVersion": "\(host.initialState.lastAcceptedWithAppVersion)" }
        """.data(using: .utf8)!
        
        saveIsolationState()
        saveIsolationPaymentState()
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
        case .contact:
            let exposureDay = GregorianDay.today.advanced(by: -2)
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
                    "hasAcknowledgedStartOfIsolation": true,
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
