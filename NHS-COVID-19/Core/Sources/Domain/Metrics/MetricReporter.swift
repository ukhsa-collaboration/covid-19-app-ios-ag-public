//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation
import Logging
import MetricKit

class MetricReporter: NSObject, MXMetricManagerSubscriber {
    
    private static let logger = Logger(label: "MetricReporter")
    
    private let client: HTTPClient
    private let collector: MetricCollector
    private let getPostcode: () -> String
    private var cancellables = [AnyCancellable]()
    
    init(manager: MetricManaging, client: HTTPClient, encryptedStore: EncryptedStoring, getPostcode: @escaping () -> String) {
        self.client = client
        self.getPostcode = getPostcode
        collector = MetricCollector(encryptedStore: encryptedStore)
        
        super.init()
        
        manager.add(self)
    }
    
    func didReceive(_ payloads: [MXMetricPayload]) {
        payloads.forEach(didReceive)
    }
    
    private func didReceive(_ payload: MXMetricPayload) {
        Self.logger.info("received payload", metadata: .describing(String(data: payload.jsonRepresentation(), encoding: .utf8) ?? ""))
        let info = MetricsInfo(
            payload: payload,
            postalDistrict: getPostcode(),
            recordedMetrics: collector.consumeMetrics(for: payload)
        )
        client
            .fetch(MetricSubmissionEndpoint(), with: info)
            .sink(receiveCompletion: { _ in }, receiveValue: {})
            .store(in: &cancellables)
    }
    
}

private extension MetricCollector {
    
    func consumeMetrics(for payload: MXMetricPayload) -> [Metric: Int] {
        let interval = DateInterval(start: payload.timeStampBegin, end: payload.timeStampEnd)
        defer { deleteMetrics(notAfter: interval.end) }
        return recordedMetrics(in: interval)
    }
    
}
