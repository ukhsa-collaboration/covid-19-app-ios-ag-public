//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import SwiftUI
import UIKit

public struct Strapline: View {
    @ObservedObject
    var country: InterfaceProperty<Country>
    
    public init(country: InterfaceProperty<Country>) {
        self.country = country
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Image(country.wrappedValue.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Color(.nhsBlue))
                .frame(width: country.wrappedValue.imageSize.width, height: country.wrappedValue.imageSize.height)
            title()
        }
        .overlay(LargeContentViewer(country: country.wrappedValue))
        .accessibilityElement()
        .accessibility(label: Text(country.wrappedValue.accessiblityText))
        .accessibility(addTraits: .isHeader)
        .environment(\.locale, Locale(identifier: currentLanguageCode()))
    }
    
    func title() -> AnyView {
        guard let text = country.wrappedValue.text else {
            return AnyView(EmptyView())
        }
        return AnyView(Text(text).font(.system(size: 11)))
    }
}

extension Strapline {
    struct LargeContentViewer: UIViewRepresentable {
        var country: Country
        
        func makeUIView(context: Context) -> UIView {
            let view = UIView()
            view.showsLargeContentViewer = true
            view.addInteraction(UILargeContentViewerInteraction())
            return view
        }
        
        func updateUIView(_ uiView: UIView, context: Context) {
            uiView.largeContentImage = UIImage(country.imageName)
            uiView.largeContentTitle = country.text.map(localize)
        }
    }
}

private extension Country {
    var imageName: ImageName {
        switch self {
        case .england:
            return .logoAlt
        case .wales:
            return .logoWales
        }
    }
    
    var imageSize: CGSize {
        switch self {
        case .england:
            return CGSize(width: .navBarLogoWidth, height: .navBarLogoHeight)
        case .wales:
            return CGSize(width: .navBarLogoWidthWithoutLabel, height: .navBarLogoHeightWithoutLabel)
        }
    }
    
    var text: StringLocalizationKey? {
        switch self {
        case .england:
            return .home_strapline_title
        case .wales:
            return nil
        }
    }
    
    var accessiblityText: StringLocalizationKey {
        switch self {
        case .england:
            return .home_strapline_accessiblity_label
        case .wales:
            return .home_strapline_accessiblity_label_wls
        }
    }
}
