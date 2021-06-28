//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import SwiftUI

public struct LocalInformationBanner: View {
    
    public struct ViewModel {
        let text: String
        let localInfoScreenViewModel: LocalInformationViewController.ViewModel
        
        public init(text: String, localInfoScreenViewModel: LocalInformationViewController.ViewModel) {
            self.text = text.applyCurrentLanguageDirection()
            self.localInfoScreenViewModel = localInfoScreenViewModel
        }
    }
    
    private let viewModel: ViewModel
    private let tapAction: (LocalInformationViewController.ViewModel) -> Void
    
    public init(viewModel: ViewModel, tapAction: @escaping (LocalInformationViewController.ViewModel) -> Void) {
        self.viewModel = viewModel
        self.tapAction = tapAction
    }
    
    public var body: some View {
        Button(action: { tapAction(viewModel.localInfoScreenViewModel) }) {
            HStack(alignment: .top, spacing: .stripeSpacing) {
                Image(.alert)
                VStack(alignment: .leading, spacing: .hairSpacing) {
                    Text(viewModel.text)
                        .styleAsBody()
                        .fixedSize(horizontal: false, vertical: true)
                    HStack {
                        Text(localize(.local_information_banner_read_more))
                        Image(.menuChevron)
                    }
                    .foregroundColor(Color(.nhsBlue))
                }
            }
            .padding(
                EdgeInsets(
                    top: .stripeSpacing,
                    leading: .standardSpacing,
                    bottom: .stripeSpacing,
                    trailing: .standardSpacing
                )
            )
            .contentShape(Rectangle()) // fixes tap outside of padding
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundColor(Color(.primaryText))
        .background(Color(.amber))
        .environment(\.colorScheme, .light) // always use light mode
        .environment(\.locale, Locale(identifier: currentLocaleIdentifier()))
    }
    
}
