//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol TestCheckSymptomsViewControllerInteracting {
    var didTapYes: () -> Void { get }
    var didTapNo: () -> Void { get }
}

private class TestCheckSymptomsContent: StickyFooterScrollingContent {
    typealias Interacting = TestCheckSymptomsViewControllerInteracting
    private static let infoboxInset = (.stripeWidth + .stripeSpacing)
    
    let scrollingContent: StackContent
    let footerContent: StackContent?
    let spacing: CGFloat = .doubleSpacing
    
    public init(interactor: Interacting) {
        scrollingContent = BasicContent(
            views: [
                BaseLabel().set(text: localize(.test_check_symptoms_heading)).styleAsPageHeader(),
                BulletedList(rows: localizeAndSplit(.test_check_symptoms_points)),
            ],
            spacing: .doubleSpacing,
            margins: mutating(.largeInset) {
                $0.bottom = 0
                $0.left -= Self.infoboxInset
                $0.right -= Self.infoboxInset
            }
        )
        
        footerContent = BasicContent(
            views: [
                PrimaryButton(title: localize(.test_check_symptoms_yes), action: {
                    interactor.didTapYes()
                }),
                SecondaryButton(title: localize(.test_check_symptoms_no), action: {
                    interactor.didTapNo()
                }),
            ],
            spacing: .halfSpacing,
            margins: mutating(.largeInset) { $0.top = 0 }
        )
    }
}

public class TestCheckSymptomsViewController: StickyFooterScrollingContentViewController {
    public typealias Interacting = TestCheckSymptomsViewControllerInteracting
    
    private let interactor: Interacting
    
    public init(interactor: Interacting) {
        self.interactor = interactor
        super.init(content: TestCheckSymptomsContent(interactor: interactor))
        title = localize(.link_test_result_title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapYes() {
        interactor.didTapYes()
    }
    
    @objc private func didTapNo() {
        interactor.didTapNo()
    }
}
