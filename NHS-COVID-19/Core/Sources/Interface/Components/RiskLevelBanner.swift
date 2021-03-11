//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Localization
import SwiftUI

extension RiskLevelBanner {
    public struct ViewModel {
        public enum ColorScheme: String {
            case green, yellow, red, amber, neutral, maroon, black
        }
        
        var postcode: String
        var colorScheme: ColorScheme
        public var riskLevelInfoViewModel: RiskLevelInfoViewController.ViewModel
        
        public init(
            postcode: String,
            colorScheme: ColorScheme,
            title: String,
            infoTitle: String,
            heading: [String],
            body: [String],
            linkTitle: String,
            linkURL: URL?,
            footer: [String],
            policies: [RiskLevelInfoViewController.Policy],
            shouldShowMassTestingLink: InterfaceProperty<Bool>
        ) {
            self.postcode = postcode
            self.colorScheme = colorScheme
            
            let image: UIImage
            switch colorScheme {
            case .neutral:
                image = UIImage(.riskLevelNeutral)
            case .green:
                image = UIImage(.riskLevelGreen)
            case .yellow:
                image = UIImage(.riskLevelYellow)
            case .amber:
                image = UIImage(.riskLevelAmber)
            case .red:
                image = UIImage(.riskLevelRed)
            case .maroon:
                image = UIImage(.riskLevelMaroon)
            case .black:
                image = UIImage(.riskLevelBlack)
            }
            
            riskLevelInfoViewModel = RiskLevelInfoViewController.ViewModel(
                image: image,
                title: title,
                infoTitle: infoTitle,
                heading: heading,
                body: body,
                linkTitle: linkTitle,
                linkURL: linkURL,
                footer: footer,
                policies: policies,
                shouldShowMassTestingLink: shouldShowMassTestingLink
            )
        }
    }
}

public struct RiskLevelBanner: View {
    private var viewModel: ViewModel
    private let tapAction: (RiskLevelInfoViewController.ViewModel) -> Void
    
    public init(viewModel: ViewModel, tapAction: @escaping (RiskLevelInfoViewController.ViewModel) -> Void) {
        self.viewModel = viewModel
        self.tapAction = tapAction
    }
    
    public var body: some View {
        NavigationButton(
            imageName: .pin,
            text: viewModel.riskLevelInfoViewModel.title,
            colorScheme: viewModel.colorScheme.navigationColorScheme,
            action: { self.tapAction(self.viewModel.riskLevelInfoViewModel) }
        )
    }
    
}

private extension RiskLevelBanner.ViewModel.ColorScheme {
    
    var navigationColorScheme: NavigationButton.ColorScheme {
        return NavigationButton.ColorScheme(
            iconColor: Color(fontColor),
            foregroundColor: Color(iconColor),
            backgroundColor: Color(backgroundColor),
            singleColor: true,
            fontColor: Color(fontColor),
            borderColor: Color(borderColor)
        )
    }
    
    var fontColor: ColorName {
        if case .black = self {
            return .lightSurface
        }
        return .primaryText
    }
    
    var iconColor: ColorName {
        switch self {
        case .neutral:
            return .nhsLightBlue
        case .green:
            return .riskLevelIconGreen
        case .yellow:
            return .riskLevelIconYellow
        case .amber:
            return .riskLevelIconAmber
        case .red:
            return .riskLevelIconRed
        case .maroon:
            return .riskLevelIconMaroon
        case .black:
            return .riskLevelIconBlack
        }
    }
    
    var backgroundColor: ColorName {
        switch self {
        case .neutral:
            return .riskLevelBackgroundNeutral
        case .green:
            return .riskLevelBackgroundGreen
        case .yellow:
            return .riskLevelBackgroundYellow
        case .amber:
            return .riskLevelBackgroundAmber
        case .red:
            return .riskLevelBackgroundRed
        case .maroon:
            return .riskLevelBackgroundMaroon
        case .black:
            return .riskLevelBackgroundBlack
        }
    }
    
    var borderColor: ColorName {
        switch self {
        case .neutral:
            return .riskLevelBorderNeutral
        case .black:
            return .riskLevelBorderBlack
        default:
            return iconColor
        }
    }
    
}
