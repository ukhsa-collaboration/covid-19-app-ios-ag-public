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
        
        var moreInfo: () -> Void
        
        public init(postcode: String, riskLevel: InterfaceProperty<RiskLevel?>, moreInfo: @escaping () -> Void) {
            self.postcode = postcode
            _riskLevel = riskLevel
            self.moreInfo = moreInfo
        }
    }
    
    @ObservedObject private var viewModel: ViewModel
    
    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        guard let riskLevel = viewModel.riskLevel else {
            return AnyView(EmptyView())
        }
        return AnyView(realBody(riskLevel: riskLevel))
    }
    
    private func realBody(riskLevel: ViewModel.RiskLevel) -> some View {
        ZStack {
            Color(.surface)
                .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.1), radius: .stripeWidth, y: .stripeWidth)
            HStack(spacing: 0) {
                Color(riskLevel.stripeColor)
                    .frame(width: .bannerStripeWidth)
                HStack {
                    HStack {
                        Image(.locationIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .locationIconPreferredLength)
                            .accessibility(hidden: true)
                        Text(.risk_level_banner_text(postcode: viewModel.postcode, risk: riskLevel.label))
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(Color(.primaryText))
                    }
                    Spacer()
                    Button(action: viewModel.moreInfo) {
                        HStack(spacing: .hairSpacing) {
                            Text(.risk_level_more_info)
                                .font(.headline)
                                .foregroundColor(Color(.nhsBlue))
                                .underline()
                            Image(.externalLink)
                                .resizable()
                                .frame(width: .linkButtonPreferredLength, height: .linkButtonPreferredLength)
                                .foregroundColor(Color(.nhsBlue))
                        }
                        .padding([.top, .bottom], .halfSpacing)
                    }
                    .linkify(.risk_level_more_info)
                    .accessibility(label: Text(.risk_level_more_info_accessibility_label))
                }
                .padding([.leading, .trailing], .halfSpacing)
            }
        }
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
    
}
