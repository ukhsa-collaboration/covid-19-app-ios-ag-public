//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation

class MockServer: HTTPClient {
    
    private let queue = DispatchQueue(label: "MockServer")
    
    var requestCount = 0
    
    private let dataProvider: MockDataProvider
    
    init(dataProvider: MockDataProvider = MockScenario.mockDataProvider) {
        self.dataProvider = dataProvider
    }
    
    struct TestError: Error {}
    var cancellables = [AnyCancellable]()
    
    func perform(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, HTTPRequestError> {
        _perform(request).regulate(as: .simulatedNetwork)
    }
    
    func _perform(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, HTTPRequestError> {
        requestCount += 1
        
        if request.path == "/distribution/risky-post-districts" {
            let highRiskPostcodes = dataProvider.highRiskPostcodes.components(separatedBy: ",")
                .lazy
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .map { "\"\($0)\": \"H\"" }
                .joined(separator: ",")
            
            let mediumRiskPostcodes = dataProvider.mediumRiskPostcodes.components(separatedBy: ",")
                .lazy
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .map { "\"\($0)\": \"M\"" }
                .joined(separator: ",")
            
            let lowRiskPostcodes = dataProvider.lowRiskPostcodes.components(separatedBy: ",")
                .lazy
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .map { "\"\($0)\": \"L\"" }
                .joined(separator: ",")
            
            let json = #"""
            {
                "postDistricts" : { \#(highRiskPostcodes), \#(mediumRiskPostcodes), \#(lowRiskPostcodes) }
            }
            """#
            return Result.success(.ok(with: .json(json))).publisher.eraseToAnyPublisher()
        }
        
        if request.path == "/distribution/risky-venues" {
            let riskyVenues = dataProvider.riskyVenueIDs.components(separatedBy: ",")
                .lazy
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .map { #"""
                {
                    "id": "\#($0)",
                    "riskyWindow": {
                      "from": "2019-07-04T13:33:03Z",
                      "until": "2029-07-04T23:59:03Z"
                    }
                }
                """#
                }
                .joined(separator: ",")
            let json = #"""
                {
                    "venues" : [
                        \#(riskyVenues)
                    ]
                }
            """#
            return Result.success(.ok(with: .json(json))).publisher.eraseToAnyPublisher()
        }
        
        if request.path == "/distribution/symptomatic-questionnaire" {
            return Result.success(.ok(with: .json(questionnaire))).publisher.eraseToAnyPublisher()
        }
        
        if request.path.starts(with: "/distribution/daily/") || request.path.starts(with: "/distribution/two-hourly/") {
            let response = HTTPResponse(httpUrlResponse: HTTPURLResponse(), bodyContent: getZip())
            return Result.success(response).publisher.eraseToAnyPublisher()
        }
        
        if request.path == "/submission/diagnosis-keys" {
            return Result.success(.ok(with: .empty)).publisher.eraseToAnyPublisher()
        }
        
        if request.path == "/distribution/exposure-configuration" {
            return Result.success(.ok(with: .json(exposureConfiguration))).publisher.eraseToAnyPublisher()
        }
        
        if request.path == "/virology-test/home-kit/order" {
            let referenceCode = dataProvider.testReferenceCode
            let websiteURL = URL(string: dataProvider.orderTestWebsite) ?? URL(string: "https://example.com")!
            
            let response = HTTPResponse.ok(with: .json(#"""
            {
                "websiteUrlWithQuery": "\#(websiteURL)",
                "tokenParameterValue": "\#(referenceCode)",
                "testResultPollingToken" : "\#(UUID().uuidString)",
                "diagnosisKeySubmissionToken": "\#(UUID().uuidString)"
            }
            """#))
            return Result.success(response).publisher.eraseToAnyPublisher()
        }
        
        if request.path == "/virology-test/results" {
            let date = "2020-04-23T00:00:00.0000000Z"
            let testResult = MockDataProvider.testResults[dataProvider.receivedTestResult]
            
            let response = HTTPResponse.ok(with: .json(#"""
            {
                "testEndDate": "\#(date)",
                "testResult": "\#(testResult)"
            }
            """#))
            return Result.success(response).publisher.eraseToAnyPublisher()
        }
        
        if request.path == "/distribution/availability-ios" {
            let response = HTTPResponse.ok(with: .json(#"""
            {
              "minimumOSVersion": {
                "value": "\#(dataProvider.minimumOSVersion)",
                "description": {
                  "en-GB": "[Placeholder] this copy will be provided by the backend."
                }
              },
              "minimumAppVersion": {
                "value": "\#(dataProvider.minimumAppVersion)",
                "description": {
                  "en-GB": "[Placeholder] this copy will be provided by the backend."
                }
              },
            }
            """#))
            return Result.success(response).publisher.eraseToAnyPublisher()
        }
        
        if request.path == "/lookup" {
            let response = HTTPResponse.ok(with: .json(#"""
            {
                "results": [
                    {
                        "bundleId": "\#(Bundle.main.bundleIdentifier!)",
                        "version": "\#(dataProvider.latestAppVersion)"
                    }
                ]
            }
            """#))
            return Result.success(response).publisher.eraseToAnyPublisher()
        }
        
        if request.path == "/circuit-breaker/exposure-notification/request" {
            let response = HTTPResponse.ok(with: .json("""
            {
                "approval_token": "\(UUID().uuidString)",
                "approval": "yes"
            }
            """))
            return Result.success(response).publisher.eraseToAnyPublisher()
        }
        
        if request.path == "/circuit-breaker/venue/request" {
            let response = HTTPResponse.ok(with: .json("""
            {
                "approval_token": "\(UUID().uuidString)",
                "approval": "yes"
            }
            """))
            return Result.success(response).publisher.eraseToAnyPublisher()
        }
        
        if request.path == "/activation/request" {
            return Result.success(.ok(with: .empty)).publisher.eraseToAnyPublisher()
        }
        
        let error = HTTPRequestError.rejectedRequest(underlyingError: TestError())
        return Result.failure(error).publisher.eraseToAnyPublisher()
    }
    
    func getZip() -> Data {
        // This is the base64 encoded string of TestKeys.zip
        let base64Zip = "UEsDBBQACAAIAAAAAAAAAAAAAAAAAAAAAAAKAAAAZXhwb3J0LmJpbnL1VnCtKMgvKlEoM1RQUFDg/PDieBwDAwODYIHVSTBDiik0WIFRg9FIUYrRUIm9OD83NT4zRUvYUM9Iz8LEQM/QwMDEVM9Ez1jPyEqaS0Bc/0jD0xmePCbiZSzGs0WdBTgk/txbyKjACJLUTma1OtKs3PuwTGxem7ztWQFGiS6QZBEgAAD//1BLBwhQGAPXhwAAAIcAAABQSwMEFAAIAAgAAAAAAAAAAAAAAAAAAAAAAAoAAABleHBvcnQuc2ln4irkUpRiNFRiL87PTY3PTNESNtQz0rMwMdAzNDAwMdUz0TPWMxJglGBU8jBwY1JkmLft5dW1WRn9Kws2PKvhaDOJe39XQjJS725LgpfMeV8mdyZFhgm59Wc/CR4X+OGlVSnOwFq878N79SXTHTXvaZStyZD8lgUIAAD//1BLBwhEY4HtfAAAAHMAAABQSwECFAAUAAgACAAAAAAAUBgD14cAAACHAAAACgAAAAAAAAAAAAAAAAAAAAAAZXhwb3J0LmJpblBLAQIUABQACAAIAAAAAABEY4HtfAAAAHMAAAAKAAAAAAAAAAAAAAAAAL8AAABleHBvcnQuc2lnUEsFBgAAAAACAAIAcAAAAHMBAAAAAA=="
        let decodedData = Data(base64Encoded: base64Zip)!
        return decodedData
    }
}

private let exposureConfiguration = """
{
    "exposureNotification": {
        "minimumRiskScore": 11,
        "attenuationDurationThresholds": [55, 63],
        "attenuationLevelValues": [0, 1, 1, 1, 1, 1, 1, 1],
        "daysSinceLastExposureLevelValues": [5, 5, 5, 5, 5, 5, 5, 5],
        "durationLevelValues": [0, 0, 0, 1, 1, 1, 1, 1],
        "transmissionRiskLevelValues": [1, 2, 3, 4, 5, 6, 7, 8],
        "attenuationWeight": 50.0,
        "daysSinceLastExposureWeight": 20,
        "durationWeight": 50.0,
        "transmissionRiskWeight": 50.0
    },
    "riskCalculation": {
        "durationBucketWeights": [1.0, 0.5, 0.0],
        "riskThreshold": 20.0
    }
}
"""

private let questionnaire = """
{
  "symptoms": [
    {
      "title": {
        "en-GB": "A high temperature (fever)"
      },
      "description": {
        "en-GB": "This means that you feel hot to touch on your chest or back (you do not need to measure your temperature)"
      },
      "riskWeight": 1
    },
    {
      "title": {
        "en-GB": "A new continuous cough"
      },
      "description": {
        "en-GB": "This means coughing a lot for more than an hour, or three or more coughing episodes in 24 hours (if you usually have a cough, it may be worse than usual)."
      },
      "riskWeight": 1
    },
    {
      "title": {
        "en-GB": "A new loss or change to your sense of smell or taste"
      },
      "description": {
        "en-GB": "This means you’ve noticed that you can’t smell or taste anything, or that things smell or taste different to normal."
      },
      "riskWeight": 1
    }
  ],
  "riskThreshold": 0.5,
  "symptomsOnsetWindowDays": 5
}
"""

private extension PublisherEventKind {
    
    static let simulatedNetwork = PublisherEventKind(label: "simualtedNetwork", regulator: SimulatedNetworkRegulator())
    
}

private class SimulatedNetworkRegulator: PublisherRegulator {
    
    static let queue = DispatchQueue(label: "simulated-network")
    
    var maximumDelay: Double = 3
    
    func regulate<T>(_ publisher: T) -> AnyPublisher<T.Output, T.Failure> where T: Publisher {
        publisher
            .delay(for: .milliseconds(.random(in: 0 ... Int(maximumDelay * 1000))), scheduler: Self.queue)
            .eraseToAnyPublisher()
    }
}
