//
// Copyright © 2021 DHSC. All rights reserved.
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
    
    private let currentDateProvider: DateProviding
    private let enabled: MetricsState
    
    init(encryptedStore: EncryptedStoring, currentDateProvider: DateProviding, enabled: MetricsState) {
        _cache = encryptedStore.encrypted("metrics")
        self.currentDateProvider = currentDateProvider
        self.enabled = enabled
        Self.current = self
    }
    
    func record(_ metric: Metric) {
        guard enabled.state == .enabled else {
            return
        }
        Self.logger.debug("record metric", metadata: .describing(metric.rawValue))
        cache = mutating(cache ?? MetricsCache(entries: [], latestWindowEnd: nil)) {
            $0.entries.append(
                MetricsCache.Entry(name: metric.rawValue, date: currentDateProvider.currentDate)
            )
        }
    }
    
    func consumeMetrics(notAfter date: Date) {
        cache = mutating(cache ?? MetricsCache(entries: [], latestWindowEnd: nil)) {
            $0.entries.removeAll { $0.date <= date }
            $0.latestWindowEnd = date
        }
    }
    
    func consumeMetricsNotOnOrAfter(date: Date) {
        guard let cache = cache else { return }
        
        self.cache = mutating(cache) {
            $0.entries.removeAll { $0.date < date }
        }
        
        // Only change the latestWindowEnd if it was present before and older than the new latest metric date
        if let currentLatestWindowEnd = cache.latestWindowEnd {
            self.cache = mutating(cache) {
                $0.latestWindowEnd = currentLatestWindowEnd < date ? date : currentLatestWindowEnd
            }
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
    
    func delete() {
        cache = nil
    }
    
    static func record(_ metric: Metric) {
        current?.record(metric)
    }
}
