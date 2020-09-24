//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation
import Logging

private struct MetricsCache: Codable, DataConvertible {
    struct Entry: Codable {
        var name: String
        var date: Date
    }
    
    var entries: [Entry]
    var latestWindowEnd: Date?
}

class MetricCollector {
    
    private static let logger = Logger(label: "MetricCollector")
    
    private static var current: MetricCollector?
    
    @Encrypted
    private var cache: MetricsCache?
    
    private let currentDateProvider: () -> Date
    
    init(encryptedStore: EncryptedStoring, currentDateProvider: @escaping () -> Date) {
        _cache = encryptedStore.encrypted("metrics")
        self.currentDateProvider = currentDateProvider
        Self.current = self
    }
    
    func record(_ metric: Metric) {
        Self.logger.debug("record metric", metadata: .describing(metric.rawValue))
        cache = mutating(cache ?? MetricsCache(entries: [], latestWindowEnd: nil)) {
            $0.entries.append(
                MetricsCache.Entry(name: metric.rawValue, date: currentDateProvider())
            )
        }
    }
    
    func consumeMetrics(notAfter date: Date) {
        cache = mutating(cache ?? MetricsCache(entries: [], latestWindowEnd: nil)) {
            $0.entries.removeAll { $0.date <= date }
            $0.latestWindowEnd = date
        }
    }
    
    func recordedMetrics(in dateInterval: DateInterval) -> [Metric: Int] {
        guard let cache = cache else { return [:] }
        
        let includedEntries = cache.entries.lazy
            .filter { dateInterval.contains($0.date) }
            .compactMap { entry in
                Metric(rawValue: entry.name)
            }.map {
                ($0, 1)
            }
        
        return Dictionary(includedEntries, uniquingKeysWith: +)
    }
    
    func earliestEntryDate() -> Date? {
        return cache?.latestWindowEnd ?? cache?.entries.map(\.date).min()
    }
    
    static func record(_ metric: Metric) {
        current?.record(metric)
    }
    
}
