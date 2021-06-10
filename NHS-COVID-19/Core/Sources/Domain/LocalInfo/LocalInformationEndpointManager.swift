//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation
import Logging
import UIKit // for UIApplication.willEnterForegroundNotification

public class LocalInformationEndpointManager {
    
    struct CurrentLocalInfo: DataConvertible {
        let messageAndVersion: String
        var data: Data {
            messageAndVersion.data(using: .utf8) ?? Data()
        }
        
        init(data: Data) throws {
            messageAndVersion = String(data: data, encoding: .utf8) ?? ""
        }
        
        init(messageAndVersion: String) {
            self.messageAndVersion = messageAndVersion
        }
    }
    
    private static let logger = Logger(label: "LocalInformationEndpointManager")
    
    private let currentDateProvider: DateProviding
    private let cachedResponse: CachedResponse<LocalInformation>
    private var cancellables = [AnyCancellable]()
    private var currentLocalInfoFetchCancellable: AnyCancellable?
    private let localInformationSubject = CurrentValueSubject<LocalInfo?, Never>(nil)
    
    static let minimumUpdateInterval: TimeInterval = 10 * 60
    
    @PublishedEncrypted
    private var currentLocalInfo: CurrentLocalInfo?
    
    public typealias LocalInfo = (localAuthority: LocalAuthority?, info: LocalInformation.MessageContentContainer?, notify: Bool)
    typealias LocalInfoUpdate = (old: LocalInformation?, new: LocalInformation?)
    
    var isEmpty: Bool {
        cachedResponse.value.isEmpty
    }
    
    var localInformation: DomainProperty<LocalInfo?> {
        localInformationSubject
            .domainProperty()
    }
    
    init(distributeClient: HTTPClient, storage cachesStorage: FileStoring, encryptedStorage: EncryptedStoring, localAuthority: AnyPublisher<LocalAuthority?, Never>, currentDateProvider: DateProviding) {
        
        _currentLocalInfo = encryptedStorage.encrypted("current_local_information")
        
        // this subject is used to inform us when the store updates
        let updatedSubject = CurrentValueSubject<LocalInfoUpdate?, Never>(nil)
        
        // set up the cached response for this endpoint
        let cachedResponse = CachedResponse(
            httpClient: distributeClient,
            endpoint: LocalInformationEndpoint(),
            storage: cachesStorage,
            name: "local_information",
            initialValue: LocalInformation(las: [:], messages: [:]),
            currentDateProvider: currentDateProvider,
            updatedSubject: updatedSubject
        )
        
        self.cachedResponse = cachedResponse
        self.currentDateProvider = currentDateProvider
        
        if let currentClearLocalInfo = FileStored<CurrentLocalInfo>(storage: cachesStorage, name: "current_local_information").wrappedValue {
            currentLocalInfo = currentClearLocalInfo
            cachesStorage.delete("current_local_information")
        }
        
        // monitor the user's local authority and the store
        localAuthority
            .combineLatest(updatedSubject.domainProperty())
            .sink { [weak self] localAuthority, localInfo in
                self?.handleUpdate(localAuthority: localAuthority, localInfo: localInfo)
            }
            .store(in: &cancellables)
        
        // load any cached info
        cachedResponse.load()
    }
    
    /// Trigger a discretionary update based on the last time it was downloaded
    func update() -> AnyPublisher<Void, Never> {
        
        guard !cachedResponse.updating else {
            Self.logger.info("Ignoring local info update as we're already fetching it")
            return Just(()).eraseToAnyPublisher()
        }
        
        // check we don't reload the content too often - this may become obsolete when http caching is implememted
        let now = currentDateProvider.currentDate
        if let lastUpdate = cachedResponse.lastUpdated, now.timeIntervalSince(lastUpdate) < Self.minimumUpdateInterval {
            Self.logger.info("Ignoring local info update as the last one was too recent")
            return Just(()).eraseToAnyPublisher()
        }
        
        Self.logger.info("Loading local info content")
        
        return startUpdate()
    }
    
    /// Force a reload regardless of the last time it was done e.g. local authority change
    func reload() {
        startUpdate()
            .sink {}
            .store(in: &cancellables)
    }
    
    func deleteCurrentInfo() {
        currentLocalInfo = nil
    }
    
    private func startUpdate() -> AnyPublisher<Void, Never> {
        return cachedResponse
            .update()
            .eraseToAnyPublisher()
    }
    
    private func handleUpdate(localAuthority: LocalAuthority?, localInfo: LocalInfoUpdate?) {
        
        guard let localAuthority = localAuthority,
            let localInfo = localInfo else { return }
        
        // figure out the combined message and version of the new local info
        let newMessageAndVersion: String? = {
            if let newMessageInfo = localInfo.new?.message(for: localAuthority.id) {
                return "\(newMessageInfo.id).\(newMessageInfo.message.contentVersion)"
            }
            return nil
        }()
        
        // figure out if we need to notify the user of a change
        let notify: Bool = {
            if let currentLocalInfo = currentLocalInfo?.messageAndVersion,
                let newMessageAndVersion = newMessageAndVersion {
                return currentLocalInfo != newMessageAndVersion
            }
            return newMessageAndVersion != nil
        }()
        
        // store the new combined message and version (or nil)
        currentLocalInfo = newMessageAndVersion.map { CurrentLocalInfo(messageAndVersion: $0) }
        
        // post the update
        let new = localInfo.new?.message(for: localAuthority.id)?.message
        let update = (localAuthority: localAuthority, info: new, notify: notify)
        localInformationSubject.send(update)
    }
}

extension LocalInformationEndpointManager {
    
    func monitorLocalInformation() {
        
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
        
        Self.logger.debug("Starting local info update call")
        currentLocalInfoFetchCancellable = update().sink { [weak self] _ in
            Self.logger.debug("Completed local info update call")
            self?.currentLocalInfoFetchCancellable = nil
        }
    }
}

extension LocalInformationEndpointManager {
    
    func recordMetrics() -> AnyPublisher<Void, Never> {
        Future<Void, Never> { [weak self] promise in
            guard let self = self else {
                promise(.success(()))
                return
            }
            
            if self.localInformationSubject.value?.info != nil {
                Metrics.signpost(.isDisplayingLocalInfoBackgroundTick)
            }
            
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
    
}
