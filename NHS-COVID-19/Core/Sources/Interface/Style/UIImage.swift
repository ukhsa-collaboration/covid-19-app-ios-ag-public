//
// Copyright © 2020 NHSX. All rights reserved.
//

import SwiftUI
import UIKit

public enum ImageName: String, CaseIterable, Identifiable {
    case onboardingStart = "Onboarding/Protect"
    case onboardingPostcode = "Onboarding/Area"
    case onboardingPermissions = "Onboarding/Permissions"
    case logo = "NHSLogo"
    case logoAlt = "NHSLogoAlt"
    case externalLink = "ExternalLink"
    case noCloud = "NoCloud"
    case padlock = "Padlock"
    case medicalRecord = "MedicalRecord"
    case checkmark = "Check"
    case linkTest = "LinkTest"
    case onboardingPrivacy = "PrivacyScreemBannerImage"
    case tickImage = "TickIcon"
    case menuChevron = "ChevronMenuIcon"
    case warningIcon = "WarningIcon"
    case camera = "Camera"
    case homeCheckin = "QRcodeMenuIcon"
    case homeSymptoms = "ReportMenuIcon"
    case homeAdvice = "DocumentMenuIcon"
    case homeContactTracing = "SignalMenuIcon"
    case homeInfo = "InfoMenuIcon"
    case homeTesting = "TestingMenuIcon"
    case locationIcon = "LocationIcon"
    case error = "Error"
    case coronaVirus = "Coronavirus"
    case calendar = "Calendar"
    case welcomeNotification = "Onboarding/Welcome/WelcomeNotification"
    case welcomeCountdown = "Onboarding/Welcome/WelcomeCountdown"
    case welcomeSymptoms = "Onboarding/Welcome/WelcomeSymptoms"
    case welcomeQRCode = "Onboarding/Welcome/WelcomeQRCode"
    
    public var id: ImageName {
        self
    }
}

extension Image {
    public static var bundle = Bundle.main
    
    public init(_ name: ImageName) {
        self.init(name.rawValue, bundle: Image.bundle)
    }
    
}

extension UIImageView {
    
    public convenience init(_ name: ImageName) {
        self.init(image: UIImage(name))
    }
    
}

extension UIImage {
    public static var bundle = Bundle.main
    
    public convenience init(_ name: ImageName) {
        self.init(named: name.rawValue, in: UIImage.bundle, compatibleWith: .current)!
    }
    
    static func hasImage(for name: ImageName) -> Bool {
        Self(named: name.rawValue, in: UIImage.bundle, compatibleWith: .current) != nil
    }
    
}
