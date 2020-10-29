//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import ExposureNotification
import Foundation
import XCTest
@testable import Domain

class TemporaryExposureKeyTests: XCTestCase {
    
    func testSetTransmissionRiskLevelBeforeUploading() throws {
        let onsetDay = GregorianDay(dateComponents: DateComponents(year: 2020, month: 7, day: 7))
        
        let diagnosisKeys = generate14DayDiagnosisKeyHistory()
        
        let keys = diagnosisKeys.map { TemporaryExposureKey(exposureKey: $0, onsetDay: onsetDay) }
        
        var expectedTransmissionRiskScores = [0, 0, 0, 0, 5, 6, 7, 6, 5, 4, 3, 2, 1, 0]
        
        keys.sorted { $0.rollingStartNumber < $1.rollingStartNumber }
            .forEach { key in
                XCTAssertEqual(key.transmissionRiskLevel, UInt8(expectedTransmissionRiskScores.removeFirst()))
            }
    }
    
    func testSetTransmissionRiskLevelBeforeUploadingOffset() throws {
        let onsetDay = GregorianDay(dateComponents: DateComponents(year: 2020, month: 7, day: 15))
        
        let diagnosisKeys = generate14DayDiagnosisKeyHistory()
        
        let keys = diagnosisKeys.map { TemporaryExposureKey(exposureKey: $0, onsetDay: onsetDay) }
        
        var expectedTransmissionRiskScores = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 6]
        
        keys.sorted { $0.rollingStartNumber < $1.rollingStartNumber }
            .forEach { key in
                XCTAssertEqual(key.transmissionRiskLevel, UInt8(expectedTransmissionRiskScores.removeFirst()))
            }
    }
    
    func testSetsTransmissionRiskLevelCorrectlyOnGMT() {
        let onsetDay = GregorianDay(dateComponents: DateComponents(year: 2020, month: 1, day: 7))
        
        let diagnosisKeys = generate14DayDiagnosisKeyHistory(month: 1)
        
        let keys = diagnosisKeys.map { TemporaryExposureKey(exposureKey: $0, onsetDay: onsetDay) }
        
        var expectedTransmissionRiskScores = [0, 0, 0, 0, 5, 6, 7, 6, 5, 4, 3, 2, 1, 0]
        
        keys.sorted { $0.rollingStartNumber < $1.rollingStartNumber }
            .forEach { key in
                XCTAssertEqual(key.transmissionRiskLevel, UInt8(expectedTransmissionRiskScores.removeFirst()))
            }
    }
    
    fileprivate func generate14DayDiagnosisKeyHistory(month: Int = 7) -> [ENTemporaryExposureKey] {
        var diagnosisKeys = [ENTemporaryExposureKey]()
        (1 ... 14).forEach { index in
            let diagnosisKey = ENTemporaryExposureKey()
            let keyDate = date(from: DateComponents(year: 2020, month: month, day: index, hour: 0))
            diagnosisKey.keyData = String.random().data
            diagnosisKey.rollingStartNumber = UInt32(exactly: keyDate.timeIntervalSince1970 / (60 * 10))!
            diagnosisKey.rollingPeriod = UInt32(24 * (60 / 10)) // Amount of 10 minute periods in 24 hours
            diagnosisKeys.append(diagnosisKey)
        }
        return diagnosisKeys
    }
    
    private func date(from dateComponents: DateComponents) -> Date {
        var dateComponentsCopy = dateComponents
        dateComponentsCopy.calendar = Calendar.utc
        return dateComponentsCopy.date!
    }
    
}
