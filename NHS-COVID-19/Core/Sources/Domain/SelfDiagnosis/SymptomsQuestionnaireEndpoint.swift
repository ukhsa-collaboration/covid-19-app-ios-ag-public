//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct SymptomsQuestionnaireEndpoint: HTTPEndpoint {
    
    func request(for input: Void) throws -> HTTPRequest {
        .get("/distribution/symptomatic-questionnaire")
    }
    
    func parse(_ response: HTTPResponse) throws -> SymptomsQuestionnaire {
        let payload = try JSONDecoder().decode(Payload.self, from: response.body.content)
        
        return SymptomsQuestionnaire(
            symptoms: payload.symptoms,
            cardinal: payload.cardinal,
            noncardinal: payload.noncardinal,
            riskThreshold: payload.riskThreshold,
            dateSelectionWindow: payload.symptomsOnsetWindowDays
        )
    }
}

private struct Payload: Decodable {
    public var symptoms: [Symptom]
    public var cardinal: CardinalSymptom
    public var noncardinal: NonCardinalSymptom
    public var riskThreshold: Double
    public var symptomsOnsetWindowDays: Int
}
