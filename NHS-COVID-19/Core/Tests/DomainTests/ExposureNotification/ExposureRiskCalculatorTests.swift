//
// Copyright © 2020 NHSX. All rights reserved.
//

import ExposureNotification
import XCTest
@testable import Domain

class ExposureRiskCalculatorTests: XCTestCase {
    
    func testRiskScoreForNoExposures() {
        let riskCalculator = getRiskCalculator()
        let exposure = getExposureInfoWith(attenuationDurations: [0, 0, 0])
        
        let riskInfo = riskCalculator.riskInfo(for: [exposure])
        
        XCTAssertNil(riskInfo)
    }
    
    func testWeightingAppliedToExposure() {
        let riskCalculator = getRiskCalculator()
        let exposure = getExposureInfoWith(attenuationDurations: [300, 300, 300])
        
        let riskInfo = riskCalculator.riskInfo(for: [exposure])
        
        XCTAssertEqual(riskInfo?.riskScore, 450)
    }
    
    func testParameterisedWeightingAppliedToExposures() {
        let riskCalculator = getRiskCalculator()
        let parameterisedTestCases: [([NSNumber], Double?)] = [
            ([1800, 0, 0], 1800.0),
            ([0, 1800, 0], 900.0),
            ([0, 0, 1800], nil),
            ([300, 300, 300], 450.0),
            ([0, 300, 300], 150.0),
            ([300, 0, 300], 300.0),
        ]
        
        for (durations, expectedRiskScore) in parameterisedTestCases {
            let exposure = getExposureInfoWith(attenuationDurations: durations)
            let riskInfo = riskCalculator.riskInfo(for: [exposure])
            
            XCTAssertEqual(riskInfo?.riskScore, expectedRiskScore)
        }
    }
    
    func testGreatestRiskScoreAmongstExposuresIsReturned() {
        let riskCalculator = getRiskCalculator()
        let shorterExposure = getExposureInfoWith(attenuationDurations: [300, 0, 0])
        let longerExposure = getExposureInfoWith(attenuationDurations: [900, 0, 0])
        
        let riskInfo = riskCalculator.riskInfo(for: [shorterExposure, longerExposure])
        
        XCTAssertEqual(riskInfo?.riskScore, 900)
    }
    
    func testParameterisedGreatestRiskScoreAmongstExposuresIsReturned() {
        let riskCalculator = getRiskCalculator()
        let shorterExposure = getExposureInfoWith(attenuationDurations: [300, 0, 0])
        let longerExposure = getExposureInfoWith(attenuationDurations: [900, 0, 0])
        
        let parameterisedTestCases = [
            ([longerExposure, shorterExposure], 900.0),
            ([shorterExposure, shorterExposure], 300.0),
            ([longerExposure, longerExposure], 900.0),
        ]
        
        for (exposures, expectedRiskScore) in parameterisedTestCases {
            let riskInfo = riskCalculator.riskInfo(for: exposures)
            
            XCTAssertEqual(riskInfo?.riskScore, expectedRiskScore)
        }
    }
    
    func getRiskCalculator() -> ExposureRiskCalculator {
        let configuration = ExposureDetectionConfiguration(
            transmitionWeight: 0,
            durationWeight: 0,
            attenuationWeight: 0,
            daysWeight: 0,
            transmition: [],
            duration: [],
            daysSinceLastExposure: [],
            attenuation: [],
            thresholds: [],
            durationBucketWeights: [1.0, 0.5, 0],
            riskThreshold: 5
        )
        
        return ExposureRiskCalculator(configuration: configuration)
    }
    
    func getExposureInfoWith(attenuationDurations: [NSNumber]) -> MockENExposureInfo {
        let exposure = MockENExposureInfo(attenuationDurations: attenuationDurations, date: Date(), totalRiskScore: 0)
        
        return exposure
    }
}
