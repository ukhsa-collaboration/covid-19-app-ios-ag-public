//
// Copyright © 2020 NHSX. All rights reserved.
//

import ExposureNotification
import Foundation

extension ENExposureConfiguration {
    convenience init(from config: ExposureDetectionConfiguration) {
        self.init()
        transmissionRiskWeight = config.transmitionWeight
        durationWeight = config.durationWeight
        attenuationWeight = config.attenuationWeight
        daysSinceLastExposureWeight = config.daysWeight
        transmissionRiskLevelValues = config.transmition.map { NSNumber(value: $0) }
        durationLevelValues = config.duration.map { NSNumber(value: $0) }
        daysSinceLastExposureLevelValues = config.daysSinceLastExposure.map { NSNumber(value: $0) }
        attenuationLevelValues = config.attenuation.map { NSNumber(value: $0) }
        metadata = ["attenuationDurationThresholds": config.thresholds.map { NSNumber(value: $0) }]
        
        if #available(iOS 13.7, *) {
            reportTypeNoneMap = ENDiagnosisReportType(rawValue: UInt32(config.reportTypeWhenMissing)) ?? ENDiagnosisReportType.confirmedTest
            infectiousnessForDaysSinceOnsetOfSymptoms = convertToMap(config.daysSinceOnsetToInfectiousness)
        }
    }
    
    private func convertToMap(_ daysSinceOnsetToInfectiousness: [Int]) -> [NSNumber : NSNumber] {
        return zip(-14...14, daysSinceOnsetToInfectiousness)
            .reduce(into: [:]) { (dict, tuple) in
                let (index, infectiousness) = tuple
                dict[NSNumber(value: index)] = NSNumber(value: infectiousness)
            }
    }
}
