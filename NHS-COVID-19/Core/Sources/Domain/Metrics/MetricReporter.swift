//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation
import Logging

class MetricReporter: NSObject {
    
    private static let logger = Logger(label: "MetricReporter")
    
    private let client: HTTPClient
    private let collector: MetricCollector
    private let enabled: MetricsState
    private let getPostcode: () -> String?
    private let getLocalAuthority: () -> String?
    private let chunkCreator: MetricUploadChunkCreator
    private var cancellables = [AnyCancellable]()
    
    init(
        client: HTTPClient,
        encryptedStore: EncryptedStoring,
        currentDateProvider: DateProviding,
        appInfo: AppInfo,
        getPostcode: @escaping () -> String?,
        getLocalAuthority: @escaping () -> String?,
        metricCollector: MetricCollector? = nil,
        metricChunkCreator: MetricUploadChunkCreator? = nil
    ) {
        self.client = client
        self.getPostcode = getPostcode
        self.getLocalAuthority = getLocalAuthority
        
        let enabled = MetricsState()
        
        let collector = metricCollector ?? MetricCollector(encryptedStore: encryptedStore, currentDateProvider: currentDateProvider, enabled: enabled)
        let chunkCreator = metricChunkCreator ?? MetricUploadChunkCreator(collector: collector, appInfo: appInfo, getPostcode: getPostcode, getLocalAuthority: getLocalAuthority, currentDateProvider: currentDateProvider)
        
        self.enabled = enabled
        self.collector = collector
        self.chunkCreator = chunkCreator
        
        super.init()
    }
    
    func set(rawState: DomainProperty<RawState>) {
        enabled.set(rawState: rawState)
    }
    
    func uploadMetrics() -> AnyPublisher<Void, Never> {
        
        // check onboarding was completed; we don't upload metrics until this is done
        guard enabled.state == .enabled else {
            return Empty().eraseToAnyPublisher()
        }
        
        var publishers = [AnyPublisher<Void, NetworkRequestError>]()
        
        // note; we're not checking that these are uploaded successfully - if it fails, they are lost
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
        
        // send the onboarding packet
        let today = GregorianDay.today.startDate(in: .utc)
        let payload = chunkCreator.createTriggeredPayload(dateInterval: DateInterval(start: today, end: today))
        let info = MetricsInfo(
            payload: MetricsInfoPayload.triggeredPayload(payload),
            postalDistrict: getPostcode() ?? "",
            localAuthority: getLocalAuthority() ?? "",
            recordedMetrics: [.completedOnboarding: 1]
        )
        client.fetch(MetricSubmissionEndpoint(), with: info).replaceError(with: ()).sink { _ in }.store(in: &cancellables)
    }
    
    func delete() {
        collector.delete()
    }
}
