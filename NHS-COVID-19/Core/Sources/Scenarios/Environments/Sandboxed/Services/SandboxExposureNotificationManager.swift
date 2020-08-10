//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Domain
import ExposureNotification
import Foundation
import Localization
import UIKit

class SandboxExposureNotificationManager: ExposureNotificationManaging {
    
    typealias AlertText = Sandbox.Text.ExposureNotification
    
    private let queue = DispatchQueue(label: "SandboxExposureNotificationManager")
    private let dataProvider = MockScenario.mockDataProvider
    private let host: SandboxHost
    
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
    
    init(host: SandboxHost) {
        self.host = host
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
        let alert = UIAlertController(
            title: AlertText.authorizationAlertTitle.rawValue,
            message: AlertText.authorizationAlertMessage.rawValue,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: AlertText.authorizationAlertDoNotAllow.rawValue, style: .default, handler: { _ in
        }))
        alert.addAction(UIAlertAction(title: AlertText.authorizationAlertAllow.rawValue, style: .default, handler: { _ in
            completionHandler(nil)
        }))
        host.container?.show(alert, sender: nil)
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
        queue.async {
            completionHandler([], nil)
        }
        return Progress()
    }
    
    func getExposureInfo(summary: ENExposureDetectionSummary, completionHandler: @escaping ENGetExposureInfoHandler) {
        _ = getExposureInfo(summary: summary, userExplanation: UUID().uuidString, completionHandler: completionHandler)
    }
}
