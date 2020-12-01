//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

public enum Sandbox {
    public enum Text {
        public enum ExposureNotification: String {
            case authorizationAlertTitle = "Enable COVID-19 Exposure Logging and Notifications"
            case authorizationAlertMessage = "[FAKE] This alert only simulates the system alert."
            case authorizationAlertAllow = "Allow"
            case authorizationAlertDoNotAllow = "Don’t Allow"
            case diagnosisKeyAlertTitle = "Share Your Device s Random IDs with ...?"
            case diagnosisKeyAlertMessage = "[FAKE] This alert only simulates the system alert"
            case diagnosisKeyAlertShare = "Share"
            case diagnosisKeyAlertDoNotShare = "Don’t share"
        }
        
        public enum UserNotification: String {
            case authorizationAlertTitle = "“NHS-COVID-19” Would Like to Send You Notifications"
            case authorizationAlertMessage = "[FAKE] This alert only simulates the system alert."
            case authorizationAlertAllow = "Allow"
            case authorizationAlertDoNotAllow = "Don’t Allow"
        }
        
        public enum SymptomsList: String {
            case cardHeading = "Heading"
            case cardContent = "Content"
        }
        
        public enum CameraManager: String {
            case authorizationAlertTitle = "“NHS-COVID-19” Would Like to Access your Camera"
            case authorizationAlertMessage = "[FAKE] This alert only simulates the system alert."
            case authorizationAlertAllow = "Allow"
            case authorizationAlertDoNotAllow = "Don’t Allow"
        }
        
        public enum IsolationCase: String {
            case none
            case index
            case contact
        }
        
        public static let validQRCode = "UKC19TRACING:1:eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjMifQ.eyJpZCI6IjRXVDU5TTVZIiwib3BuIjoiR292ZXJubWVudCBPZmZpY2UgT2YgSHVtYW4gUmVzb3VyY2VzIn0.ZIvwm9rxiRTm4o-koafL6Bzre9pakcyae8m6_MSyvAl-CFkUgfm6gcXYn4gg5OScKZ1-XayHBGwEdps0RKXs4g"
    }
    
    public class InitialState {
        var modifiedLaunchArguments = [String: String]()
        
        @TestInjected("sandbox.isPilotActivated", defaultValue: false)
        public var isPilotActivated: Bool
        
        @TestInjected("sandbox.exposureNotificationsAuthorized", defaultValue: false)
        public var exposureNotificationsAuthorized: Bool
        
        @TestInjected("sandbox.userNotificationsAuthorized", defaultValue: nil)
        public var userNotificationsAuthorized: Bool?
        
        @TestInjected("sandbox.cameraAuthorized", defaultValue: false)
        public var cameraAuthorized: Bool
        
        // Defaults to nil, but setting to nil causes fatal error
        @TestInjected("sandbox.postcode")
        public var postcode: String?
        
        @TestInjected("sandbox.lastAcceptedWithAppVersion", defaultValue: "3.10")
        public var lastAcceptedWithAppVersion: String
        
        @TestInjected("sandbox.scannedQRCode", defaultValue: Text.validQRCode)
        public var scannedQRCode: String
        
        @TestInjected("sandbox.shouldScanQRCode", defaultValue: true)
        public var shouldScanQRCode: Bool
        
        @TestInjected("sandbox.qrCodeScanTime", defaultValue: 2.0)
        public var qrCodeScanTime: Double
        
        @TestInjected("sandbox.cameraUnavailable", defaultValue: false)
        public var cameraUnavailable: Bool
        
        @TestInjected("sandbox.isolationCase", defaultValue: Text.IsolationCase.none.rawValue)
        public var isolationCase: String
        
        @TestInjected("sandbox.testResult")
        public var testResult: String?
        
        @TestInjected("sandbox.testResultEndDate")
        private(set) var testResultEndDateString: String?
        
        @TestInjected("scenario.toggle.localAuthority", defaultValue: FeatureToggleStorage.getEnabledFeatures().contains(.localAuthority))
        public var localAuthorityEnabled: Bool
        
        @TestInjected("sandbox.localAuthorityId")
        public var localAuthorityId: String?
        
        public func set(testResultEndDate: Date) throws {
            let data = try JSONEncoder().encode(testResultEndDate)
            testResultEndDateString = String(data: data, encoding: .utf8)!
        }
        
        public init() {}
        
        public var launchArguments: [String] {
            modifiedLaunchArguments.flatMap { key, value in
                ["-\(key)", value]
            }
        }
    }
    
    public enum Config {
        public enum Isolation {
            public static let indexCaseSinceSelfDiagnosisUnknownOnset = 8
        }
    }
}
