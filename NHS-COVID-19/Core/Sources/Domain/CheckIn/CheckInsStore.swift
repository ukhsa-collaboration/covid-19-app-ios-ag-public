//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation

public typealias CheckIns = [CheckIn]

private struct CheckInsWrapper: Codable, DataConvertible {
    var checkIns: CheckIns
    var riskApprovalTokens: [String: CircuitBreakerApprovalToken]
    
    // IMPORTANT: This is mis-spelled, but do not rename it since it would break reading data in the wild.
    // This type is private and only used for `Codable` conformance, so the impact is contained.
    var unacknowldegedRiskyVenueIds: [String]
    
    // For the purposes of this struct, "risky" = "triggering a 'warn and book a test' notification"
    var mostRecentRiskyVenueCheckInDay: GregorianDay?
    var cachedRiskyVenueConfiguration: RiskyVenueConfiguration?
    
    var riskyCheckIns: CheckIns {
        checkIns.filter { $0.isRisky }
    }
}

public class CheckInsStore {
    
    private let venueDecoder: QRCode
    
    @Encrypted<CheckInsWrapper> private var checkInsInfo: CheckInsWrapper? {
        didSet {
            updateProperties()
        }
    }
    
    private func updateProperties() {
        let info = checkInsInfo
        let unacknowldegedRiskyVenueIds = info?.unacknowldegedRiskyVenueIds ?? []
        let riskyCheckIns = info?.riskyCheckIns ?? []
        self.riskyCheckIns = riskyCheckIns
        unacknowledgedRiskyCheckIns = unacknowldegedRiskyVenueIds.compactMap { venueId in
            riskyCheckIns.first { $0.venueId.caseInsensitiveCompare(venueId) == .orderedSame }
        }
        mostRecentRiskyCheckInDay = info?.mostRecentRiskyVenueCheckInDay
        mostRecentRiskyVenueConfiguration = info?.cachedRiskyVenueConfiguration
        checkIns = info?.checkIns ?? []
    }
    
    private(set) var riskyCheckIns: [CheckIn] = []
    
    @Published
    private(set) var checkIns: [CheckIn] = []
    
    @Published
    private(set) var unacknowledgedRiskyCheckIns: [CheckIn] = [] {
        didSet {
            mostRecentAndSevereUnacknowledgedRiskyCheckIn = unacknowledgedRiskyCheckIns.sorted {
                $0.isMoreRecentAndSevere(than: $1)
            }.first
        }
    }
    
    @Published
    private(set) var mostRecentAndSevereUnacknowledgedRiskyCheckIn: CheckIn? = nil
    
    var riskApprovalTokens: [String: CircuitBreakerApprovalToken] {
        get {
            checkInsInfo?.riskApprovalTokens ?? [:]
        }
        set {
            checkInsInfo?.riskApprovalTokens = newValue
        }
    }
    
    var detectedNewRiskyCheckIns = PassthroughSubject<Void, Never>()
    
    @Published
    private(set) var mostRecentRiskyCheckInDay: GregorianDay? = nil
    
    @Published
    private(set) var mostRecentRiskyVenueConfiguration: RiskyVenueConfiguration? = nil
    
    private let getCachedRiskyVenueConfiguration: () -> RiskyVenueConfiguration
    
    required init(store: EncryptedStoring,
                  venueDecoder: QRCode,
                  getCachedRiskyVenueConfiguration: @escaping () -> RiskyVenueConfiguration) {
        self.venueDecoder = venueDecoder
        _checkInsInfo = store.encrypted("checkins")
        self.getCachedRiskyVenueConfiguration = getCachedRiskyVenueConfiguration
        updateProperties()
    }
    
    func save(_ checkIn: CheckIn) {
        if var checkIns = checkInsInfo?.checkIns {
            // Automatically check out the last checkIn
            if let lastCheckIn = checkIns.last {
                if checkIn.checkedIn < lastCheckIn.checkedOut {
                    checkIns[checkIns.count - 1].checkedOut = UTCHour(roundedUpToQuarter: checkIn.checkedIn.date)
                }
            }
            checkIns.append(checkIn)
            save(checkIns)
        } else {
            save([checkIn])
        }
        Metrics.signpost(.checkedIn)
    }
    
    func saveMostRecentRiskyVenueCheckIn(on newRiskyCheckInDay: GregorianDay) {
        guard var mutatedWrapper = checkInsInfo else {
            return
        }
        
        if let existingRiskyCheckInDay = mutatedWrapper.mostRecentRiskyVenueCheckInDay,
            existingRiskyCheckInDay >= newRiskyCheckInDay {
            return
        }
        
        /// NOTE: For now, `mostRecentRiskyVenueCheckInDay` and `cachedRiskyVenueConfiguration` are updated and saved together.
        mutatedWrapper.mostRecentRiskyVenueCheckInDay = newRiskyCheckInDay
        mutatedWrapper.cachedRiskyVenueConfiguration = getCachedRiskyVenueConfiguration()
        save(mutatedWrapper)
    }
    
    func deleteMostRecentRiskyVenueCheckIn() {
        guard var mutatedWrapper = checkInsInfo else {
            return
        }
        mutatedWrapper.mostRecentRiskyVenueCheckInDay = nil
        mutatedWrapper.cachedRiskyVenueConfiguration = nil
        save(mutatedWrapper)
    }
    
    public func load() -> CheckIns? {
        checkInsInfo?.checkIns
    }
    
    func deleteExpired(before date: UTCHour) {
        guard var checkInsInfo = self.checkInsInfo else { return }
        checkInsInfo.checkIns.removeAll {
            $0.checkedIn < date
        }
        
        self.checkInsInfo = updateRiskyProperties(checkInsInfo)
    }
    
    func updateRisk(_ riskyVenues: [RiskyVenue]) {
        guard let existingCheckIns = checkInsInfo?.checkIns else { return }
        var updatedCheckins: CheckIns = []
        
        existingCheckIns.forEach { checkIn in
            let relevantRiskyVenue = riskyVenues
                .filter { riskyVenue in
                    riskyVenue.id.caseInsensitiveCompare(checkIn.venueId) == .orderedSame
                        && riskyVenue.riskyInterval.intersects(checkIn.checkedInInterval)
                }
                .sorted()
                .first
            
            if let riskyVenue = relevantRiskyVenue {
                let mutatedCheckIn = mutating(checkIn) {
                    $0.isRisky = true
                    $0.venueMessageType = riskyVenue.messageType
                }
                updatedCheckins.append(mutatedCheckIn)
            } else {
                updatedCheckins.append(checkIn)
            }
        }
        
        save(updatedCheckins)
        detectedNewRiskyCheckIns.send(())
    }
    
    func set(_ approval: CircuitBreakerApproval, for venueId: String) {
        guard let existingCheckIns = checkInsInfo?.checkIns else { return }
        
        let updatedCheckins = existingCheckIns.map { checkIn -> CheckIn in
            if venueId.caseInsensitiveCompare(checkIn.venueId) == .orderedSame {
                return mutating(checkIn) {
                    $0.circuitBreakerApproval = approval
                }
            } else {
                return checkIn
            }
        }
        
        if let mostRecentDay = mostRecentWarnAndBookATestCheckInDay(from: updatedCheckins) {
            saveMostRecentRiskyVenueCheckIn(on: mostRecentDay)
        }
        
        save(updatedCheckins)
        if approval == .yes {
            checkInsInfo?.unacknowldegedRiskyVenueIds.append(venueId)
        }
    }
    
    private func mostRecentWarnAndBookATestCheckInDay(from checkIns: [CheckIn]) -> GregorianDay? {
        return checkIns
            .filter { $0.circuitBreakerApproval == .yes && $0.venueMessageType == .some(.warnAndBookATest) }
            .sorted { $0.isMoreRecentAndSevere(than: $1) }
            .first?.checkedIn.day
    }
    
    func deleteLatest() {
        Metrics.signpost(.deletedLastCheckIn)
        if checkInsInfo?.checkIns.count == 1 {
            checkInsInfo = nil
        } else {
            checkInsInfo?.checkIns.removeLast()
        }
    }
    
    func delete(checkInId: String) {
        guard var checkInsInfo = self.checkInsInfo else { return }
        checkInsInfo.checkIns.removeAll {
            $0.id == checkInId
        }
        
        self.checkInsInfo = updateRiskyProperties(checkInsInfo)
    }
    
    private func updateRiskyProperties(_ checkInsInfo: CheckInsWrapper) -> CheckInsWrapper {
        var copy = checkInsInfo
        let checkins = copy.checkIns
        let hasCheckInFor = { (venueId: String) in
            checkins.contains { $0.venueId.caseInsensitiveCompare(venueId) == .orderedSame }
        }
        
        copy.unacknowldegedRiskyVenueIds.removeAll { venueId in
            !hasCheckInFor(venueId)
        }
        
        for venueId in copy.riskApprovalTokens.keys {
            if !hasCheckInFor(venueId) {
                copy.riskApprovalTokens[venueId] = nil
            }
        }
        
        return copy
    }
    
    func deleteAll() {
        checkInsInfo = nil
    }
    
    func acknowldegeRiskyCheckIns() {
        let checkInsInfo = mutating(self.checkInsInfo) {
            $0?.unacknowldegedRiskyVenueIds = []
        }
        save(checkInsInfo)
    }
    
    public func checkIn(with payload: String, currentDate: Date) throws -> (String, () -> Void) {
        let venue = try venueDecoder.parse(payload)
        let checkIn = CheckIn(venue: venue, checkedInDate: currentDate)
        save(checkIn)
        return (venue.organisation, deleteLatest)
    }
    
    private func save(_ checkIns: [CheckIn]) {
        save(CheckInsWrapper(
            checkIns: checkIns,
            riskApprovalTokens: checkInsInfo?.riskApprovalTokens ?? [:],
            unacknowldegedRiskyVenueIds: checkInsInfo?.unacknowldegedRiskyVenueIds ?? [],
            mostRecentRiskyVenueCheckInDay: checkInsInfo?.mostRecentRiskyVenueCheckInDay,
            cachedRiskyVenueConfiguration: checkInsInfo?.cachedRiskyVenueConfiguration
        ))
    }
    
    private func save(_ checkInsInfo: CheckInsWrapper?) {
        self.checkInsInfo = checkInsInfo
    }
}
