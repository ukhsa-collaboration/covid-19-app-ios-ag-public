//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import UIKit

public class LogoStrapline: UIView {

    private let colorName: ColorName
    private var stack: UIStackView?

    public enum Style {
        case home(Country)
        case onboarding

        var label: String? {
            switch self {
            case .home(let country):
                switch country {
                case .england:
                    return localize(.home_strapline_title)
                case .wales:
                    return nil
                }
            case .onboarding:
                return localize(.onboarding_strapline_title)
            }
        }

        var accessibilityLabel: String {
            switch self {
            case .home:
                return localizeForCountry(.home_strapline_accessiblity_label)
            case .onboarding:
                return localize(.onboarding_strapline_accessiblity_label)
            }
        }

        var image: ImageName {
            switch self {
            case .home(let country):
                switch country {
                case .england:
                    return .logoAlt
                case .wales:
                    return .logoWales
                }
            case .onboarding:
                return .logoAlt
            }
        }

        var imageHeight: CGFloat {
            switch self {
            case .home(let country):
                switch country {
                case .england:
                    return CGFloat.navBarLogoHeight
                case .wales:
                    return CGFloat.navBarLogoHeightWithoutLabel
                }
            case .onboarding:
                return CGFloat.navBarLogoHeight
            }
        }
    }

    public init(_ colorName: ColorName, style: Style) {
        self.colorName = colorName
        super.init(frame: .zero)

        isAccessibilityElement = false
        accessibilityElementsHidden = true
        accessibilityLabel = style.accessibilityLabel
        accessibilityTraits = [.header, .staticText]

        backgroundColor = .clear

        update(style: style)
    }

    func update(style: Style) {
        stack?.removeFromSuperview()
        var logoStack: [UIView] = []

        let image = UIImage(style.image)
        let logoView = UIImageView(image: image)
        logoView.contentMode = .scaleAspectFit
        logoView.tintColor = UIColor(.nhsBlue)
        logoStack.append(logoView)

        if let label = style.label {
            let titleLabel = BaseLabel()
            titleLabel.adjustsFontForContentSizeCategory = false
            titleLabel.font = UIFont.boldSystemFont(ofSize: 11.0)
            titleLabel.text = label
            titleLabel.textColor = UIColor(colorName)
            titleLabel.setContentHuggingPriority(.almostRequest, for: .vertical)
            logoStack.append(titleLabel)
        }

        let height = style.imageHeight
        let width = height * image.size.width / image.size.height
        logoView.heightAnchor.constraint(equalToConstant: height).isActive = true
        logoView.widthAnchor.constraint(equalToConstant: width).isActive = true

        let stack = UIStackView(arrangedSubviews: logoStack)
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.showsLargeContentViewer = true
        stack.largeContentImage = UIImage(.logoAlt)
        stack.largeContentTitle = style.label
        stack.addInteraction(UILargeContentViewerInteraction())

        self.stack = stack

        addFillingSubview(stack)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
