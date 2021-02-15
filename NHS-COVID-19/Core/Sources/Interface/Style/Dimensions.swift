//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

extension CGFloat {
    
    public static let standardSpacing: CGFloat = 16
    public static let bigSpacing: CGFloat = 20
    public static let doubleSpacing: CGFloat = 32
    public static let tripleSpacing: CGFloat = 48
    public static let halfSpacing: CGFloat = 8
    public static let hairSpacing: CGFloat = 4
    
    public static let buttonCornerRadius: CGFloat = 8
    public static let menuButtonCornerRadius: CGFloat = 15
    public static let menuButtonColorWidth: CGFloat = 60
    public static let buttonMinimumHeight: CGFloat = 54
    public static let stripeWidth: CGFloat = 4
    public static let stripeSpacing: CGFloat = 12
    public static let straplineHeight: CGFloat = 22
    public static let linkIconSpacing: CGFloat = 10
    public static let hitAreaMinHeight: CGFloat = 45
    public static let bulletPointSize: CGFloat = 30
    public static let confirmationIconImageSize: CGFloat = 80
    public static let closeButtonSize: CGFloat = 30
    public static let navBarLogoHeight: CGFloat = 18
    public static let navBarLogoHeightWithoutLabel: CGFloat = 35
    
    public static let navBarLogoWidth: CGFloat = 45.2
    public static let navBarLogoWidthWithoutLabel: CGFloat = 147
    
    public static let linkButtonPreferredLength: CGFloat = 24
    public static let bannerStripeWidth: CGFloat = 6
    public static let locationIconPreferredLength: CGFloat = 14
    public static let symbolIconWidth: CGFloat = 22
    
    public static let appActivityIndicatorMinHeight: CGFloat = 240
    public static let indicatorPulseMaxSize: CGFloat = 500
}

extension UIEdgeInsets {
    
    static let standard = UIEdgeInsets(
        top: .standardSpacing,
        left: .standardSpacing,
        bottom: .standardSpacing,
        right: .standardSpacing
    )
    
    static let inner = UIEdgeInsets(
        top: 0,
        left: .standardSpacing,
        bottom: 0,
        right: .standardSpacing
    )
    
    static let largeInset = UIEdgeInsets(
        top: .doubleSpacing,
        left: .doubleSpacing,
        bottom: .doubleSpacing,
        right: .doubleSpacing
    )
    
    static let infoboxStack = UIEdgeInsets(
        top: .stripeWidth,
        left: .zero,
        bottom: .stripeWidth,
        right: .standardSpacing
    )
    
    static let none = UIEdgeInsets(
        top: .zero,
        left: .zero,
        bottom: .zero,
        right: .zero
    )
}
