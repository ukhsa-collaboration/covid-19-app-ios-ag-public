//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation
import RiskScore

@available(iOS 13.7, *)
class ExposureWindowRiskCalculator {
    private static let riskScoreVersion = 2
    private let infectiousnessFactorCalculator: ExposureWindowInfectiousnessFactorCalculator
    private let dateProvider: () -> Date
    private let isolationLength: DayDuration
    private let submitExposureWindows: ([(ExposureNotificationExposureWindow, ExposureRiskInfo)]) -> Void
    
    init(
        infectiousnessFactorCalculator: ExposureWindowInfectiousnessFactorCalculator = ExposureWindowInfectiousnessFactorCalculator(),
        dateProvider: @escaping () -> Date,
        isolationLength: DayDuration,
        submitExposureWindows: @escaping ([(ExposureNotificationExposureWindow, ExposureRiskInfo)]) -> Void
    ) {
        self.infectiousnessFactorCalculator = infectiousnessFactorCalculator
        self.dateProvider = dateProvider
        self.isolationLength = isolationLength
        self.submitExposureWindows = submitExposureWindows
    }
    
    func riskInfo(
        for exposureWindows: [ExposureNotificationExposureWindow],
        configuration: ExposureDetectionConfiguration,
        riskScoreCalculator: ExposureWindowRiskScoreCalculator
    ) -> ExposureRiskInfo? {
        var riskyWindows = [(ExposureNotificationExposureWindow, ExposureRiskInfo)]()
        
        let maxRiskInfo = exposureWindows.map { exposureWindow in
            let scanInstances = exposureWindow.enScanInstances.map { $0.toScanInstance() }
            let riskScore = riskScoreCalculator.calculate(instances: scanInstances) * 60
            let infectiousnessFactor = infectiousnessFactorCalculator.infectiousnessFactor(for: exposureWindow.infectiousness, config: configuration)
            let riskInfo = ExposureRiskInfo(
                riskScore: riskScore * infectiousnessFactor,
                riskScoreVersion: Self.riskScoreVersion,
                day: GregorianDay(date: exposureWindow.date, timeZone: .utc),
                riskThreshold: configuration.v2RiskThreshold
            )
            if riskInfo.isConsideredRisky, isRecentDate(exposureRiskInfo: riskInfo) {
                riskyWindows.append((exposureWindow, riskInfo))
            }
            return riskInfo
        }
        .filter { isRecentDate(exposureRiskInfo: $0) }
        .max { $1.isHigherPriority(than: $0) }
        
        submitExposureWindows(riskyWindows)
        return maxRiskInfo
    }
    
    private func isRecentDate(exposureRiskInfo: ExposureRiskInfo) -> Bool {
        let today = GregorianDay(date: dateProvider(), timeZone: .utc)
        return today - isolationLength < exposureRiskInfo.day
    }
}
