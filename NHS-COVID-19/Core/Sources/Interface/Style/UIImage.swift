//
// Copyright © 2021 DHSC. All rights reserved.
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
    case linkTest = "LinkTest"
    case onboardingPrivacy = "PrivacyScreemBannerImage"
    case tickImage = "TickIcon"
    case tick = "Tick"
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
    case thermometer = "Thermometer"
    case qrCode = "QRCode"
    case bluetooth = "Bluetooth"
    case info = "Info"
    case read = "Read"
    case swab = "Swab"
    case settings = "Settings"
    case finance = "Finance"
    case pin = "Pin"
    case checkTick = "CheckTick"
    case chain = "Chain"
    case logoWales = "Logo Wales"
    case qrCodePoster = "QRCodePoster"
    case qrCodePosterHospitality = "QRCodePosterHospitality"
    case qrCodePosterWales = "QRCodePosterWales"
    case isolationStartIndex = "IsolationStartIndex"
    case isolationStartContact = "IsolationStartContact"
    case isolationContinue = "IsolationContinue"
    case isolationEndedWarning = "IsolationEndedWarning"
    case isolationEnded = "IsolationEnded"
    case policy = "Policy"
    
    // MARK: Key sharing
    
    case shareKeys = "ShareKeys"
    
    // MARK: Risk levels
    
    case riskLevelNeutral = "RiskLevel/Neutral"
    case riskLevelGreen = "RiskLevel/Green"
    case riskLevelYellow = "RiskLevel/Yellow"
    case riskLevelAmber = "RiskLevel/Amber"
    case riskLevelRed = "RiskLevel/Red"
    case riskLevelMaroon = "RiskLevel/Maroon"
    case riskLevelBlack = "RiskLevel/Black"
    
    case riskLevelDefaultIcon = "RiskLevel/Icons/DefaultIcon"
    case riskLevelBarsAndPubsIcon = "RiskLevel/Icons/BarsAndPubs"
    case riskLevelEducationIcon = "RiskLevel/Icons/Education"
    case riskLevelExerciseIcon = "RiskLevel/Icons/Exercise"
    case riskLevelMeetingPeopleIcon = "RiskLevel/Icons/MeetingPeople"
    case riskLevelOvernightStaysIcon = "RiskLevel/Icons/OvernightStays"
    case riskLevelTravellingIcon = "RiskLevel/Icons/Travelling"
    case riskLevelWorshipIcon = "RiskLevel/Icons/Worship"
    case riskLevelWeddingsAndFuneralsIcon = "RiskLevel/Icons/WeddingsAndFunerals"
    case riskLevelBusinessesIcon = "RiskLevel/Icons/Businesses"
    case riskLevelRetailIcon = "RiskLevel/Icons/Retail"
    case riskLevelEntertainmentIcon = "RiskLevel/Icons/Entertainment"
    case riskLevelPersonalCareIcon = "RiskLevel/Icons/PersonalCare"
    case riskLevelLargeEventsIcon = "RiskLevel/Icons/LargeEvents"
    case riskLevelClinicallyExtremelyVulnerableIcon = "RiskLevel/Icons/ClinicallyExtremelyVulnerable"
    case riskLevelSocialDistancingIcon = "RiskLevel/Icons/SocialDistancing"
    case riskLevelFaceCoveringsIcon = "RiskLevel/Icons/FaceCoverings"
    case riskLevelMeetingOutdoorsIcon = "RiskLevel/Icons/MeetingOutdoors"
    case riskLevelMeetingIndoorsIcon = "RiskLevel/Icons/MeetingIndoors"
    case riskLevelWorkIcon = "RiskLevel/Icons/Work"
    case riskLevelInternationalTravelIcon = "RiskLevel/Icons/InternationalTravel"
    
    case symbolRef = "Symbols/Ref"
    case symbolinfo = "Symbols/Info"
    case symbolRelease = "Symbols/Release"
    case symbolManufacturer = "Symbols/Manufacturer"
    case symbolUKCA = "Symbols/UKCA"
    case symbolInstructionForUse = "Symbols/InstructionForUse"
    case appUpdateImage = "AppUpdateImage"
    
    case settingInfo = "SettingInfo"
    case privacyIcon = "PrivacyIcon"
    case shareKeysReview = "ShareKeysReview"
    
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
