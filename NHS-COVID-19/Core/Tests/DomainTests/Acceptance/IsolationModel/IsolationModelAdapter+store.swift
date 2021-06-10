//
// Copyright © 2021 DHSC. All rights reserved.
//

import BehaviourModels
import Common
import Domain
import Foundation

extension IsolationModelAdapter {
    
    func storeRepresentations(for state: IsolationModel.State) throws -> [String] {
        try contactCaseInfoRepresentations(for: state).flatMap { contactCaseInfo in
            try indexCaseInfoRepresentations(for: state).lazy.map { indexCaseInfo in
                isolationJSON {
                    """
                    "hasAcknowledgedEndOfIsolation": \(endOfIsolationAcknowledged(for: state)),
                    "hasAcknowledgedStartOfIsolation": false,
                    \(object(named: "contactCaseInfo", content: contactCaseInfo))
                    \(contactCaseInfo != nil ? "," : "")
                    \(object(named: "indexCaseInfo", content: indexCaseInfo))
                    """
                }
            }
        }
    }
    
    private func contactCaseInfoRepresentations(for state: IsolationModel.State) throws -> [String?] {
        switch state.contact {
        case .noIsolation:
            return [
                nil,
            ]
        case .isolating:
            return [
                contactCaseWithoutDCT(exposureDay: contactCase.exposureDay, isolationFromDay: contactCase.contactIsolationFromStartOfDay),
            ]
            
        case .notIsolatingAndHadRiskyContactIsolationTerminatedDueToDCT:
            return [
                """
                    "exposureDay" : {
                        "day" : \(contactCase.exposureDay.day),
                        "month" : \(contactCase.exposureDay.month),
                        "year" : \(contactCase.exposureDay.year)
                    },
                    "isolationFromStartOfDay":{
                        "year": \(contactCase.contactIsolationFromStartOfDay.year),
                        "month": \(contactCase.contactIsolationFromStartOfDay.month),
                        "day": \(contactCase.contactIsolationFromStartOfDay.day)
                    },
                    "optOutOfIsolationDay":{
                        "year": \(contactCase.optedOutForDCTDay.year),
                        "month": \(contactCase.optedOutForDCTDay.month),
                        "day": \(contactCase.optedOutForDCTDay.day)
                    }
                """,
            ]
        case .notIsolatingAndHadRiskyContactPreviously:
            return [
                contactCaseWithoutDCT(exposureDay: contactCase.expiredExposureDay, isolationFromDay: contactCase.expiredIsolationFromStartOfDay),
            ]
        }
    }
    
    private func contactCaseWithoutDCT(exposureDay: GregorianDay, isolationFromDay: GregorianDay) -> String {
        return """
            "exposureDay" : {
                "day" : \(exposureDay.day),
                "month" : \(exposureDay.month),
                "year" : \(exposureDay.year)
            },
            "isolationFromStartOfDay":{
                "year": \(isolationFromDay.year),
                "month": \(isolationFromDay.month),
                "day": \(isolationFromDay.day)
            }
        """
    }
    
    private func indexCaseInfoRepresentations(for state: IsolationModel.State) throws -> [String?] {
        switch (state.symptomatic, state.positiveTest) {
        case (.noIsolation, .noIsolation):
            return [
                nil,
            ]
        case (.noIsolation, .isolatingWithConfirmedTest):
            return [
                testCaseRepresentation(
                    testEndDay: testCase.testEndDay,
                    receivedOnDay: testCase.receivedOnDay
                ),
            ]
        case (.noIsolation, .isolatingWithUnconfirmedTest):
            return [
                testCaseRepresentation(
                    testEndDay: testCase.testEndDay,
                    receivedOnDay: testCase.receivedOnDay,
                    isPendingConfirmation: true
                ),
            ]
        case (.noIsolation, .notIsolatingAndHadConfirmedTestPreviously):
            return [
                testCaseRepresentation(
                    testEndDay: testCase.expiredTestEndDay,
                    receivedOnDay: testCase.expiredReceivedOnDay
                ),
            ]
        case (.noIsolation, .notIsolatingAndHadUnconfirmedTestPreviously):
            return [
                testCaseRepresentation(
                    testEndDay: testCase.expiredTestEndDay,
                    receivedOnDay: testCase.expiredReceivedOnDay,
                    isPendingConfirmation: true
                ),
            ]
        case (.noIsolation, .notIsolatingAndHasNegativeTest):
            return [
                testCaseRepresentation(
                    testEndDay: testCase.testEndDay,
                    receivedOnDay: testCase.receivedOnDay,
                    result: "negative"
                ),
            ]
        case (.isolating, .noIsolation):
            return [
                symptomaticCaseRepresentation(selfDiagnosisDay: symptomaticCase.selfDiagnosisDay, onsetDay: symptomaticCase.onsetDay),
            ]
        case (.isolating, .isolatingWithConfirmedTest):
            return [
                symptomaticAndTestCaseRepresentation(selfDiagnosisDay: symptomaticCase.selfDiagnosisDay, testEndDay: testCase.testEndDay, receivedOnDay: testCase.receivedOnDay),
            ]
        case (.isolating, .isolatingWithUnconfirmedTest):
            return [
                symptomaticAndTestCaseRepresentation(selfDiagnosisDay: symptomaticCase.selfDiagnosisDay, testEndDay: testCase.testEndDay, receivedOnDay: testCase.receivedOnDay, isPendingConfirmation: true),
            ]
        case (.isolating, .notIsolatingAndHadConfirmedTestPreviously):
            return [
                symptomaticAndTestCaseRepresentation(selfDiagnosisDay: symptomaticCase.selfDiagnosisDay, testEndDay: testCase.expiredTestEndDay, receivedOnDay: testCase.expiredReceivedOnDay),
            ]
        case (.isolating, .notIsolatingAndHadUnconfirmedTestPreviously):
            return [
                symptomaticAndTestCaseRepresentation(selfDiagnosisDay: symptomaticCase.selfDiagnosisDay, testEndDay: testCase.expiredTestEndDay, receivedOnDay: testCase.expiredReceivedOnDay, isPendingConfirmation: true),
            ]
        case (.isolating, .notIsolatingAndHasNegativeTest):
            return [
                symptomaticAndTestCaseRepresentation(selfDiagnosisDay: symptomaticCase.selfDiagnosisDay, testEndDay: testCase.testEndDay, receivedOnDay: testCase.receivedOnDay, result: "negative"),
            ]
        case (.notIsolatingAndHadSymptomsPreviously, .noIsolation):
            return [
                symptomaticCaseRepresentation(selfDiagnosisDay: symptomaticCase.expiredSelfDiagnosisDay),
            ]
        case (.notIsolatingAndHadSymptomsPreviously, .isolatingWithConfirmedTest):
            return [
                symptomaticAndTestCaseRepresentation(selfDiagnosisDay: symptomaticCase.expiredSelfDiagnosisDay, testEndDay: testCase.testEndDay, receivedOnDay: testCase.receivedOnDay),
            ]
        case (.notIsolatingAndHadSymptomsPreviously, .isolatingWithUnconfirmedTest):
            return [
                symptomaticAndTestCaseRepresentation(selfDiagnosisDay: symptomaticCase.expiredSelfDiagnosisDay, testEndDay: testCase.testEndDay, receivedOnDay: testCase.receivedOnDay, isPendingConfirmation: true),
            ]
        case (.notIsolatingAndHadSymptomsPreviously, .notIsolatingAndHadConfirmedTestPreviously):
            return [
                symptomaticAndTestCaseRepresentation(selfDiagnosisDay: symptomaticCase.expiredSelfDiagnosisDay, testEndDay: testCase.expiredTestEndDay, receivedOnDay: testCase.expiredReceivedOnDay),
            ]
        case (.notIsolatingAndHadSymptomsPreviously, .notIsolatingAndHadUnconfirmedTestPreviously):
            return [
                symptomaticAndTestCaseRepresentation(selfDiagnosisDay: symptomaticCase.expiredSelfDiagnosisDay, testEndDay: testCase.expiredTestEndDay, receivedOnDay: testCase.expiredReceivedOnDay, isPendingConfirmation: true),
            ]
        case (.notIsolatingAndHadSymptomsPreviously, .notIsolatingAndHasNegativeTest):
            return [
                symptomaticAndTestCaseRepresentation(selfDiagnosisDay: symptomaticCase.selfDiagnosisDay, testEndDay: testCase.testEndDay, receivedOnDay: testCase.receivedOnDay, result: "negative"),
            ]
        }
    }
    
    private func symptomaticCaseRepresentation(selfDiagnosisDay: GregorianDay, onsetDay: GregorianDay? = nil) -> String {
        var json = """
            "selfDiagnosisDay" : {
                "day" : \(selfDiagnosisDay.day),
                "month" : \(selfDiagnosisDay.month),
                "year" : \(selfDiagnosisDay.year)
            }
        """
        
        if let onsetDay = onsetDay {
            json += """
                ,
                "onsetDay" : {
                    "day" : \(onsetDay.day),
                    "month" : \(onsetDay.month),
                    "year" : \(onsetDay.year)
                }
            """
        }
        
        return json
    }
    
    private func testCaseRepresentation(
        testEndDay: GregorianDay,
        receivedOnDay: GregorianDay,
        result: String = "positive",
        isPendingConfirmation: Bool = false
    ) -> String {
        return """
            "npexDay" : {
                "day" : \(testEndDay.day),
                "month" : \(testEndDay.month),
                "year" : \(testEndDay.year)
            },
            "testInfo": {
                "result" : "\(result)",
                "testKitType": "labResult",
                "requiresConfirmatoryTest": \(isPendingConfirmation),
                "receivedOnDay" : {
                    "day" : \(receivedOnDay.day),
                    "month" : \(receivedOnDay.month),
                    "year" : \(receivedOnDay.year)
                }
            }
        """
    }
    
    private func symptomaticAndTestCaseRepresentation(
        selfDiagnosisDay: GregorianDay,
        onsetDay: GregorianDay? = nil,
        testEndDay: GregorianDay,
        receivedOnDay: GregorianDay,
        result: String = "positive",
        isPendingConfirmation: Bool = false
    ) -> String {
        return [
            symptomaticCaseRepresentation(
                selfDiagnosisDay: selfDiagnosisDay,
                onsetDay: onsetDay
            ),
            testCaseRepresentation(
                testEndDay: testEndDay,
                receivedOnDay: receivedOnDay,
                result: result,
                isPendingConfirmation: isPendingConfirmation
            ),
        ].joined(separator: ",")
    }
    
    private func endOfIsolationAcknowledged(for state: IsolationModel.State) -> String {
        switch (state.contact, state.symptomatic, state.positiveTest) {
        case (.notIsolatingAndHadRiskyContactIsolationTerminatedDueToDCT, .noIsolation, .noIsolation),
             (.notIsolatingAndHadRiskyContactIsolationTerminatedDueToDCT, .notIsolatingAndHadSymptomsPreviously, .noIsolation),
             (.notIsolatingAndHadRiskyContactIsolationTerminatedDueToDCT, .notIsolatingAndHadSymptomsPreviously, .notIsolatingAndHadConfirmedTestPreviously),
             (.notIsolatingAndHadRiskyContactIsolationTerminatedDueToDCT, .notIsolatingAndHadSymptomsPreviously, .notIsolatingAndHasNegativeTest),
             (.notIsolatingAndHadRiskyContactIsolationTerminatedDueToDCT, .noIsolation, .notIsolatingAndHadConfirmedTestPreviously),
             (.notIsolatingAndHadRiskyContactIsolationTerminatedDueToDCT, .noIsolation, .notIsolatingAndHadUnconfirmedTestPreviously),
             (.notIsolatingAndHadRiskyContactIsolationTerminatedDueToDCT, .noIsolation, .notIsolatingAndHasNegativeTest),
             (.notIsolatingAndHadRiskyContactIsolationTerminatedDueToDCT, .notIsolatingAndHadSymptomsPreviously, .notIsolatingAndHadUnconfirmedTestPreviously):
            return "true"
        default:
            return "false"
        }
    }
    
    private func isolationJSON(with isolationInfoLines: () -> String) -> String {
        """
        {
            "configuration" : {
                "indexCaseSinceSelfDiagnosisOnset" : 7,
                "maxIsolation" : 21,
                "contactCase" : 14,
                "indexCaseSinceSelfDiagnosisUnknownOnset" : 5,
                "housekeepingDeletionPeriod" : 14
            },
            "isolationInfo" : {
                \(isolationInfoLines())
            }
        }
        """
    }
    
    private func object(named name: String, content: String?) -> String {
        guard let content = content else { return "" }
        return """
        \"\(name)\": {
        \(content)
        }
        """
    }
    
}
