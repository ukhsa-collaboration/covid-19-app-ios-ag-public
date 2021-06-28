//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation
import Logging
import UIKit

public class RiskyPostcodeEndpointManager {
    public struct PostcodeRisk: Equatable {
        public enum RiskType {
            case postcode
            case localAuthority
        }
        
        let id: String
        public let style: RiskyPostcodes.RiskStyle
        public let type: RiskType
        
        public init(id: String, style: RiskyPostcodes.RiskStyle, type: RiskType) {
            self.id = id
            self.style = style
            self.type = type
        }
    }
    
    private static let logger = Logger(label: "RiskyPostcodeEndpointManager")
    
    private let currentDateProvider: DateProviding
    private let cachedResponse: CachedResponse<RiskyPostcodes>
    private var cancellables = [AnyCancellable]()
    private var currentPostcodeFetchCancellable: AnyCancellable?
    private var rawState: DomainProperty<RawState>?
    private let minimumUpdateIntervalProvider: MinimumUpdateIntervalProviding
    
    let postcodeInfo: DomainProperty<(postcode: Postcode, localAuthority: LocalAuthority?, risk: DomainProperty<PostcodeRisk?>)?>
    
    var isEmpty: Bool {
        cachedResponse.value.isEmpty
    }
    
    init(
        distributeClient: HTTPClient,
        storage: FileStoring,
        postcode: AnyPublisher<Postcode?, Never>,
        localAuthority: AnyPublisher<LocalAuthority?, Never>,
        currentDateProvider: DateProviding,
        minimumUpdateIntervalProvider: MinimumUpdateIntervalProviding
    ) {
        
        let cachedResponse = CachedResponse(
            httpClient: distributeClient,
            endpoint: RiskyPostcodesEndpointV2(),
            storage: storage,
            name: "risky_postcodes_v2",
            initialValue: RiskyPostcodes(postDistricts: [:], riskLevels: [:]),
            currentDateProvider: currentDateProvider
        )
        
        postcodeInfo = postcode.combineLatest(localAuthority) { postcode, localAuthority -> (postcode: Postcode, localAuthority: LocalAuthority?, risk: DomainProperty<PostcodeRisk?>)? in
            guard let postcode = postcode else { return nil }
            let risk = cachedResponse.$value
                .map { v2 -> PostcodeRisk? in
                    if let localAuthority = localAuthority,
                        let v2LocalAuthorityRisk = v2.riskStyle(for: localAuthority.id) {
                        return PostcodeRisk(id: v2LocalAuthorityRisk.id, style: v2LocalAuthorityRisk.style, type: .localAuthority)
                    } else if let v2Risk = v2.riskStyle(for: postcode) {
                        return PostcodeRisk(id: v2Risk.id, style: v2Risk.style, type: .postcode)
                    } else {
                        return nil
                    }
                }
                .domainProperty()
            return (postcode, localAuthority, risk)
        }
        .domainProperty()
        
        self.cachedResponse = cachedResponse
        self.currentDateProvider = currentDateProvider
        self.minimumUpdateIntervalProvider = minimumUpdateIntervalProvider
    }
    
    /// Trigger a discretionary update based on the last time it was downloaded
    func update() -> AnyPublisher<Void, Never> {
        
        guard !cachedResponse.updating else {
            Self.logger.info("Ignoring risky postcode update as we're already fetching it")
            return Just(()).eraseToAnyPublisher()
        }
        
        // check we don't reload the content too often - this may become obsolete when http caching is implememted
        let now = currentDateProvider.currentDate
        if let lastUpdate = cachedResponse.lastUpdated, now.timeIntervalSince(lastUpdate) < minimumUpdateIntervalProvider.interval {
            Self.logger.info("Ignoring risky postcode update as the last one was too recent")
            return Just(()).eraseToAnyPublisher()
        }
        
        Self.logger.info("Loading risky postcode content")
        
        return startUpdate()
    }
    
    /// Force a reload regardless of the last time it was done e.g. postcode change
    func reload() {
        startUpdate()
            .sink {}
            .store(in: &cancellables)
    }
    
    private func startUpdate() -> AnyPublisher<Void, Never> {
        return cachedResponse
            .update()
            .eraseToAnyPublisher()
    }
}

extension RiskyPostcodeEndpointManager {
    
    func monitorRiskyPostcodes() {
        
        // assuming this is called shortly after the app launches, check if we need to update now
        runUpdate()
        
        // now listen for foreground events and check again when they happen
        #warning("This is adding a new sub to .willEnterForegroundNotification when the app transitions in and out of .fullyOnboarded")
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.runUpdate()
            }
            .store(in: &cancellables)
    }
    
    private func runUpdate() {
        
        Self.logger.debug("Starting postcode update call")
        currentPostcodeFetchCancellable = update().sink { [weak self] _ in
            Self.logger.debug("Completed postcode update call")
            self?.currentPostcodeFetchCancellable = nil
        }
    }
}
