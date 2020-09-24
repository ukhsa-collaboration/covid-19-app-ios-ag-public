//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Localization
import SwiftUI

public struct RiskLevelBanner: View {
    
    public struct ViewModel {
        public enum RiskLevel: String {
            case low
            case medium
            case high
        }
        
        var postcode: String
        var riskLevel: RiskLevel
        
        public init(postcode: String, riskLevel: RiskLevel) {
            self.postcode = postcode
            self.riskLevel = riskLevel
        }
    }
    
    private var viewModel: ViewModel
    private let tapAction: (ViewModel) -> Void
    
    public init(viewModel: ViewModel, tapAction: @escaping (ViewModel) -> Void) {
        self.viewModel = viewModel
        self.tapAction = tapAction
    }
    
    public var body: some View {
        NavigationButton(
            imageName: .pin,
            foregroundColor: viewModel.riskLevel.color,
            backgroundColor: .clear,
            text: localizeForCountry(.risk_level_banner_text(postcode: viewModel.postcode, risk: viewModel.riskLevel.label)),
            action: { self.tapAction(self.viewModel) }
        )
    }
    
}

private extension RiskLevelBanner.ViewModel.RiskLevel {
    
    var label: String {
        switch self {
        case .low:
            return localizeForCountry(.risk_level_low)
        case .medium:
            return localizeForCountry(.risk_level_medium)
        case .high:
            return localizeForCountry(.risk_level_high)
            
        }
    }
    
    var stripeColor: ColorName {
        switch self {
        case .low:
            return .nhsButtonGreen
        case .medium:
            return .amber
        case .high:
            return .errorRed
        }
    }
    
    var color: Color {
        switch self {
        case .low:
            return Color(.styleGreen)
        case .medium:
            return Color(.styleOrange)
        case .high:
            return Color(.styleRed)
        }
    }
}
