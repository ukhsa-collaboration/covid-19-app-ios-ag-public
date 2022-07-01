//
// Copyright © 2021 DHSC. All rights reserved.
//

import BehaviourModels
import Common
import Domain
import Foundation

extension IsolationModelAdapter {

    func storeRepresentations(for state: IsolationModel.State) throws -> [String] {
        try contactRepresentations(for: state).flatMap { contact in
            try symptomaticRepresentation(for: state).flatMap { symptomatic in
                try testRepresentation(for: state).lazy.map { test in
                    isolationJSON {
                        """
                        "hasAcknowledgedEndOfIsolation": \(endOfIsolationAcknowledged(for: state)),
                        \(object(named: "contact", content: contact))
                        \(contact != nil ? "," : "")
                        \(object(named: "symptomatic", content: symptomatic))
                        \(symptomatic != nil ? "," : "")
                        \(object(named: "test", content: test))
                        """
                    }
                }
            }
        }
    }

    private func contactRepresentations(for state: IsolationModel.State) throws -> [String?] {
        switch state.contact {
        case .noIsolation:
            return [
                nil,
            ]
        case .isolating:
            return [
                contactCaseWithoutIsolationOptOut(exposureDay: contactCase.exposureDay, isolationFromDay: contactCase.contactIsolationFromStartOfDay),
            ]

        case .notIsolatingAndHadRiskyContactIsolationTerminatedEarly:
            return [
                """
                    "hasAcknowledgedStartOfIsolation": false,
                    "exposureDay" : {
                        "day" : \(contactCase.exposureDay.day),
                        "month" : \(contactCase.exposureDay.month),
                        "year" : \(contactCase.exposureDay.year)
                    },
                    "notificationDay":{
                        "year": \(contactCase.contactIsolationFromStartOfDay.year),
                        "month": \(contactCase.contactIsolationFromStartOfDay.month),
                        "day": \(contactCase.contactIsolationFromStartOfDay.day)
                    },
                    "isolationOptOutInfo": {
                        "fromDay": {
                            "year": \(contactCase.optedOutIsolation.year),
                            "month": \(contactCase.optedOutIsolation.month),
                            "day": \(contactCase.optedOutIsolation.day)
                        }
                    }
                """,
            ]
        case .notIsolatingAndHadRiskyContactPreviously:
            return [
                contactCaseWithoutIsolationOptOut(exposureDay: contactCase.expiredExposureDay, isolationFromDay: contactCase.expiredIsolationFromStartOfDay),
            ]
        }
    }

    private func contactCaseWithoutIsolationOptOut(exposureDay: GregorianDay, isolationFromDay: GregorianDay) -> String {
        return """
            "hasAcknowledgedStartOfIsolation": false,
            "exposureDay" : {
                "day" : \(exposureDay.day),
                "month" : \(exposureDay.month),
                "year" : \(exposureDay.year)
            },
            "notificationDay":{
                "year": \(isolationFromDay.year),
                "month": \(isolationFromDay.month),
                "day": \(isolationFromDay.day)
            }
        """
    }

    private func symptomaticRepresentation(for state: IsolationModel.State) throws -> [String?] {
        switch state.symptomatic {
        case .noIsolation:
            return [
                nil,
            ]
        case .isolating:
            return [
                symptomaticCaseRepresentation(selfDiagnosisDay: symptomaticCase.selfDiagnosisDay, onsetDay: symptomaticCase.onsetDay),
            ]
        case .notIsolatingAndHadSymptomsPreviously:
            return [
                symptomaticCaseRepresentation(selfDiagnosisDay: symptomaticCase.expiredSelfDiagnosisDay),
            ]
        }
    }

    private func testRepresentation(for state: IsolationModel.State) throws -> [String?] {
        switch state.positiveTest {
        case .noIsolation:
            return [
                nil,
            ]
        case .isolatingWithConfirmedTest:
            return [
                testCaseRepresentation(
                    testEndDay: testCase.testEndDay,
                    receivedOnDay: testCase.receivedOnDay
                ),
            ]
        case .isolatingWithUnconfirmedTest:
            return [
                testCaseRepresentation(
                    testEndDay: testCase.testEndDay,
                    receivedOnDay: testCase.receivedOnDay,
                    isPendingConfirmation: true,
                    confirmatoryDayLimit: 2
                ),
            ]
        case .notIsolatingAndHadConfirmedTestPreviously:
            return [
                testCaseRepresentation(
                    testEndDay: testCase.expiredTestEndDay,
                    receivedOnDay: testCase.expiredReceivedOnDay
                ),
            ]
        case .notIsolatingAndHadUnconfirmedTestPreviously:
            return [
                testCaseRepresentation(
                    testEndDay: testCase.expiredTestEndDay,
                    receivedOnDay: testCase.expiredReceivedOnDay,
                    isPendingConfirmation: true,
                    confirmatoryDayLimit: 2
                ),
            ]
        case .notIsolatingAndHasNegativeTest:
            return [
                testCaseRepresentation(
                    testEndDay: testCase.testEndDay,
                    receivedOnDay: testCase.receivedOnDay,
                    result: "negative"
                ),
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
        isPendingConfirmation: Bool = false,
        confirmatoryDayLimit: Int? = nil
    ) -> String {
        return """
            "testEndDay" : {
                "day" : \(testEndDay.day),
                "month" : \(testEndDay.month),
                "year" : \(testEndDay.year)
            },
            "testResult" : "\(result)",
            "testKitType": "labResult",
            "requiresConfirmatoryTest": \(isPendingConfirmation),
            "acknowledgedDay" : {
                "day" : \(receivedOnDay.day),
                "month" : \(receivedOnDay.month),
                "year" : \(receivedOnDay.year)
            },
            \(value(named: "confirmatoryDayLimit", content: confirmatoryDayLimit))
        """
    }

    private func endOfIsolationAcknowledged(for state: IsolationModel.State) -> String {
        switch (state.contact, state.symptomatic, state.positiveTest) {
        case (.notIsolatingAndHadRiskyContactIsolationTerminatedEarly, .noIsolation, .noIsolation),
             (.notIsolatingAndHadRiskyContactIsolationTerminatedEarly, .notIsolatingAndHadSymptomsPreviously, .noIsolation),
             (.notIsolatingAndHadRiskyContactIsolationTerminatedEarly, .notIsolatingAndHadSymptomsPreviously, .notIsolatingAndHadConfirmedTestPreviously),
             (.notIsolatingAndHadRiskyContactIsolationTerminatedEarly, .notIsolatingAndHadSymptomsPreviously, .notIsolatingAndHasNegativeTest),
             (.notIsolatingAndHadRiskyContactIsolationTerminatedEarly, .noIsolation, .notIsolatingAndHadConfirmedTestPreviously),
             (.notIsolatingAndHadRiskyContactIsolationTerminatedEarly, .noIsolation, .notIsolatingAndHadUnconfirmedTestPreviously),
             (.notIsolatingAndHadRiskyContactIsolationTerminatedEarly, .noIsolation, .notIsolatingAndHasNegativeTest),
             (.notIsolatingAndHadRiskyContactIsolationTerminatedEarly, .notIsolatingAndHadSymptomsPreviously, .notIsolatingAndHadUnconfirmedTestPreviously):
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
            "version": 2,
            \(isolationInfoLines())
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

    private func value(named name: String, content: Int?) -> String {
        guard let content = content else {
            return """
                \"\(name)\": null
            """
        }

        return """
        \"\(name)\": \(String(describing: content))
        """
    }

}
