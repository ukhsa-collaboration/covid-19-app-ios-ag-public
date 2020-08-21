//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation

class SandboxDistributeClient: HTTPClient {
    private let queue = DispatchQueue(label: "sandbox-distribution-client")
    
    public func perform(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, HTTPRequestError> {
        _perform(request).publisher
            .receive(on: queue)
            .eraseToAnyPublisher()
    }
    
    private func _perform(_ request: HTTPRequest) -> Result<HTTPResponse, HTTPRequestError> {
        if request.path == "/distribution/symptomatic-questionnaire" {
            return Result.success(.ok(with: .json(questionnaire)))
        }
        if request.path == "/distribution/self-isolation" {
            return Result.success(.ok(with: .json(isolationConfig)))
        }
        return Result.failure(.rejectedRequest(underlyingError: SimpleError("")))
    }
}

private let isolationConfig = """
{
  "durationDays": {
    "indexCaseSinceSelfDiagnosisOnset": 1,
    "indexCaseSinceSelfDiagnosisUnknownOnset": \(Sandbox.Config.Isolation.indexCaseSinceSelfDiagnosisUnknownOnset),
    "contactCase": 3,
    "maxIsolation": \(Sandbox.Config.Isolation.indexCaseSinceSelfDiagnosisUnknownOnset)
  }
}

"""

private let questionnaire = """
{
  "symptoms": [
    {
      "title": {
        "en-GB": "\(Sandbox.Text.SymptomsList.cardHeading.rawValue)"
      },
      "description": {
        "en-GB": "\(Sandbox.Text.SymptomsList.cardContent.rawValue)"
      },
      "riskWeight": 1
    }
  ],
  "riskThreshold": 0.5,
  "symptomsOnsetWindowDays": 5
}
"""
