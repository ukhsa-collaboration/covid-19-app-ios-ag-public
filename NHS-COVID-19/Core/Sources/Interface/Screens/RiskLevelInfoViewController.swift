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
        var heading: [String]
        var body: [String]
        var linkTitle: String
        var linkURL: URL?
    }
}

extension RiskLevelInfoViewController {
    private class Content: BasicStickyFooterScrollingContent {
        typealias Interacting = RiskLevelInfoInteracting
        
        init(viewModel: ViewModel, interactor: Interacting) {
            super.init(
                scrollingViews: [
                    UIImageView(image: viewModel.image).styleAsDecoration(),
                    UILabel().set(text: viewModel.title).styleAsPageHeader(),
                    viewModel.heading.map {
                        UILabel().set(text: $0).styleAsTertiaryTitle()
                    },
                    viewModel.body.map {
                        UILabel().set(text: $0).styleAsBody()
                    },
                ],
                footerTopView: PrimaryLinkButton(title: viewModel.linkTitle) {
                    guard let url = viewModel.linkURL else { return }
                    interactor.didTapWebsiteLink(url: url)
                }
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
