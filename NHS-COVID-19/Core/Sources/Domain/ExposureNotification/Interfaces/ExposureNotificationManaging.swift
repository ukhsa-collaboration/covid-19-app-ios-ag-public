//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import ExposureNotification
import Foundation

public protocol ExposureNotificationManaging {
    typealias ErrorHandler = ENErrorHandler
    typealias AuthorizationStatus = ENAuthorizationStatus
    typealias Status = ENStatus
    typealias DetectExposuresHandler = ENDetectExposuresHandler
    
    var instanceAuthorizationStatus: AuthorizationStatus { get }
    
    var exposureNotificationStatus: Status { get }
    var exposureNotificationStatusPublisher: AnyPublisher<Status, Never> { get }
    
    var exposureNotificationEnabled: Bool { get }
    var exposureNotificationEnabledPublisher: AnyPublisher<Bool, Never> { get }
    
    func activate(completionHandler: @escaping ErrorHandler)
    
    func setExposureNotificationEnabled(_ enabled: Bool, completionHandler: @escaping ErrorHandler)
    
    func getDiagnosisKeys(completionHandler: @escaping ENGetDiagnosisKeysHandler)
    
    @discardableResult
    func detectExposures(configuration: ENExposureConfiguration, diagnosisKeyURLs: [URL], completionHandler: @escaping ENDetectExposuresHandler) -> Progress
    
    @discardableResult
    func getExposureInfo(summary: ENExposureDetectionSummary, userExplanation: String, completionHandler: @escaping ENGetExposureInfoHandler) -> Progress
    
    func getExposureInfo(summary: ENExposureDetectionSummary, completionHandler: @escaping ENGetExposureInfoHandler)
    
    @available(iOS 13.7, *)
    @discardableResult
    func getExposureWindows(summary: ENExposureDetectionSummary, completionHandler: @escaping ENGetExposureWindowsHandler) -> Progress
}
