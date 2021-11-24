//
// Copyright © 2021 DHSC. All rights reserved.
//

import SwiftUI
import UIKit

public enum ColorName: String, CaseIterable, Identifiable {
    case background = "Background"
    case nhsBlue = "NHS Blue"
    case nhsLightBlue = "NHS Light Blue"
    case nhsButtonGreen = "NHS Button Green"
    case activeScanIndicator = "NHS Active Scan Indicator"
    case secondaryText = "Secondary Text"
    case primaryText = "Primary Text"
    case tertiaryText = "Tertiary Text"
    case surface = "Surface"
    case errorRed = "Error Red"
    case amber = "Amber"
    case primaryButtonLabel = "Primary Button Label"
    
    case lightSurface = "Light Surface"
    case sectionHeaderText = "Section Header Text"
    case navigationBar = "Navigation Bar"
    
    case styleTurquoise = "Style/Turquoise"
    case styleGreen = "Style/Green"
    case styleOrange = "Style/Orange"
    case stylePink = "Style/Pink"
    case stylePurple = "Style/Purple"
    case styleRed = "Style/Red"
    case styleBlue = "Style/Blue"
    case styleYellow = "Style/Yellow"
    
    case riskLevelBackgroundNeutral = "RiskLevel/Background/Neutral"
    case riskLevelBackgroundGreen = "RiskLevel/Background/Green"
    case riskLevelBackgroundYellow = "RiskLevel/Background/Yellow"
    case riskLevelBackgroundAmber = "RiskLevel/Background/Amber"
    case riskLevelBackgroundRed = "RiskLevel/Background/Red"
    case riskLevelBackgroundMaroon = "RiskLevel/Background/Maroon"
    case riskLevelBackgroundBlack = "RiskLevel/Background/Black"
    case riskLevelIconGreen = "RiskLevel/Icon/Green"
    case riskLevelIconYellow = "RiskLevel/Icon/Yellow"
    case riskLevelIconAmber = "RiskLevel/Icon/Amber"
    case riskLevelIconRed = "RiskLevel/Icon/Red"
    case riskLevelIconMaroon = "RiskLevel/Icon/Maroon"
    case riskLevelIconBlack = "RiskLevel/Icon/Black"
    case riskLevelBorderNeutral = "RiskLevel/Border/Neutral"
    case riskLevelBorderBlack = "RiskLevel/Border/Black"
    
    case borderColor = "Border color"
    case bookFreeTest = "Book Free Test"
    case contactTracingHubButton = "Contact Tracing Hub Button"
    
    case accessibleButtonOutline = "Accessible Button Outline"
    
    public var id: ColorName {
        self
    }
}

extension Color {
    public static var bundle: Bundle = Bundle.main
    
    public init(_ name: ColorName) {
        self.init(name.rawValue, bundle: Color.bundle)
    }
    
}

extension UIColor {
    public static var bundle: Bundle = Bundle.main
    
    public convenience init(_ name: ColorName) {
        self.init(named: name.rawValue, in: UIColor.bundle, compatibleWith: .current)!
    }
    
    static func hasColor(for name: ColorName) -> Bool {
        Self(named: name.rawValue, in: UIColor.bundle, compatibleWith: .current) != nil
    }
}
