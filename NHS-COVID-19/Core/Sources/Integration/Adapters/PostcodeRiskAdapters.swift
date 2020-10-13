//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Foundation
import Interface
import Localization

extension RiskLevelBanner.ViewModel {
    private static let postcodePlaceholder = "[postcode]"
    
    public init(postcode: Postcode, risk: RiskyPostcodeEndpointManager.PostcodeRisk) {
        switch risk {
        case .v1(let v1):
            let colorScheme: ColorScheme
            let name: String
            let body: [String]
            
            switch v1 {
            case .low:
                colorScheme = .green
                name = localize(.risk_level_banner_text(postcode: postcode.value, risk: localizeForCountry(.risk_level_low)))
                body = localizeForCountryAndSplit(.risk_level_screen_low_body)
            case .medium:
                colorScheme = .yellow
                name = localize(.risk_level_banner_text(postcode: postcode.value, risk: localizeForCountry(.risk_level_medium)))
                body = localizeForCountryAndSplit(.risk_level_screen_medium_body)
            case .high:
                colorScheme = .red
                name = localize(.risk_level_banner_text(postcode: postcode.value, risk: localizeForCountry(.risk_level_high)))
                body = localizeForCountryAndSplit(.risk_level_screen_high_body)
            }
            
            self.init(
                postcode: postcode.value,
                colorScheme: colorScheme,
                title: name,
                heading: [],
                body: body,
                linkTitle: localize(.risk_level_screen_button),
                linkURL: ExternalLink.moreInfoOnPostcodeRisk.url
            )
        case .v2(_, let style):
            let colorScheme: ColorScheme
            
            switch style.colorScheme {
            case .green:
                colorScheme = .green
            case .amber:
                colorScheme = .amber
            case .yellow:
                colorScheme = .yellow
            case .red:
                colorScheme = .red
            case .neutral:
                colorScheme = .neutral
            }
            
            self.init(
                postcode: postcode.value,
                colorScheme: colorScheme,
                title: style.name.localizedString.replacingOccurrences(of: Self.postcodePlaceholder, with: postcode.value),
                heading: style.heading.localizedString.split(separator: "\n").map(String.init).filter { !$0.isEmpty },
                body: style.content.localizedString.split(separator: "\n").map(String.init).filter { !$0.isEmpty },
                linkTitle: style.linkTitle.localizedString,
                linkURL: URL(string: style.linkUrl.localizedString)
            )
        }
    }
}
