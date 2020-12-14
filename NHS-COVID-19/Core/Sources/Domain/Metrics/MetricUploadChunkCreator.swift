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
    private let getPostcode: () -> String
    private let currentDateProvider: DateProviding
    
    init(collector: MetricCollector, appInfo: AppInfo, getPostcode: @escaping () -> String, currentDateProvider: DateProviding) {
        self.collector = collector
        self.appInfo = appInfo
        self.getPostcode = getPostcode
        self.currentDateProvider = currentDateProvider
    }
    
    func consumeMetricsInfoForNextWindow() -> MetricsInfo? {
        guard let earliestEntryDate = collector.earliestEntryDate() else { return nil }
        
        let earliestBeginDateUTC = UTCHour(containing: earliestEntryDate)
        let uploadWindow = calculateUploadWindow(from: earliestBeginDateUTC)
        
        let uploadInterval = uploadWindow.interval(on: earliestBeginDateUTC.day)
        
        if uploadInterval.end > currentDateProvider.currentDate { return nil }
        
        let recordedMetrics = collector.consumeMetrics(for: uploadInterval)
        
        let info = MetricsInfo(
            payload: .triggeredPayload(createTriggeredPayload(dateInterval: uploadInterval)),
            postalDistrict: getPostcode(),
            recordedMetrics: recordedMetrics
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
