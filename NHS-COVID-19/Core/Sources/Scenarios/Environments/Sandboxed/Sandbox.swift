//
// Copyright © 2021 DHSC. All rights reserved.
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
            case indexAndContact
            case indexWithPositiveTest
        }

        public enum IsolationPaymentState: String {
            case enabled
            case disabled
        }

        public enum RiskyVenueMessageType: String {
            case warnAndInform
            case warnAndBookATest
        }

        public static let validQRCode = "UKC19TRACING:1:eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjMifQ.eyJpZCI6IjRXVDU5TTVZIiwib3BuIjoiR292ZXJubWVudCBPZmZpY2UgT2YgSHVtYW4gUmVzb3VyY2VzIn0.ZIvwm9rxiRTm4o-koafL6Bzre9pakcyae8m6_MSyvAl-CFkUgfm6gcXYn4gg5OScKZ1-XayHBGwEdps0RKXs4g"
    }

    public struct InitialState: Codable, Equatable {

        public var exposureNotificationsAuthorized: Bool = false

        public var exposureNotificationsEnabled: Bool = true

        public var userNotificationsAuthorized: Bool?

        public var cameraAuthorized: Bool = false

        public var postcode: String?

        public var lastAcceptedWithAppVersion: String = "4.16"

        public var scannedQRCode: String = Text.validQRCode

        public var shouldScanQRCode: Bool = true

        public var qrCodeScanTime: Double = 2.0

        public var cameraUnavailable: Bool = false

        public var isolationCase: String = Text.IsolationCase.none.rawValue

        public var testResult: String?

        public var requiresConfirmatoryTest: Bool = false

        public var supportsKeySubmission: Bool = true

        public var testKitType: String = "LAB_RESULT"

        private(set) var testResultEndDateString: String?

        public var localAuthorityId: String?

        public var isolationPaymentState: String = Text.IsolationPaymentState.disabled.rawValue

        public var riskyVenueMessageType: String?

        public var hasAcknowledgedStartOfIsolation: Bool = true

        public var hasCheckIns: Bool = false

        public var bluetootOff: Bool = false

        public var isSymptomaticSelfIsolationForWalesEnabled: Bool = false

        public init() {}

        public mutating func set(testResultEndDate: Date) throws {
            let data = try JSONEncoder().encode(testResultEndDate)
            testResultEndDateString = String(data: data, encoding: .utf8)!
        }

    }

    public enum Config {
        public enum Isolation {
            public static let indexCaseSinceSelfDiagnosisUnknownOnset = 8
            public static let indexCaseSinceTestResultEndDate = 5
            public static let indexCaseSinceSelfDiagnosisOnset = 1
            public static let contactCaseSinceExposureDay = 12
            public static let daysSinceReceivingExposureNotification = 2
        }
    }
}
