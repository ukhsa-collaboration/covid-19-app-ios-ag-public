//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol UnknownTestResultsViewControllerInteracting {
    func didTapOpenStore()
    func didTapClose()
}

extension UnknownTestResultsViewController {
    private struct VerticalSpacer: StackViewContentProvider {
        let height: CGFloat
        private class VerticalSpacerView: UIView {
            let height: CGFloat
            init(height: CGFloat) {
                self.height = height
                super.init(frame: .zero)
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            override var intrinsicContentSize: CGSize {
                CGSize(width: UIView.noIntrinsicMetric, height: height)
            }
        }
        
        var content: [UIView] {
            [VerticalSpacerView(height: height)]
        }
    }
    
    private class Content: PrimaryButtonStickyFooterScrollingContent {
        init(interactor: Interacting) {
            super.init(
                scrollingViews: [
                    VerticalSpacer(height: 50),
                    UIImageView(.softwareUpdate).styleAsDecoration().color(.nhsBlue),
                    BaseLabel().set(text: localize(.unknown_test_result_screen_header)).styleAsPageHeader().leadingAligned(),
                    localizeAndSplit(.unknown_test_result_screen_description).map {
                        BaseLabel().set(text: $0).styleAsBody().leadingAligned()
                    },
                ],
                primaryButton: (
                    title: localize(.unknown_test_result_screen_button),
                    action: interactor.didTapOpenStore
                )
            )
        }
    }
}

public class UnknownTestResultsViewController: StickyFooterScrollingContentViewController {
    
    public typealias Interacting = UnknownTestResultsViewControllerInteracting
    
    private let interactor: Interacting
    
    public init(interactor: Interacting) {
        self.interactor = interactor
        super.init(content: Content(interactor: interactor))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    @objc private func didTapClose() {
        interactor.didTapClose()
    }
    
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = UIColor(.nhsBlue)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: localize(.close),
            style: .plain,
            target: self,
            action: #selector(didTapClose)
        )
    }
}
