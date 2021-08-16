//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation
import Logging
import UIKit

class MetricReporter: NSObject {
    
    private static let logger = Logger(label: "MetricReporter")
    
    private let client: HTTPClient
    private let collector: MetricCollector
    private let enabled: MetricsState
    private let getPostcode: () -> String?
    private let getLocalAuthority: () -> String?
    private let chunkCreator: MetricUploadChunkCreator
    private var cancellables = [AnyCancellable]()
    private let currentDateProvider: DateProviding
    private let getHouseKeepingDayDuration: () -> DayDuration
    
    init(
        client: HTTPClient,
        encryptedStore: EncryptedStoring,
        currentDateProvider: DateProviding,
        appInfo: AppInfo,
        getPostcode: @escaping () -> String?,
        getLocalAuthority: @escaping () -> String?,
        getHouseKeepingDayDuration: @escaping () -> DayDuration,
        metricCollector: MetricCollector? = nil,
        metricChunkCreator: MetricUploadChunkCreator? = nil
    ) {
        self.client = client
        self.getPostcode = getPostcode
        self.getLocalAuthority = getLocalAuthority
        self.currentDateProvider = currentDateProvider
        self.getHouseKeepingDayDuration = getHouseKeepingDayDuration
        
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
    
    private func executeHousekeeping() {
        Self.logger.debug("execute housekeeping; deleting expired metric entries")
        let today = currentDateProvider.currentGregorianDay(timeZone: .utc)
        let housekeepingDuration = getHouseKeepingDayDuration().days
        let keepAfterDate = today.advanced(by: -housekeepingDuration).startDate(in: .utc)
        collector.consumeMetricsNotOnOrAfter(date: keepAfterDate)
    }
    
    func createHouskeepingPublisher() -> AnyPublisher<Void, Never> {
        Future<Void, Never> { [weak self] promise in
            guard let self = self else {
                promise(.success(()))
                return
            }
            self.executeHousekeeping()
            promise(.success(()))
        }.eraseToAnyPublisher()
    }
    
    func delete() {
        collector.delete()
    }
}

extension MetricReporter {
    
    func monitorHousekeeping() {
        
        // assuming this is called shortly after the app launches, execute housekeeping now
        executeHousekeeping()
        
        // now listen for foreground events and check again when they happen
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.executeHousekeeping()
            }
            .store(in: &cancellables)
    }
}
