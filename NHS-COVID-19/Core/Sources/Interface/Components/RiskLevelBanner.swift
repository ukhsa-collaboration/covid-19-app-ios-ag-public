//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Localization
import SwiftUI

public struct RiskLevelBanner: View {
    
    public class ViewModel: ObservableObject {
        public enum RiskLevel: String {
            case low
            case medium
            case high
        }
        
        public var objectWillChange: ObservableObjectPublisher {
            $riskLevel.objectWillChange
        }
        
        @InterfaceProperty
        var riskLevel: RiskLevel?
        
        var postcode: String
        
        public init(postcode: String, riskLevel: InterfaceProperty<RiskLevel?>) {
            self.postcode = postcode
            _riskLevel = riskLevel
        }
    }
    
    @ObservedObject private var viewModel: ViewModel
    private let moreInfo: () -> Void
    
    public init(viewModel: ViewModel, moreInfo: @escaping () -> Void) {
        self.viewModel = viewModel
        self.moreInfo = moreInfo
    }
    
    public var body: some View {
        guard let riskLevel = viewModel.riskLevel else {
            return AnyView(EmptyView())
        }
        return AnyView(realBody(riskLevel: riskLevel))
    }
    
    private func realBody(riskLevel: ViewModel.RiskLevel) -> some View {
        NavigationButton(
            imageName: .pin,
            foregroundColor: riskLevel.color,
            backgroundColor: .clear,
            text: localize(.risk_level_banner_text(postcode: viewModel.postcode, risk: riskLevel.label)),
            action: moreInfo
        )
    }
    
}

private extension RiskLevelBanner.ViewModel.RiskLevel {
    
    var label: String {
        switch self {
        case .low:
            return localize(.risk_level_low)
        case .medium:
            return localize(.risk_level_medium)
        case .high:
            return localize(.risk_level_high)
            
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
