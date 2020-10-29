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
    
    init(
        infectiousnessFactorCalculator: ExposureWindowInfectiousnessFactorCalculator = ExposureWindowInfectiousnessFactorCalculator(),
        dateProvider: @escaping () -> Date,
        isolationLength: DayDuration
    ) {
        self.infectiousnessFactorCalculator = infectiousnessFactorCalculator
        self.dateProvider = dateProvider
        self.isolationLength = isolationLength
    }
    
    func riskInfo(
        for exposureWindows: [ExposureNotificationExposureWindow],
        configuration: ExposureDetectionConfiguration,
        riskScoreCalculator: ExposureWindowRiskScoreCalculator
    ) -> ExposureRiskInfo? {
        return exposureWindows.map { exposureWindow in
            let scanInstances = exposureWindow.enScanInstances.map { $0.toScanInstance() }
            let riskScore = riskScoreCalculator.calculate(instances: scanInstances) * 60
            let infectiousnessFactor = infectiousnessFactorCalculator.infectiousnessFactor(for: exposureWindow.infectiousness, config: configuration)
            return ExposureRiskInfo(
                riskScore: riskScore * infectiousnessFactor,
                riskScoreVersion: Self.riskScoreVersion,
                day: GregorianDay(date: exposureWindow.date, timeZone: .utc),
                isConsideredRisky: riskScore >= configuration.v2RiskThreshold
            )
        }
        .filter { isRecentDate(exposureRiskInfo: $0) && $0.isConsideredRisky }
        .max { $1.isHigherPriority(than: $0) }
    }
    
    private func isRecentDate(exposureRiskInfo: ExposureRiskInfo) -> Bool {
        let today = GregorianDay(date: dateProvider(), timeZone: .utc)
        return today - isolationLength < exposureRiskInfo.day
    }
}
