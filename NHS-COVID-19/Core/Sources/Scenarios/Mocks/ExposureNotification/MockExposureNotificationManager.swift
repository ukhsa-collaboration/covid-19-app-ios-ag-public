//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Domain
import ExposureNotification
import Foundation
import Localization

public class MockExposureNotificationManager: ExposureNotificationManaging {
    
    public var instanceAuthorizationStatus = AuthorizationStatus.unknown
    
    @Published
    public var exposureNotificationStatus = Status.unknown
    
    public var exposureNotificationStatusPublisher: AnyPublisher<Status, Never> {
        $exposureNotificationStatus
            .eraseToAnyPublisher()
    }
    
    @Published
    public var exposureNotificationEnabled = false
    
    public var exposureNotificationEnabledPublisher: AnyPublisher<Bool, Never> {
        $exposureNotificationEnabled
            .eraseToAnyPublisher()
    }
    
    public var activationCompletionHandler: ErrorHandler?
    public var setExposureNotificationEnabledCompletionHandler: ErrorHandler?
    public var setExposureNotificationEnabledValue: Bool?
    
    public var diagnosisKeys: [ENTemporaryExposureKey] = [
        ENTemporaryExposureKey(),
        ENTemporaryExposureKey(),
    ]
    
    public var urls = [URL]()
    
    public var summary: ENExposureDetectionSummary = ENExposureDetectionSummary()
    
    public var exposureInfo: [ENExposureInfo] = [
        ENExposureInfo(),
        ENExposureInfo(),
    ]
    
    public var createExposure: (() -> [ENExposureInfo])?
    
    public init() {}
    
    public func activate(completionHandler: @escaping ErrorHandler) {
        activationCompletionHandler = completionHandler
    }
    
    public func setExposureNotificationEnabled(_ enabled: Bool, completionHandler: @escaping ErrorHandler) {
        setExposureNotificationEnabledValue = enabled
        setExposureNotificationEnabledCompletionHandler = completionHandler
    }
    
    public func getDiagnosisKeys(completionHandler: @escaping ENGetDiagnosisKeysHandler) {
        completionHandler(diagnosisKeys, nil)
    }
    
    public func detectExposures(configuration: ENExposureConfiguration, diagnosisKeyURLs: [URL], completionHandler: @escaping ENDetectExposuresHandler) -> Progress {
        urls = diagnosisKeyURLs
        completionHandler(summary, nil)
        return Progress()
    }
    
    public func getExposureInfo(summary: ENExposureDetectionSummary, userExplanation: String, completionHandler: @escaping ENGetExposureInfoHandler) -> Progress {
        self.summary = summary
        
        completionHandler(createExposure?() ?? exposureInfo, nil)
        return Progress()
    }
    
    public func getExposureInfo(summary: ENExposureDetectionSummary, completionHandler: @escaping ENGetExposureInfoHandler) {
        _ = getExposureInfo(summary: summary, userExplanation: UUID().uuidString, completionHandler: completionHandler)
    }
    
    @available(iOS 13.7, *)
    public func getExposureWindows(summary: ENExposureDetectionSummary, completionHandler: @escaping ENGetExposureWindowsHandler) -> Progress {
        return Progress()
    }
}

@available(iOS 13.7, *)
public class MockWindowsExposureNotificationManager: MockExposureNotificationManager {
    var exposureWindows: [ENExposureWindow] = [
        ENExposureWindow(),
    ]
    
    @available(iOS 13.7, *)
    override public func getExposureWindows(summary: ENExposureDetectionSummary, completionHandler: @escaping ENGetExposureWindowsHandler) -> Progress {
        self.summary = summary
        
        completionHandler(exposureWindows, nil)
        return Progress()
    }
}
