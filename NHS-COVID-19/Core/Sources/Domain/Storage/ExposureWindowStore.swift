//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
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
    }
    
    enum Infectiousness: String, Codable, Equatable {
        case none
        case standard
        case high
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
    
    func append(_ info: ExposureWindowInfo) {
        if let current = exposureWindowsInfo {
            var exposureWindowInfoCollection = current
            exposureWindowInfoCollection.exposureWindowsInfo.append(info)
            save(exposureWindowInfoCollection)
        } else {
            save(ExposureWindowInfoCollection(exposureWindowsInfo: [info]))
        }
    }
    
    private func save(_ collection: ExposureWindowInfoCollection) {
        exposureWindowsInfo = collection
    }
    
    func delete() {
        exposureWindowsInfo = nil
    }
}
