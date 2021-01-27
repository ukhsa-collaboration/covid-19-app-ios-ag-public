//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public class LocalAuthorityInformationViewController: OnboardingStepViewController {
    
    public init(action: @escaping () -> Void) {
        super.init(step: LocalAuthorityInformationStep(action: action))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private class LocalAuthorityInformationStep: NSObject, OnboardingStep {
    var footerContent = [UIView]()
    var strapLineStyle: LogoStrapline.Style? { .onboarding }
    
    private let action: () -> Void
    
    private lazy var title: UILabel = {
        let label = BaseLabel()
        label.text = localize(.local_authority_information_title)
        label.styleAsPageHeader()
        return label
    }()
    
    let actionTitle = localize(.local_authority_information_button)
    let image: UIImage? = UIImage(.onboardingPostcode)
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    private var descriptionLabel: [UILabel] {
        localizeAndSplit(.local_authority_information_description).map { BaseLabel().styleAsBody().set(text: String($0)) }
    }
    
    var content: [UIView] {
        var content = [title]
        content.append(contentsOf: descriptionLabel)
        return [stack(for: content, spacing: .halfSpacing)]
    }
    
    func act() {
        action()
    }
}
