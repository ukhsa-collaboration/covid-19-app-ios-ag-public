//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation
import TestSupport
import XCTest
@testable import Domain

@available(iOS 13.7, *)
class ExposureWindowEventEndpointTests: XCTestCase {
    private let endpointExposureWindow = ExposureWindowEventEndpoint(
        latestAppVersion: Version(major: 3, minor: 12),
        postcode: "LL44",
        localAuthority: "W06000002",
        eventType: .exposureWindow
    )
    
    private let endpointExposureWindowPositiveTest = ExposureWindowEventEndpoint(
        latestAppVersion: Version(major: 3, minor: 12),
        postcode: "LL44",
        localAuthority: "W06000002",
        eventType: .exposureWindowPositiveTest(testKitType: nil, requiresConfirmatoryTest: false)
    )
    
    func testEncodingExposureWindow() throws {
        let expected = HTTPRequest.post("/submission/mobile-analytics-events", body: .json("""
        {
          "events": [
            {
              "payload": {
                "infectiousness": "high",
                "riskScore": 131.44555790888523,
                "riskCalculationVersion": 2,
                "scanInstances": [
                  {
                    "minimumAttenuation": 97,
                    "secondsSinceLastScan": 201,
                    "typicalAttenuation": 0
                  }
                ],
                "date": "2020-11-12T00:00:00Z"
              },
              "type": "exposureWindow",
              "version": 1
            }
          ],
          "metadata": {
            "deviceModel": "\(UIDevice.current.modelName)",
            "latestApplicationVersion": "3.12",
            "operatingSystemVersion": "\(UIDevice.current.systemVersion)",
            "postalDistrict": "LL44",
            "localAuthority": "W06000002"
          }
        }
        """)).withCanonicalJSONBody()
        
        let exposureWindow = ExposureWindowInfo(
            date: GregorianDay(year: 2020, month: 11, day: 12),
            infectiousness: .high,
            scanInstances: [
                ExposureWindowInfo.ScanInstance(
                    minimumAttenuation: 97,
                    typicalAttenuation: 0,
                    secondsSinceLastScan: 201
                ),
            ],
            riskScore: 131.44555790888523,
            riskCalculationVersion: 2
        )
        
        let actual = try endpointExposureWindow.request(for: exposureWindow).withCanonicalJSONBody()
        TS.assert(actual, equals: expected)
    }
    
    func testEncodingExposureWindowPositveTest() throws {
        let expected = HTTPRequest.post("/submission/mobile-analytics-events", body: .json("""
        {
          "events": [
            {
              "payload": {
                "testType": "unknown",
                "requiresConfirmatoryTest": false,
                "infectiousness": "high",
                "riskScore": 131.44555790888523,
                "riskCalculationVersion": 2,
                "scanInstances": [
                  {
                    "minimumAttenuation": 97,
                    "secondsSinceLastScan": 201,
                    "typicalAttenuation": 0
                  }
                ],
                "date": "2020-11-12T00:00:00Z"
              },
              "type": "exposureWindowPositiveTest",
              "version": 2
            }
          ],
          "metadata": {
            "deviceModel": "\(UIDevice.current.modelName)",
            "latestApplicationVersion": "3.12",
            "operatingSystemVersion": "\(UIDevice.current.systemVersion)",
            "postalDistrict": "LL44",
            "localAuthority": "W06000002"
          }
        }
        """)).withCanonicalJSONBody()
        
        let exposureWindow = ExposureWindowInfo(
            date: GregorianDay(year: 2020, month: 11, day: 12),
            infectiousness: .high,
            scanInstances: [
                ExposureWindowInfo.ScanInstance(
                    minimumAttenuation: 97,
                    typicalAttenuation: 0,
                    secondsSinceLastScan: 201
                ),
            ],
            riskScore: 131.44555790888523,
            riskCalculationVersion: 2
        )
        let actual = try endpointExposureWindowPositiveTest.request(for: exposureWindow).withCanonicalJSONBody()
        TS.assert(actual, equals: expected)
    }
    
    func testEncodingExposureWindowPositveTestWithTestTypeLabResult() throws {
        let endpointExposureWindowPositiveTest = ExposureWindowEventEndpoint(
            latestAppVersion: Version(major: 3, minor: 12),
            postcode: "LL44",
            localAuthority: "W06000002",
            eventType: .exposureWindowPositiveTest(testKitType: .labResult, requiresConfirmatoryTest: false)
        )
        
        let expected = HTTPRequest.post("/submission/mobile-analytics-events", body: .json("""
        {
          "events": [
            {
              "payload": {
                "testType": "LAB_RESULT",
                "requiresConfirmatoryTest": false,
                "infectiousness": "high",
                "riskScore": 131.44555790888523,
                "riskCalculationVersion": 2,
                "scanInstances": [
                  {
                    "minimumAttenuation": 97,
                    "secondsSinceLastScan": 201,
                    "typicalAttenuation": 0
                  }
                ],
                "date": "2020-11-12T00:00:00Z"
              },
              "type": "exposureWindowPositiveTest",
              "version": 2
            }
          ],
          "metadata": {
            "deviceModel": "\(UIDevice.current.modelName)",
            "latestApplicationVersion": "3.12",
            "operatingSystemVersion": "\(UIDevice.current.systemVersion)",
            "postalDistrict": "LL44",
            "localAuthority": "W06000002"
          }
        }
        """)).withCanonicalJSONBody()
        
        let exposureWindow = ExposureWindowInfo(
            date: GregorianDay(year: 2020, month: 11, day: 12),
            infectiousness: .high,
            scanInstances: [
                ExposureWindowInfo.ScanInstance(
                    minimumAttenuation: 97,
                    typicalAttenuation: 0,
                    secondsSinceLastScan: 201
                ),
            ],
            riskScore: 131.44555790888523,
            riskCalculationVersion: 2
        )
        let actual = try endpointExposureWindowPositiveTest.request(for: exposureWindow).withCanonicalJSONBody()
        TS.assert(actual, equals: expected)
    }
    
    func testEncodingExposureWindowPositveTestWithRapidTestRequiringConfirmation() throws {
        let endpointExposureWindowPositiveTest = ExposureWindowEventEndpoint(
            latestAppVersion: Version(major: 3, minor: 12),
            postcode: "LL44",
            localAuthority: "W06000002",
            eventType: .exposureWindowPositiveTest(testKitType: .rapidResult, requiresConfirmatoryTest: true)
        )
        
        let expected = HTTPRequest.post("/submission/mobile-analytics-events", body: .json("""
        {
          "events": [
            {
              "payload": {
                "testType": "RAPID_RESULT",
                "requiresConfirmatoryTest": true,
                "infectiousness": "high",
                "riskScore": 131.44555790888523,
                "riskCalculationVersion": 2,
                "scanInstances": [
                  {
                    "minimumAttenuation": 97,
                    "secondsSinceLastScan": 201,
                    "typicalAttenuation": 0
                  }
                ],
                "date": "2020-11-12T00:00:00Z"
              },
              "type": "exposureWindowPositiveTest",
              "version": 2
            }
          ],
          "metadata": {
            "deviceModel": "\(UIDevice.current.modelName)",
            "latestApplicationVersion": "3.12",
            "operatingSystemVersion": "\(UIDevice.current.systemVersion)",
            "postalDistrict": "LL44",
            "localAuthority": "W06000002"
          }
        }
        """)).withCanonicalJSONBody()
        
        let exposureWindow = ExposureWindowInfo(
            date: GregorianDay(year: 2020, month: 11, day: 12),
            infectiousness: .high,
            scanInstances: [
                ExposureWindowInfo.ScanInstance(
                    minimumAttenuation: 97,
                    typicalAttenuation: 0,
                    secondsSinceLastScan: 201
                ),
            ],
            riskScore: 131.44555790888523,
            riskCalculationVersion: 2
        )
        let actual = try endpointExposureWindowPositiveTest.request(for: exposureWindow).withCanonicalJSONBody()
        TS.assert(actual, equals: expected)
    }
}
