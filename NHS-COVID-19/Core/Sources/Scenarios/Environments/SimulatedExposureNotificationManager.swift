//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Domain
import ExposureNotification
import Foundation
import Localization

class SimulatedExposureNotificationManager: ExposureNotificationManaging {
    
    private let queue = DispatchQueue(label: "SimulatedExposureNotificationManager")
    private let dataProvider = MockScenario.mockDataProvider
    
    var instanceAuthorizationStatus: AuthorizationStatus
    
    @Published
    var exposureNotificationStatus: Status
    var exposureNotificationStatusPublisher: AnyPublisher<Status, Never> {
        $exposureNotificationStatus
            .eraseToAnyPublisher()
    }
    
    @Published
    var exposureNotificationEnabled: Bool
    var exposureNotificationEnabledPublisher: AnyPublisher<Bool, Never> {
        $exposureNotificationEnabled
            .eraseToAnyPublisher()
    }
    
    init() {
        instanceAuthorizationStatus = .unknown
        exposureNotificationStatus = .unknown
        exposureNotificationEnabled = false
    }
    
    func activate(completionHandler: @escaping ErrorHandler) {
        queue.async {
            self.instanceAuthorizationStatus = .authorized
            self.exposureNotificationEnabled = true
            self.exposureNotificationStatus = .active
            completionHandler(nil)
        }
    }
    
    func setExposureNotificationEnabled(_ enabled: Bool, completionHandler: @escaping ErrorHandler) {
        queue.async {
            self.exposureNotificationEnabled = enabled
            completionHandler(nil)
        }
    }
    
    func getDiagnosisKeys(completionHandler: @escaping ENGetDiagnosisKeysHandler) {
        queue.async {
            completionHandler([], nil)
        }
    }
    
    func detectExposures(configuration: ENExposureConfiguration, diagnosisKeyURLs: [URL], completionHandler: @escaping ENDetectExposuresHandler) -> Progress {
        queue.async {
            let summary = ENExposureDetectionSummary()
            completionHandler(summary, nil)
        }
        return Progress()
    }
    
    func getExposureInfo(summary: ENExposureDetectionSummary, userExplanation: String, completionHandler: @escaping ENGetExposureInfoHandler) -> Progress {
        let info = repeatElement(SimulatedExposureInfo(daysAgo: dataProvider.contactDaysAgo), count: dataProvider.numberOfContacts)
        queue.async {
            completionHandler(Array(info), nil)
        }
        return Progress()
    }
    
    func getExposureInfo(summary: ENExposureDetectionSummary, completionHandler: @escaping ENGetExposureInfoHandler) {
        _ = getExposureInfo(summary: summary, userExplanation: UUID().uuidString, completionHandler: completionHandler)
    }
    
    @available(iOS 13.7, *)
    func getExposureWindows(summary: ENExposureDetectionSummary, completionHandler: @escaping ENGetExposureWindowsHandler) -> Progress {
        return Progress()
    }
}

private class SimulatedExposureInfo: ENExposureInfo {
    
    private let daysAgo: Int
    private let _attenuationDurations: [NSNumber]
    
    init(daysAgo: Int) {
        self.daysAgo = daysAgo
        _attenuationDurations = [1800, 1800, 1800]
        super.init()
    }
    
    override var date: Date {
        GregorianDay.today.advanced(by: -1).startDate(in: .utc)
    }
    
    override var attenuationDurations: [NSNumber] {
        _attenuationDurations
    }
    
    override var transmissionRiskLevel: ENRiskLevel {
        7
    }
    
}
