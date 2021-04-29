//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import ExposureNotification

struct TemporaryExposureKey {
    private static let priorDaysThreshold = -2
    
    var keyData: Data
    var rollingStartNumber: UInt32
    var rollingPeriod: UInt32
    var transmissionRiskLevel: UInt8 {
        let transmissionRiskLevel = daysSinceOnsetOfSymptoms < Self.priorDaysThreshold
            ? 0
            : ENTemporaryExposureKey.maxTransmissionRiskLevel - abs(daysSinceOnsetOfSymptoms)
        
        return ENRiskLevel(max(ENTemporaryExposureKey.minTransmissionRiskLevel, transmissionRiskLevel))
    }
    
    var gregorianDay: GregorianDay
    var daysSinceOnsetOfSymptoms: Int
    
    init(exposureKey: ENTemporaryExposureKey, onsetDay: GregorianDay) {
        keyData = exposureKey.keyData
        rollingStartNumber = exposureKey.rollingStartNumber
        rollingPeriod = exposureKey.rollingPeriod
        gregorianDay = exposureKey.gregorianDay
        daysSinceOnsetOfSymptoms = onsetDay.distance(to: exposureKey.gregorianDay)
    }
}

private extension ENTemporaryExposureKey {
    var gregorianDay: GregorianDay {
        // rollingStartNumber is the number of 10 minute periods since 1970
        // so we multiply by 60 * 10 to convert to seconds
        let timeSince1970 = TimeInterval(rollingStartNumber * 60 * 10)
        let date = Date(timeIntervalSince1970: timeSince1970)
        return GregorianDay(date: date, timeZone: .current)
    }
}

extension TemporaryExposureKey {
    
    static func infectiousDateRange(onsetDay: GregorianDay) -> Range<GregorianDay> {
        let startDay = onsetDay.advanced(by: priorDaysThreshold)
        let endDay = onsetDay.advanced(by: ENTemporaryExposureKey.maxTransmissionRiskLevel)
        return startDay ..< endDay
    }
    
    static func dateRangeConsideredForUploadIgnoringInfectiousness(
        acknowledgmentDay: GregorianDay,
        isolationDuration: DayDuration,
        today: GregorianDay
    ) -> Range<GregorianDay> {
        let startDay = today.advanced(by: -(isolationDuration.days - 1)) // excluding today
        let endDay = acknowledgmentDay
        return min(startDay, endDay) ..< endDay
    }
    
}
