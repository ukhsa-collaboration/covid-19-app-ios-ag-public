//
// Copyright © 2020 NHSX. All rights reserved.
//

import SwiftUI
import UIKit

public enum ColorName: String, CaseIterable, Identifiable {
    case background = "Background"
    case nhsBlue = "NHS Blue"
    case nhsButtonGreen = "NHS Button Green"
    case activeScanIndicator = "NHS Active Scan Indicator"
    case secondaryText = "Secondary Text"
    case primaryText = "Primary Text"
    case surface = "Surface"
    case errorRed = "Error Red"
    case amber = "Amber"
    case primaryButtonLabel = "Primary Button Label"
    
    case lightSurface = "Light Surface"
    case sectionHeaderText = "Section Header Text"
    case warningIcon = "Warning Icon"
    case navigationBar = "Navigation Bar"
    
    case styleTurquoise = "Style/Turquoise"
    case styleGreen = "Style/Green"
    case styleOrange = "Style/Orange"
    case stylePink = "Style/Pink"
    case stylePurple = "Style/Purple"
    case styleRed = "Style/Red"
    case styleBlue = "Style/Blue"
    
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
