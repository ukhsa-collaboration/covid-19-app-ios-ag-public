//
// Copyright © 2021 DHSC. All rights reserved.
//

import Domain
import Foundation
import Interface
import Localization

extension RiskLevelBanner.ViewModel {
    private static let postcodePlaceholder = "[postcode]"
    private static let localAuthorityPlaceholder = "[local authority]"
    
    public init(
        postcode: Postcode,
        localAuthority: Domain.LocalAuthority?,
        risk: RiskyPostcodeEndpointManager.PostcodeRisk
    ) {
        let colorScheme: ColorScheme
        
        if let colorName = risk.style.colorSchemeV2 {
            colorScheme = ColorScheme(rawValue: colorName) ?? .neutral
        } else {
            #warning("Remove fallback to old field after the backend is deployed")
            switch risk.style.colorScheme {
            case .green: colorScheme = .green
            case .amber: colorScheme = .amber
            case .yellow: colorScheme = .yellow
            case .red: colorScheme = .red
            case .neutral: colorScheme = .neutral
            }
        }
        
        if let policyData = risk.style.policyData {
            let localAuthorityTitle: String = {
                if let localAuthority = localAuthority,
                    risk.type == .localAuthority {
                    return policyData.localAuthorityRiskTitle.localizedString()
                        .replacingOccurrences(of: Self.postcodePlaceholder, with: postcode.value)
                        .replacingOccurrences(of: Self.localAuthorityPlaceholder, with: localAuthority.name)
                } else {
                    return risk.style.name.localizedString()
                        .replacingOccurrences(of: Self.postcodePlaceholder, with: postcode.value)
                }
            }()
            
            self.init(
                postcode: postcode.value,
                colorScheme: colorScheme,
                title: risk.style.name.localizedString().replacingOccurrences(of: Self.postcodePlaceholder, with: postcode.value),
                infoTitle: localAuthorityTitle,
                heading: policyData.heading.localizedString().split(separator: "\n").map(String.init).filter { !$0.isEmpty },
                body: policyData.content.localizedString().split(separator: "\n").map(String.init).filter { !$0.isEmpty },
                linkTitle: risk.style.linkTitle.localizedString(),
                linkURL: URL(string: risk.style.linkUrl.localizedString(contentType: .url)),
                footer: policyData.footer.localizedString().split(separator: "\n").map(String.init).filter { !$0.isEmpty },
                policies: policyData.policies.map { policy in
                    RiskLevelInfoViewController.Policy(
                        icon: RiskLevelInfoViewController.Policy.iconFromName(string: policy.policyIcon),
                        heading: policy.policyHeading.localizedString(),
                        body: policy.policyContent.localizedString()
                    )
                }
            )
        } else {
            let title = risk.style.name.localizedString().replacingOccurrences(of: Self.postcodePlaceholder, with: postcode.value)
            
            self.init(
                postcode: postcode.value,
                colorScheme: colorScheme,
                title: title,
                infoTitle: title,
                heading: risk.style.heading.localizedString().split(separator: "\n").map(String.init).filter { !$0.isEmpty },
                body: risk.style.content.localizedString().split(separator: "\n").map(String.init).filter { !$0.isEmpty },
                linkTitle: risk.style.linkTitle.localizedString(),
                linkURL: URL(string: risk.style.linkUrl.localizedString(contentType: .url)),
                footer: [],
                policies: []
            )
        }
    }
}
