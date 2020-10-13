//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Localization
import SwiftUI

extension RiskLevelBanner {
    public struct ViewModel {
        public enum ColorScheme {
            case green, yellow, red, amber, neutral
        }
        
        var postcode: String
        var colorScheme: ColorScheme
        public var riskLevelInfoViewModel: RiskLevelInfoViewController.ViewModel
        
        public init(
            postcode: String,
            colorScheme: ColorScheme,
            title: String,
            heading: [String],
            body: [String],
            linkTitle: String,
            linkURL: URL?
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
            }
            
            riskLevelInfoViewModel = RiskLevelInfoViewController.ViewModel(
                image: image,
                title: title,
                heading: heading,
                body: body,
                linkTitle: linkTitle,
                linkURL: linkURL
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
            contentColorScheme: contentColorScheme
        )
    }
    
    var fontColor: ColorName {
        switch self {
        case .neutral:
            return .primaryText
        case .green:
            return .primaryText
        case .yellow:
            return .primaryText
        case .amber:
            return .primaryText
        case .red:
            return .surface
        }
    }
    
    var iconColor: ColorName {
        switch self {
        case .neutral:
            return .secondaryText
        case .green:
            return .primaryText
        case .yellow:
            return .primaryText
        case .amber:
            return .primaryText
        case .red:
            return .surface
        }
    }
    
    var backgroundColor: ColorName {
        switch self {
        case .neutral:
            return .surface
        case .green:
            return .riskLevelGreen
        case .yellow:
            return .riskLevelYellow
        case .amber:
            return .riskLevelAmber
        case .red:
            return .riskLevelRed
        }
    }
    
    var contentColorScheme: NavigationButton.ContentColorScheme {
        switch self {
        case .neutral:
            return .matchEnvironment
        case .green, .yellow, .amber:
            return .override(.light)
        case .red:
            return .matchEnvironment
        }
    }
    
}
