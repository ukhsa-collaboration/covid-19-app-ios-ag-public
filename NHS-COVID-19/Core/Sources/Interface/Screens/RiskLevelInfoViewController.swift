//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import Localization
import SwiftUI

public protocol RiskLevelInfoInteracting {
    func didTapWebsiteLink()
}

private class RiskLevelInfoContent: StackContent {
    typealias Interacting = RiskLevelInfoInteracting
    
    var views: [UIView]
    var spacing: CGFloat = .standardSpacing
    var margins: UIEdgeInsets = .largeInset
    
    init(viewModel: RiskLevelBanner.ViewModel, interactor: Interacting) {
        views = [
            UIImageView(viewModel.bannerImageName).styleAsDecoration(),
            UILabel().set(text: viewModel.heading).styleAsTertiaryTitle(),
            UILabel().set(text: viewModel.body).styleAsBody(),
            LinkButton(title: RiskLevelBanner.ViewModel.linkButtonTitle, action: interactor.didTapWebsiteLink),
        ]
    }
}

public class RiskLevelInfoViewController: ScrollingContentViewController {
    public typealias Interacting = RiskLevelInfoInteracting
    
    public init(viewModel: RiskLevelBanner.ViewModel, interactor: Interacting) {
        super.init(content: RiskLevelInfoContent(viewModel: viewModel, interactor: interactor))
        
        navigationItem.title = localize(.risk_level_screen_title)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: localize(.risk_level_screen_close_button), style: .done, target: self, action: #selector(didTapCancel))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func accessibilityPerformEscape() -> Bool {
        dismiss(animated: true)
        return true
    }
    
    @objc func didTapCancel() {
        dismiss(animated: true)
    }
}

private extension RiskLevelBanner.ViewModel {
    static let linkButtonTitle = localize(.risk_level_screen_button)
    
    var heading: String {
        localizeForCountry(.risk_level_banner_text(postcode: postcode, risk: riskHeading))
    }
    
    private var riskHeading: String {
        switch riskLevel {
        case .low: return localizeForCountry(.risk_level_low)
        case .medium: return localizeForCountry(.risk_level_medium)
        case .high: return localizeForCountry(.risk_level_high)
        }
    }
    
    var body: String {
        switch riskLevel {
        case .low: return localizeForCountry(.risk_level_screen_low_body)
        case .medium: return localizeForCountry(.risk_level_screen_medium_body)
        case .high: return localizeForCountry(.risk_level_screen_high_body)
        }
    }
    
    var bannerImageName: ImageName {
        switch riskLevel {
        case .low: return .riskLevelLow
        case .medium: return .riskLevelMedium
        case .high: return .riskLevelHigh
        }
    }
}
