//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import UIKit

// MARK: - View Model

public protocol LocalInformationScreenBodyElement {} // marker interface

extension LocalInformationViewController {
    public struct ViewModel {
        let header: String
        let body: [LocalInformationScreenBodyElement]
        
        public init(header: String, body: [LocalInformationScreenBodyElement]) {
            self.header = header.applyCurrentLanguageDirection()
            self.body = body
        }
    }
}

extension LocalInformationViewController.ViewModel {
    public struct Paragraph: LocalInformationScreenBodyElement {
        let text: String?
        let link: (url: URL, title: String)?
        
        public init(text: String?, link: (url: URL, title: String)?) {
            self.text = text?.applyCurrentLanguageDirection()
            if let link = link {
                self.link = (url: link.url, title: link.title.applyCurrentLanguageDirection())
            } else {
                self.link = nil
            }
        }
    }
}

// MARK: - Interacting

public protocol LocalInformationViewControllerInteracting {
    func didTapExternalLink(url: URL)
    func didTapPrimaryButton()
    func didTapCancel()
}

// MARK: - Content Adapter

extension LocalInformationContent {
    private final class BodyContentAdapter {
        
        func views(
            forBodyElement bodyElement: LocalInformationScreenBodyElement,
            interactor: Interacting
        ) -> [UIView] {
            switch bodyElement {
            case let paragraph as ViewModel.Paragraph:
                return views(forParagraph: paragraph, interactor: interactor)
                
            default:
                return []
            }
        }
        
        private func views(
            forParagraph paragraph: ViewModel.Paragraph,
            interactor: Interacting
        ) -> [UIView] {
            var views: [UIView] = []
            
            if let text = paragraph.text {
                views.append(BaseLabel().styleAsBody().set(text: text))
            }
            
            if let link = paragraph.link {
                views.append(
                    LinkButton(
                        title: link.title,
                        action: { interactor.didTapExternalLink(url: link.url) }
                    )
                )
            }
            
            return views
        }
    }
}

// MARK: - Content

private class LocalInformationContent: PrimaryButtonStickyFooterScrollingContent {
    typealias Interacting = LocalInformationViewControllerInteracting
    typealias ViewModel = LocalInformationViewController.ViewModel
    
    init(viewModel: ViewModel, interactor: Interacting) {
        let contentAdapter = BodyContentAdapter()
        
        super.init(
            scrollingViews: [
                BaseLabel()
                    .styleAsPageHeader()
                    .set(text: viewModel.header),
                
                viewModel.body.flatMap {
                    contentAdapter.views(forBodyElement: $0, interactor: interactor)
                },
            ],
            primaryButton: (title: localize(.local_information_screen_primary_button), action: interactor.didTapPrimaryButton)
        )
    }
}

// MARK: - View Controller

public final class LocalInformationViewController: StickyFooterScrollingContentViewController {
    public typealias Interacting = LocalInformationViewControllerInteracting
    
    private let interactor: Interacting
    
    public init(viewModel: ViewModel, interactor: Interacting) {
        self.interactor = interactor
        let content = LocalInformationContent(viewModel: viewModel, interactor: interactor)
        super.init(content: content)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.tintColor = UIColor(.nhsBlue)
        setNavigationBarTransparent(true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: localize(.cancel),
            style: .plain,
            target: self,
            action: #selector(didTapCancel)
        )
    }
    
    private func setNavigationBarTransparent(_ isTransparent: Bool) {
        let image = isTransparent ? UIImage() : nil
        navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        navigationController?.navigationBar.shadowImage = image
        navigationController?.navigationBar.isTranslucent = isTransparent
    }
    
    @objc
    private func didTapCancel() {
        interactor.didTapCancel()
    }
}
