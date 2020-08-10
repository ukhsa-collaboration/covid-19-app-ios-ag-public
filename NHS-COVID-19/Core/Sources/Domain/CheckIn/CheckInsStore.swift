//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation

public typealias CheckIns = [CheckIn]

private struct CheckInsWrapper: Codable, DataConvertible {
    var checkIns: CheckIns
    var riskApprovalTokens: [String: CircuitBreakerApprovalToken]
    var unacknowldegedRiskyVenueIds: [String]
    
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
    }
    
    private(set) var riskyCheckIns: [CheckIn] = []
    
    @Published
    private(set) var unacknowledgedRiskyCheckIns: [CheckIn] = [] {
        didSet {
            lastUnacknowledgedRiskyCheckIns = unacknowledgedRiskyCheckIns.sorted { $0.checkedIn.date < $1.checkedIn.date }.last
        }
    }
    
    @Published
    private(set) var lastUnacknowledgedRiskyCheckIns: CheckIn? = nil
    
    var riskApprovalTokens: [String: CircuitBreakerApprovalToken] {
        get {
            checkInsInfo?.riskApprovalTokens ?? [:]
        }
        set {
            checkInsInfo?.riskApprovalTokens = newValue
        }
    }
    
    var detectedNewRiskyCheckIns = PassthroughSubject<Void, Never>()
    
    required init(store: EncryptedStoring, venueDecoder: QRCode) {
        self.venueDecoder = venueDecoder
        _checkInsInfo = store.encrypted("checkins")
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
    
    public func load() -> CheckIns? {
        checkInsInfo?.checkIns
    }
    
    func deleteExpired(before date: UTCHour) {
        guard var checkInsInfo = self.checkInsInfo else { return }
        checkInsInfo.checkIns.removeAll {
            $0.checkedIn < date
        }
        
        let hasCheckInFor = { (venueId: String) in
            checkInsInfo.checkIns.contains { $0.venueId.caseInsensitiveCompare(venueId) == .orderedSame }
        }
        
        checkInsInfo.unacknowldegedRiskyVenueIds.removeAll { venueId in
            !hasCheckInFor(venueId)
        }
        
        for venueId in checkInsInfo.riskApprovalTokens.keys {
            if !hasCheckInFor(venueId) {
                checkInsInfo.riskApprovalTokens[venueId] = nil
            }
        }
        
        self.checkInsInfo = checkInsInfo
    }
    
    func updateRisk(_ venueIds: [String]) {
        guard let existingCheckIns = checkInsInfo?.checkIns else { return }
        let updatedCheckins = existingCheckIns.map { checkIn -> CheckIn in
            let containingRiskyVenueId = venueIds.contains { $0.caseInsensitiveCompare(checkIn.venueId) == .orderedSame }
            if containingRiskyVenueId {
                return mutating(checkIn) {
                    $0.isRisky = true
                }
            } else {
                return checkIn
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
        
        save(updatedCheckins)
        if approval == .yes {
            checkInsInfo?.unacknowldegedRiskyVenueIds.append(venueId)
        }
    }
    
    func deleteLatest() {
        Metrics.signpost(.deletedLastCheckIn)
        if checkInsInfo?.checkIns.count == 1 {
            checkInsInfo = nil
        } else {
            checkInsInfo?.checkIns.removeLast()
        }
    }
    
    func deleteAll() {
        checkInsInfo = nil
    }
    
    func acknowldegeRiskyCheckIns() {
        let checkInsInfo = mutating(self.checkInsInfo) {
            $0?.unacknowldegedRiskyVenueIds = []
        }
        _ = save(checkInsInfo)
    }
    
    public func checkIn(with payload: String) throws -> (String, () -> Void) {
        let venue = try venueDecoder.parse(payload)
        let checkIn = CheckIn(venue: venue, checkedInDate: Date())
        save(checkIn)
        return (venue.organisation, deleteLatest)
    }
    
    private func save(_ checkIns: [CheckIn]) {
        save(CheckInsWrapper(
            checkIns: checkIns,
            riskApprovalTokens: checkInsInfo?.riskApprovalTokens ?? [:],
            unacknowldegedRiskyVenueIds: checkInsInfo?.unacknowldegedRiskyVenueIds ?? []
        ))
    }
    
    private func save(_ checkInsInfo: CheckInsWrapper?) {
        self.checkInsInfo = checkInsInfo
    }
}
