//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import ExposureNotification
import Foundation

struct ExposureWindowInfo: Codable, Equatable {
    var date: GregorianDay
    var infectiousness: Infectiousness
    var scanInstances: [ScanInstance]
    var riskScore: Double
    var riskCalculationVersion: Int
    
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
        riskCalculationVersion: Int
    ) {
        self.date = date
        self.infectiousness = infectiousness
        self.scanInstances = scanInstances
        self.riskScore = riskScore
        self.riskCalculationVersion = riskCalculationVersion
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
            riskCalculationVersion: riskInfo.riskScoreVersion
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
    
    init(store: EncryptedStoring) {
        _exposureWindowsInfo = store.encrypted("exposure_window_store")
    }
    
    func load() -> ExposureWindowInfoCollection? {
        return exposureWindowsInfo
    }
    
    func append(_ infos: [ExposureWindowInfo]) {
        if let current = exposureWindowsInfo {
            var exposureWindowInfoCollection = current
            exposureWindowInfoCollection.exposureWindowsInfo.append(contentsOf: infos)
            save(exposureWindowInfoCollection)
        } else {
            save(ExposureWindowInfoCollection(exposureWindowsInfo: infos))
        }
    }
    
    private func save(_ collection: ExposureWindowInfoCollection) {
        exposureWindowsInfo = collection
    }
    
    func delete() {
        exposureWindowsInfo = nil
    }
}
