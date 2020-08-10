//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public class LogoStrapline: UIView {
    
    private let colorName: ColorName
    
    public enum Style {
        case home
        case onboarding
        
        var label: String {
            switch self {
            case .home:
                return localize(.home_strapline_title)
            case .onboarding:
                return localize(.onboarding_strapline_title)
            }
        }
        
        var accessibilityLabel: String {
            switch self {
            case .home:
                return localize(.home_strapline_accessiblity_label)
            case .onboarding:
                return localize(.onboarding_strapline_accessiblity_label)
            }
        }
    }
    
    public init(_ imageName: ColorName, style: Style) {
        colorName = imageName
        super.init(frame: .zero)
        
        isAccessibilityElement = true
        accessibilityLabel = style.accessibilityLabel
        accessibilityTraits = [.header, .staticText]
        
        backgroundColor = .clear
        
        let image = UIImage(.logoAlt)
        let logoView = UIImageView(image: image)
        logoView.contentMode = .scaleAspectFit
        logoView.tintColor = UIColor(colorName)
        
        let titleLabel = UILabel()
        titleLabel.adjustsFontForContentSizeCategory = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 11.0)
        titleLabel.text = style.label
        titleLabel.textColor = UIColor(colorName)
        titleLabel.setContentHuggingPriority(.almostRequest, for: .vertical)
        
        let height = CGFloat.navBarLogoHeight
        let width = height * image.size.width / image.size.height
        logoView.heightAnchor.constraint(equalToConstant: height).isActive = true
        logoView.widthAnchor.constraint(equalToConstant: width).isActive = true
        
        let stack = UIStackView(arrangedSubviews: [logoView, titleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.showsLargeContentViewer = true
        stack.largeContentImage = UIImage(.logoAlt)
        stack.largeContentTitle = style.label
        stack.addInteraction(UILargeContentViewerInteraction())
        
        addFillingSubview(stack)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
