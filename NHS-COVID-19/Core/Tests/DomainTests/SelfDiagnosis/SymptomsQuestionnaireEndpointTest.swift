//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import TestSupport
import XCTest
@testable import Domain

class SymptomsQuestionnaireEndpointTests: XCTestCase {
    
    private let endpoint = SymptomsQuestionnaireEndpoint()
    
    func testEndpoint() throws {
        let expected = HTTPRequest.get("/distribution/symptomatic-questionnaire")
        
        let actual = try endpoint.request(for: ())
        
        TS.assert(actual, equals: expected)
    }
    
    func testDecodingEmptyList() throws {
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "symptoms": [],
            "cardinal": {
              "title": {
                "en": "Do you have a high temperature?",
              }
            },
            "noncardinal": {
              "title": {
                "en": "Do you have any of these symptoms?",
              },
              "description": {
                "en": "Shivering or chills",
              }
            },
            "riskThreshold": 0.5,
            "symptomsOnsetWindowDays": 14
        }
        """#))
        
        let questionnaire = try endpoint.parse(response)
        
        TS.assert(questionnaire.riskThreshold, equals: 0.5)
        TS.assert(questionnaire.dateSelectionWindow, equals: 14)
        XCTAssert(questionnaire.symptoms.isEmpty)
    }
    
    func testDecodingSymptomList() throws {
        let title1en = String.random()
        let description1en = String.random()
        let title1de = String.random()
        let description1de = String.random()
        let title2 = String.random()
        let description2 = String.random()
        
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "symptoms": [
              {
                "title": {
                  "en-GB": "\#(title1en)",
                  "de-DE": "\#(title1de)"
                },
                "description": {
                  "en-GB": "\#(description1en)",
                  "de-DE": "\#(description1de)"
                },
                "riskWeight": 1
              },
              {
                "title": {
                  "en-GB": "\#(title2)"
                },
                "description": {
                  "en-GB": "\#(description2)"
                },
                "riskWeight": 0
              }
            ],
            "cardinal": {
              "title": {
                "en": "",
              }
            },
            "noncardinal": {
              "title": {
                "en": "",
              },
              "description": {
                "en": "",
              }
            },
            "riskThreshold": 0.8,
            "symptomsOnsetWindowDays": 14
        }
        """#))
        
        let expected = SymptomsQuestionnaire(
            symptoms: [
                Symptom(
                    title: [Locale(identifier: "en-GB"): title1en, Locale(identifier: "de-DE"): title1de],
                    description: [Locale(identifier: "en-GB"): description1en, Locale(identifier: "de-DE"): description1de],
                    riskWeight: 1
                ),
                Symptom(
                    title: [Locale(identifier: "en-GB"): title2],
                    description: [Locale(identifier: "en-GB"): description2],
                    riskWeight: 0
                ),
            ],
            cardinal: CardinalSymptom(title: LocaleString(dictionaryLiteral: (Locale(identifier: "en"), ""))),
            noncardinal: NonCardinalSymptom(
                title: LocaleString(dictionaryLiteral: (Locale(identifier: "en"), "")),
                description: LocaleString(dictionaryLiteral: (Locale(identifier: "en"), ""))
            ),
            riskThreshold: 0.8,
            dateSelectionWindow: 14
        )
        
        let actual = try endpoint.parse(response)
        
        TS.assert(actual, equals: expected)
    }
}
