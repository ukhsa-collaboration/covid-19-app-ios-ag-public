//
// Copyright © 2020 NHSX. All rights reserved.
//

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
        default: return ImageName.riskLevelDefaultIcon
        }
    }
}

extension RiskLevelInfoViewController {
    private class Content: PrimaryLinkButtonStickyFooterScrollingContent {
        typealias Interacting = RiskLevelInfoInteracting
        
        init(viewModel: ViewModel, interactor: Interacting) {
            super.init(
                scrollingViews: [
                    UIImageView(image: viewModel.image).styleAsDecoration(),
                    UILabel().set(text: viewModel.infoTitle).styleAsPageHeader(),
                    viewModel.heading.map {
                        UILabel().set(text: $0).styleAsTertiaryTitle()
                    },
                    viewModel.body.map {
                        UILabel().set(text: $0).styleAsBody()
                    },
                    viewModel.policies.map { policy in
                        WelcomePoint(
                            image: policy.icon,
                            header: policy.heading,
                            body: policy.body
                        )
                    },
                    viewModel.footer.map {
                        UILabel().set(text: $0).styleAsBody()
                    },
                ],
                primaryLinkButton: (
                    title: viewModel.linkTitle,
                    action: {
                        guard let url = viewModel.linkURL else { return }
                        interactor.didTapWebsiteLink(url: url)
                    }
                )
            )
        }
    }
}

public class RiskLevelInfoViewController: StickyFooterScrollingContentViewController {
    public typealias Interacting = RiskLevelInfoInteracting
    
    public init(viewModel: ViewModel, interactor: Interacting) {
        super.init(content: Content(viewModel: viewModel, interactor: interactor))
        
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
