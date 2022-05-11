//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation
import UIKit

struct MetricUploadChunkCreator {
    private static let uploadWindows: [UploadWindow] =
        [
            .init(0, 24),
        ]
    
    private let collector: MetricCollector
    private let appInfo: AppInfo
    private let getPostcode: () -> String?
    private let getLocalAuthority: () -> String?
    private let getCountry: () -> Country
    private let currentDateProvider: DateProviding
    private let isFeatureEnabled: (Feature) -> Bool
    
    init(collector: MetricCollector,
         appInfo: AppInfo,
         getPostcode: @escaping () -> String?,
         getLocalAuthority: @escaping () -> String?,
         getCountry: @escaping () -> Country,
         currentDateProvider: DateProviding,
         isFeatureEnabled: @escaping (Feature) -> Bool) {
        self.collector = collector
        self.appInfo = appInfo
        self.getPostcode = getPostcode
        self.getLocalAuthority = getLocalAuthority
        self.getCountry = getCountry
        self.currentDateProvider = currentDateProvider
        self.isFeatureEnabled = isFeatureEnabled
    }
    
    func consumeMetricsInfoForNextWindow() -> MetricsInfo? {
        guard let earliestEntryDate = collector.earliestEntryDate() else { return nil }
        
        let earliestBeginDateUTC = UTCHour(containing: earliestEntryDate)
        let uploadWindow = calculateUploadWindow(from: earliestBeginDateUTC)
        
        let uploadInterval = uploadWindow.interval(on: earliestBeginDateUTC.day)
        
        if uploadInterval.end > currentDateProvider.currentDate { return nil }
        
        let recordedMetrics = collector.consumeMetrics(for: uploadInterval)
        
        var metricsToBeStripped = Feature.allCases.filter { !isFeatureEnabled($0) }
            .filter { $0.countriesOfRelevance.contains(self.getCountry()) }
            .map { $0.associatedMetrics }
            .reduce([], +)
            
        metricsToBeStripped.append(contentsOf: Metric.nonFeatureRelatedMetricsToBeStripped)
        
        let info = MetricsInfo(
            payload: .triggeredPayload(createTriggeredPayload(dateInterval: uploadInterval)),
            postalDistrict: getPostcode() ?? "",
            localAuthority: getLocalAuthority() ?? "",
            recordedMetrics: recordedMetrics,
            excludedMetrics: metricsToBeStripped
        )
        
        return info
    }
    
    func createTriggeredPayload(dateInterval: DateInterval) -> TriggeredPayload {
        TriggeredPayload(
            startDate: dateInterval.start,
            endDate: dateInterval.end,
            deviceModel: UIDevice.current.modelName,
            operatingSystemVersion: UIDevice.current.systemVersion,
            latestApplicationVersion: appInfo.version.readableRepresentation,
            includesMultipleApplicationVersions: false
        )
    }
    
    private func calculateUploadWindow(from date: UTCHour) -> UploadWindow {
        for uploadWindow in Self.uploadWindows {
            if uploadWindow.range.contains(date.hour) {
                return uploadWindow
            }
        }
        return Self.uploadWindows.first!
    }
    
}

private struct UploadWindow {
    var startHour: Int
    var endHour: Int
    
    var range: Range<Int> {
        (startHour ..< endHour)
    }
    
    init(_ startHour: Int, _ endHour: Int) {
        self.startHour = startHour
        self.endHour = endHour
    }
    
    func interval(on day: GregorianDay) -> DateInterval {
        let startDate = UTCHour(day: day, hour: startHour, minutes: 0).date
        
        let endDate: Date
        if endHour == 24 {
            let nextDay = day.advanced(by: 1)
            endDate = UTCHour(day: nextDay, hour: 0, minutes: 0).date
        } else {
            endDate = UTCHour(day: day, hour: endHour, minutes: 0).date
        }
        
        return DateInterval(start: startDate, end: endDate)
    }
}

private extension MetricCollector {
    
    func consumeMetrics(for interval: DateInterval) -> [Metric: Int] {
        defer { consumeMetrics(notAfter: interval.end) }
        return recordedMetrics(in: interval)
    }
    
}
