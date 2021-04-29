//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import ExposureNotification
import Foundation
import Logging

struct ExposureWindowInfo: Codable, Equatable {
    var date: GregorianDay
    var infectiousness: Infectiousness
    var scanInstances: [ScanInstance]
    var riskScore: Double
    var riskCalculationVersion: Int
    var isConsideredRisky: Bool
    
    struct ScanInstance: Codable, Equatable {
        var minimumAttenuation: UInt8
        var typicalAttenuation: UInt8
        var secondsSinceLastScan: Int
        
        init(minimumAttenuation: UInt8, typicalAttenuation: UInt8, secondsSinceLastScan: Int) {
            self.minimumAttenuation = minimumAttenuation
            self.typicalAttenuation = typicalAttenuation
            self.secondsSinceLastScan = secondsSinceLastScan
        }
    }
    
    enum Infectiousness: String, Codable, Equatable {
        case none
        case standard
        case high
    }
    
    init(
        date: GregorianDay,
        infectiousness: ExposureWindowInfo.Infectiousness,
        scanInstances: [ExposureWindowInfo.ScanInstance],
        riskScore: Double,
        riskCalculationVersion: Int,
        isConsideredRisky: Bool
    ) {
        self.date = date
        self.infectiousness = infectiousness
        self.scanInstances = scanInstances
        self.riskScore = riskScore
        self.riskCalculationVersion = riskCalculationVersion
        self.isConsideredRisky = isConsideredRisky
    }
}

extension ExposureWindowInfo {
    @available(iOS 13.7, *)
    init(exposureWindow: ExposureNotificationExposureWindow, riskInfo: ExposureRiskInfo) {
        self.init(
            date: GregorianDay(date: exposureWindow.date, timeZone: .utc),
            infectiousness: ExposureWindowInfo.Infectiousness(exposureWindow.infectiousness),
            scanInstances: exposureWindow.enScanInstances.map { ExposureWindowInfo.ScanInstance($0) },
            riskScore: riskInfo.riskScore,
            riskCalculationVersion: riskInfo.riskScoreVersion,
            isConsideredRisky: riskInfo.isConsideredRisky
        )
    }
}

extension ExposureWindowInfo.Infectiousness {
    @available(iOS 13.7, *)
    init(_ infectioness: ENInfectiousness) {
        switch infectioness {
        case .none: self = ExposureWindowInfo.Infectiousness.none
        case .standard: self = ExposureWindowInfo.Infectiousness.standard
        case .high: self = ExposureWindowInfo.Infectiousness.high
        @unknown default: self = ExposureWindowInfo.Infectiousness.none
        }
    }
}

extension ExposureWindowInfo.ScanInstance {
    @available(iOS 13.7, *)
    init(_ scanInstance: ExposureNotificationScanInstance) {
        minimumAttenuation = scanInstance.minimumAttenuation
        typicalAttenuation = scanInstance.typicalAttenuation
        secondsSinceLastScan = scanInstance.secondsSinceLastScan
    }
}

struct ExposureWindowInfoCollection: Codable, Equatable, DataConvertible {
    var exposureWindowsInfo: [ExposureWindowInfo]
}

class ExposureWindowStore {
    @Encrypted private var exposureWindowsInfo: ExposureWindowInfoCollection?
    
    private static var logger = Logger(label: "ExposureWindowStore")
    /// Limit of non-risky windows to be stored
    var nonRiskyWindowsLimit: Int
    
    init(store: EncryptedStoring, nonRiskyWindowsLimit: Int = ExposureWindowInfo.nonRiskyWindowStoreLimit) {
        _exposureWindowsInfo = store.encrypted("exposure_window_store")
        self.nonRiskyWindowsLimit = nonRiskyWindowsLimit
    }
    
    func load() -> ExposureWindowInfoCollection? {
        return exposureWindowsInfo
    }
    
    func append(_ infos: [ExposureWindowInfo]) {
        
        let collectionToStore: ExposureWindowInfoCollection = {
            if var current = exposureWindowsInfo {
                // store has existing windows so append all new risky windows and up to a combined store limit of existing and new non-risky windows
                let combinedNonRiskyWindows = (current.exposureWindowsInfo.nonRiskyWindows + infos.nonRiskyWindows).suffix(nonRiskyWindowsLimit)
                current.exposureWindowsInfo = current.exposureWindowsInfo.riskyWindows + infos.riskyWindows + combinedNonRiskyWindows
                return current
            } else {
                // store is empty so save all risky and up to the store limit of non-risky windows
                return ExposureWindowInfoCollection(exposureWindowsInfo: infos.riskyWindows + infos.nonRiskyWindows.suffix(nonRiskyWindowsLimit))
            }
        }()
        
        save(collectionToStore)
    }
    
    private func save(_ collection: ExposureWindowInfoCollection) {
        exposureWindowsInfo = collection
    }
    
    // delete all exposure windows
    func delete() {
        exposureWindowsInfo = nil
    }

    // delete windows before and on 'includingAndPriorTo'
    func deleteWindows(includingAndPriorTo: GregorianDay) {
        guard let current = exposureWindowsInfo else {
            return
        }
        var exposureWindowInfoCollection = current
        exposureWindowInfoCollection.exposureWindowsInfo.removeAll {
            if $0.date <= includingAndPriorTo {
                Self.logger.debug("Expiring exposure window with date of \($0.date)")
                return true
            }
            return false
        }
        save(exposureWindowInfoCollection)
    }
}

// Decodable init
extension ExposureWindowInfo {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        date = try container.decode(GregorianDay.self, forKey: .date)
        infectiousness = try container.decode(Infectiousness.self, forKey: .infectiousness)
        scanInstances = try container.decode([ScanInstance].self, forKey: .scanInstances)
        riskScore = try container.decode(Double.self, forKey: .riskScore)
        riskCalculationVersion = try container.decode(Int.self, forKey: .riskCalculationVersion)
        isConsideredRisky = try container.decodeIfPresent(Bool.self, forKey: .isConsideredRisky) ?? true
        
    }
}
