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
    }
    
    public class InitialState {
        var modifiedLaunchArguments = [String: String]()
        
        @TestInjected("sandbox.isPilotActivated", defaultValue: false)
        public var isPilotActivated: Bool
        
        @TestInjected("sandbox.exposureNotificationsAuthorized", defaultValue: false)
        public var exposureNotificationsAuthorized: Bool
        
        @TestInjected("sandbox.userNotificationsAuthorized", defaultValue: false)
        public var userNotificationsAuthorized: Bool
        
        // Defaults to nil, but setting to nil causes fatal error
        @TestInjected("sandbox.postcode")
        public var postcode: String?
        
        @TestInjected("sandbox.riskLevel")
        public var riskLevel: String?
        
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
