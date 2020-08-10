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
            riskThreshold: payload.riskThreshold,
            dateSelectionWindow: payload.symptomsOnsetWindowDays
        )
    }
}

private struct Payload: Codable {
    public var symptoms: [Symptom]
    public var riskThreshold: Double
    public var symptomsOnsetWindowDays: Int
}
