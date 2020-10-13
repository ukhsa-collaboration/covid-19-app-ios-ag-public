//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation
import Logging
import MetricKit

class MetricReporter: NSObject {
    
    private static let logger = Logger(label: "MetricReporter")
    
    private let client: HTTPClient
    private let collector: MetricCollector
    private let getPostcode: () -> String
    private let chunkCreator: MetricUploadChunkCreator
    private var cancellables = [AnyCancellable]()
    
    init(
        manager: MetricManaging,
        client: HTTPClient,
        encryptedStore: EncryptedStoring,
        currentDateProvider: @escaping () -> Date,
        appInfo: AppInfo,
        getPostcode: @escaping () -> String
    ) {
        self.client = client
        self.getPostcode = getPostcode
        collector = MetricCollector(encryptedStore: encryptedStore, currentDateProvider: currentDateProvider)
        chunkCreator = MetricUploadChunkCreator(collector: collector, appInfo: appInfo, getPostcode: getPostcode, currentDateProvider: currentDateProvider)
        super.init()
    }
    
    func uploadMetrics() -> AnyPublisher<Void, Never> {
        var publishers = [AnyPublisher<Void, NetworkRequestError>]()
        
        while let info = chunkCreator.consumeMetricsInfoForNextWindow() {
            publishers.append(
                client.fetch(MetricSubmissionEndpoint(), with: info)
            )
        }
        
        return Publishers.Sequence<[AnyPublisher<Void, NetworkRequestError>], NetworkRequestError>(sequence: publishers)
            .flatMap { $0 }
            .ensureFinishes(placeholder: ())
            .eraseToAnyPublisher()
    }
    
    func didFinishOnboarding() {
        let today = GregorianDay.today.startDate(in: .utc)
        let payload = chunkCreator.createTriggeredPayload(dateInterval: DateInterval(start: today, end: today))
        let info = MetricsInfo(payload: MetricsInfoPayload.triggeredPayload(payload), postalDistrict: getPostcode(), recordedMetrics: [.completedOnboarding: 1])
        client.fetch(MetricSubmissionEndpoint(), with: info).replaceError(with: ()).sink { _ in }.store(in: &cancellables)
    }
}

private extension MetricCollector {
    
    func consumeMetrics(for payload: MXMetricPayload) -> [Metric: Int] {
        let interval = DateInterval(start: payload.timeStampBegin, end: payload.timeStampEnd)
        defer { consumeMetrics(notAfter: interval.end) }
        return recordedMetrics(in: interval)
    }
    
}
