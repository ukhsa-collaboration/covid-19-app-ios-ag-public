//
// Copyright © 2020 NHSX. All rights reserved.
//

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
    }
    
    public class InitialState {
        var modifiedLaunchArguments = [String: String]()
        
        @TestInjected("sandbox.isPilotActivated", defaultValue: false)
        public var isPilotActivated: Bool
        
        public init() {}
        
        public var launchArguments: [String] {
            modifiedLaunchArguments.flatMap { key, value in
                ["-\(key)", value]
            }
        }
    }
}
