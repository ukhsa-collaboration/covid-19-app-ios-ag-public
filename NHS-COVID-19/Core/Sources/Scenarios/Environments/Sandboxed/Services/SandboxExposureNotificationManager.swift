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
    
//    private let queue = DispatchQueue(label: "SandboxExposureNotificationManager", qos: DispatchQoS.userInteractive)
    private let queue = DispatchQueue.main // Using this to see if it improve reliability of tests on the CI.
    private let host: SandboxHost
    private var hasPreviouslyAskedForPermission: Bool = false
    
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
        queue.async { [weak self] in
            guard let self = self else {
                return
            }
            let allowed = self.host.initialState.exposureNotificationsAuthorized
            self.instanceAuthorizationStatus = allowed ? .authorized : .unknown
            self.exposureNotificationEnabled = allowed
            self.hasPreviouslyAskedForPermission = allowed
            self.exposureNotificationStatus = .active
            completionHandler(nil)
        }
    }
    
    func setExposureNotificationEnabled(_ enabled: Bool, completionHandler: @escaping ErrorHandler) {
        guard enabled, !hasPreviouslyAskedForPermission else {
            exposureNotificationEnabled = enabled
            return
        }
        
        hasPreviouslyAskedForPermission = true
        
        let alert = UIAlertController(
            title: AlertText.authorizationAlertTitle.rawValue,
            message: AlertText.authorizationAlertMessage.rawValue,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: AlertText.authorizationAlertDoNotAllow.rawValue, style: .default, handler: { _ in }))
        
        alert.addAction(UIAlertAction(title: AlertText.authorizationAlertAllow.rawValue, style: .default, handler: { [weak self] _ in
            self?.instanceAuthorizationStatus = .authorized
            self?.exposureNotificationEnabled = true
            completionHandler(nil)
        }))
        host.container?.show(alert, sender: nil)
    }
    
    func getDiagnosisKeys(completionHandler: @escaping ENGetDiagnosisKeysHandler) {
        let alert = UIAlertController(
            title: AlertText.diagnosisKeyAlertTitle.rawValue,
            message: AlertText.diagnosisKeyAlertMessage.rawValue,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: AlertText.diagnosisKeyAlertDoNotShare.rawValue, style: .default, handler: { _ in }))
        
        alert.addAction(UIAlertAction(title: AlertText.diagnosisKeyAlertShare.rawValue, style: .default, handler: { [weak self] _ in
            self?.queue.async {
                completionHandler([], nil)
            }
        }))
        host.container?.show(alert, sender: nil)
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
