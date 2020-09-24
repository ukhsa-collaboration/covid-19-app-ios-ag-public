

import Foundation
import ExposureNotification
import Common

public class TransmissionRiskLevelApplier {
    private static let priorDaysThreshold = -2
    
    public init() {}
    
    func applyTransmissionRiskLevels(for keys: [ENTemporaryExposureKey], onsetDay: GregorianDay) -> [ENTemporaryExposureKey] {
        return keys
            .map { key in
                let daysFromOnset = onsetDay.distance(to: key.gregorianDay)
                key.transmissionRiskLevel = calculateTransmissionRiskLevel(daysFromOnset)
                return key
            }
    }
    
    private func calculateTransmissionRiskLevel(_ daysFromOnset: Int) -> ENRiskLevel {
        let transmissionRiskLevel = daysFromOnset < Self.priorDaysThreshold
            ? 0
            : ENTemporaryExposureKey.maxTransmissionRiskLevel - abs(daysFromOnset)
        
        return ENRiskLevel(max(ENTemporaryExposureKey.minTransmissionRiskLevel, transmissionRiskLevel))
    }
}

private extension ENTemporaryExposureKey {
    var gregorianDay: GregorianDay {
        get {
            // rollingStartNumber is the number of 10 minute periods since 1970
            // so we multiply by 60 * 10 to convert to seconds
            let timeSince1970 = TimeInterval(rollingStartNumber * 60 * 10)
            let date = Date(timeIntervalSince1970: timeSince1970)
            return GregorianDay(date: date, timeZone: .current)
        }
    }
}
