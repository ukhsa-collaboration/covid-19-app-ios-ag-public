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
}

class MetricCollector {
    
    private static let logger = Logger(label: "MetricCollector")
    
    private static var current: MetricCollector?
    
    @Encrypted
    private var cache: MetricsCache?
    
    private let makeDate: () -> Date
    
    init(encryptedStore: EncryptedStoring, makeDate: @escaping () -> Date = Date.init) {
        _cache = encryptedStore.encrypted("metrics")
        self.makeDate = makeDate
        Self.current = self
    }
    
    func record(_ metric: Metric) {
        Self.logger.debug("record metric", metadata: .describing(metric.rawValue))
        cache = mutating(cache ?? MetricsCache(entries: [])) {
            $0.entries.append(
                MetricsCache.Entry(name: metric.rawValue, date: makeDate())
            )
        }
    }
    
    func deleteMetrics(notAfter date: Date) {
        cache = mutating(cache ?? MetricsCache(entries: [])) {
            $0.entries.removeAll { $0.date <= date }
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
    
    static func record(_ metric: Metric) {
        current?.record(metric)
    }
    
}
