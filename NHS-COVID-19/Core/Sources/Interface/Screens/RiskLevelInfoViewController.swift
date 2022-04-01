//
// Copyright © 2022 DHSC. All rights reserved.
//

import Common
import Foundation
import Localization
import SwiftUI

public protocol RiskLevelInfoInteracting {
    func didTapWebsiteLink(url: URL)
}

extension RiskLevelInfoViewController {
    public struct ViewModel {
        var image: UIImage
        var title: String
        var infoTitle: String
        var heading: [String]
        var body: [String]
        var linkTitle: String
        var linkURL: URL?
        var footer: [String]
        var policies: [Policy]
    }
    
    public struct Policy {
        var icon: ImageName
        var heading: String
        var body: String
        
        public init(
            icon: ImageName,
            heading: String,
            body: String
        ) {
            self.icon = icon
            self.heading = heading
            self.body = body
        }
    }
}

extension RiskLevelInfoViewController.Policy {
    public static func iconFromName(string: String) -> ImageName {
        switch string {
        case "meeting-people": return ImageName.riskLevelMeetingPeopleIcon
        case "bars-and-pubs": return ImageName.riskLevelBarsAndPubsIcon
        case "worship": return ImageName.riskLevelWorshipIcon
        case "overnight-stays": return ImageName.riskLevelOvernightStaysIcon
        case "education": return ImageName.riskLevelEducationIcon
        case "travelling": return ImageName.riskLevelTravellingIcon
        case "exercise": return ImageName.riskLevelExerciseIcon
        case "weddings-and-funerals": return ImageName.riskLevelWeddingsAndFuneralsIcon
        case "businesses": return ImageName.riskLevelBusinessesIcon
        case "retail": return ImageName.riskLevelRetailIcon
        case "entertainment": return ImageName.riskLevelEntertainmentIcon
        case "personal-care": return ImageName.riskLevelPersonalCareIcon
        case "large-events": return ImageName.riskLevelLargeEventsIcon
        case "clinically-extremely-vulnerable": return ImageName.riskLevelClinicallyExtremelyVulnerableIcon
        case "social-distancing": return ImageName.riskLevelSocialDistancingIcon
        case "face-coverings": return ImageName.riskLevelFaceCoveringsIcon
        case "meeting-outdoors": return ImageName.riskLevelMeetingOutdoorsIcon
        case "meeting-indoors": return ImageName.riskLevelMeetingIndoorsIcon
        case "work": return ImageName.riskLevelWorkIcon
        case "international-travel": return ImageName.riskLevelInternationalTravelIcon
        default: return ImageName.riskLevelDefaultIcon
        }
    }
}

extension RiskLevelInfoViewController {
    struct RiskLevelInfoContent {
        typealias Interacting = RiskLevelInfoInteracting
        var views: [StackViewContentProvider]
        
        init(viewModel: ViewModel, interactor: Interacting) {
            
            var stackedViews: [StackViewContentProvider] = [
                UIImageView(image: viewModel.image).styleAsDecoration(),
                BaseLabel().set(text: viewModel.infoTitle).styleAsPageHeader(),
                viewModel.heading.map {
                    BaseLabel().set(text: $0).styleAsTertiaryTitle()
                },
                viewModel.body.map {
                    BaseLabel().set(text: $0).styleAsBody()
                },
                viewModel.policies.map { policy in
                    WelcomePoint(
                        image: policy.icon,
                        header: policy.heading,
                        body: policy.body
                    )
                },
            ]
            
            stackedViews.append(contentsOf:
                viewModel.footer.map {
                    BaseLabel().set(text: $0).styleAsBody()
                }
            )
            
            let contentStack = UIStackView(arrangedSubviews: stackedViews.flatMap { $0.content })
            contentStack.axis = .vertical
            contentStack.spacing = .standardSpacing
            
            let button = PrimaryLinkButton(
                title: viewModel.linkTitle,
                action: {
                    guard let url = viewModel.linkURL else { return }
                    interactor.didTapWebsiteLink(url: url)
                }
            )
            
            let stackView = UIStackView(arrangedSubviews: [contentStack, button])
            stackView.axis = .vertical
            stackView.distribution = .equalSpacing
            stackView.spacing = .standardSpacing
            
            views = [stackView]
        }
    }
}

public class RiskLevelInfoViewController: ScrollingContentViewController {
    public typealias Interacting = RiskLevelInfoInteracting
    
    public init(viewModel: ViewModel, interactor: Interacting) {
        let content = RiskLevelInfoContent(viewModel: viewModel, interactor: interactor)
        super.init(views: content.views)
        
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
