//
// Copyright © 2022 DHSC. All rights reserved.
//

import Domain
import Foundation
import Interface
import Localization

extension RiskLevelBanner.ViewModel {

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

        var externalUrls: RiskLevelInfoViewController.ExternalUrls? {
            if let externalUrls = risk.style.externalUrls {
                return RiskLevelInfoViewController.ExternalUrls(
                    title: externalUrls.title?.localizedString(),
                    urls: externalUrls.urls.map {
                        if let url = $0.url {
                            return RiskLevelInfoViewController.ExternalLink(
                                title: $0.title.localizedString(),
                                url: URL(string: url.localizedString(contentType: .url))
                            )
                        } else {
                            return RiskLevelInfoViewController.ExternalLink(
                                title: $0.title.localizedString(),
                                url: nil
                            )
                        }
                    }
                )
            } else {
                return nil
            }
        }

        if let policyData = risk.style.policyData {
            let localAuthorityTitle: String = {
                if let localAuthority = localAuthority,
                    risk.type == .localAuthority {
                    return policyData.localAuthorityRiskTitle.localizedString()
                        .stringByReplacing(postcode: postcode.value, localAuthority: localAuthority.name)
                } else {
                    return risk.style.name.localizedString()
                        .stringByReplacing(postcode: postcode.value)
                }
            }()

            self.init(
                postcode: postcode.value,
                colorScheme: colorScheme,
                title: risk.style.name.localizedString().stringByReplacing(postcode: postcode.value),
                infoTitle: localAuthorityTitle,
                heading: policyData.heading.localizedString().split(separator: "\n").map(String.init).filter { !$0.isEmpty },
                body: policyData.content.localizedString().split(separator: "\n").map(String.init).filter { !$0.isEmpty },
                linkTitle: risk.style.linkTitle.localizedString(),
                linkURL: URL(string: risk.style.linkUrl.localizedString(contentType: .url)),
                footer: policyData.footer.localizedString().split(separator: "\n").map(String.init).filter { !$0.isEmpty },
                externalUrls: externalUrls,
                policies: policyData.policies.map { policy in
                    RiskLevelInfoViewController.Policy(
                        icon: RiskLevelInfoViewController.Policy.iconFromName(string: policy.policyIcon),
                        heading: policy.policyHeading.localizedString(),
                        body: policy.policyContent.localizedString()
                    )
                }
            )
        } else {
            let title = risk.style.name.localizedString().stringByReplacing(postcode: postcode.value)

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
                externalUrls: externalUrls,
                policies: []
            )
        }
    }
}
