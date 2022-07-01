//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct ExposureInfo: Codable {
    var approvalToken: CircuitBreakerApprovalToken?
    var riskInfo: RiskInfo
}

public struct ExposureDetectionInfo: Codable, DataConvertible {
    var lastKeyDownloadDate: Date?
    var exposureInfo: ExposureInfo?
}

class ExposureDetectionStore {

    @Encrypted private var exposureDetectionInfo: ExposureDetectionInfo?

    @Published
    var exposureInfo: ExposureInfo? {
        didSet {
            exposureDetectionInfo = ExposureDetectionInfo(
                lastKeyDownloadDate: exposureDetectionInfo?.lastKeyDownloadDate,
                exposureInfo: exposureInfo
            )
        }
    }

    init(store: EncryptedStoring) {
        _exposureDetectionInfo = store.encrypted("background_task_state")
        exposureInfo = exposureDetectionInfo?.exposureInfo
    }

    public func save(lastKeyDownloadDate: Date) {
        exposureDetectionInfo = ExposureDetectionInfo(
            lastKeyDownloadDate: lastKeyDownloadDate,
            exposureInfo: exposureDetectionInfo?.exposureInfo
        )
    }

    private func newRiskInfo(current: RiskInfo?, incoming: RiskInfo) -> RiskInfo? {
        guard let current = current else { return incoming }
        if incoming.isHigherPriority(than: current) {
            return incoming
        }
        return nil
    }

    public func save(riskInfo: RiskInfo) {
        guard let riskInfo = newRiskInfo(current: exposureInfo?.riskInfo, incoming: riskInfo) else { return }
        exposureInfo = ExposureInfo(
            approvalToken: nil,
            riskInfo: riskInfo
        )
    }

    public func load() -> ExposureDetectionInfo? {
        exposureDetectionInfo
    }

    public func delete() {
        exposureDetectionInfo = nil
        exposureInfo = nil
    }
}
