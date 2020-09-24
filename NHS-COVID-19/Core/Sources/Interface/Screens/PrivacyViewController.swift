//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public protocol PrivacyViewControllerInteracting {
    func didTapPrivacyNotice()
    
    func didTapTermsOfUse()
    
    func didTapAgree()
    
    func didTapNoThanks()
}

public class PrivacyViewController: UIViewController {
    
    public typealias Interacting = PrivacyViewControllerInteracting
    
    private let interacting: Interacting
    
    public init(interactor: Interacting) {
        interacting = interactor
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)
        
        let content = getContent()
        
        let stackView = UIStackView(arrangedSubviews: content)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = .standardSpacing
        stackView.layoutMargins = .standard
        stackView.isLayoutMarginsRelativeArrangement = true
        
        let scrollView = UIScrollView()
        scrollView.addFillingSubview(stackView)
        
        view.addAutolayoutSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            stackView.widthAnchor.constraint(equalTo: view.readableContentGuide.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func getContent() -> [UIView] {
        let headerContent = getHeaderContent()
        let privacyInformationView = getPrivacyInformationView()
        let dataInformationView = getDataInformationView()
        let footerContent = getFooterContent()
        return [headerContent, privacyInformationView, dataInformationView, footerContent]
    }
    
    private func getHeaderContent() -> UIStackView {
        let logoStrapline = LogoStrapline(.nhsBlue, style: .onboarding)
        
        let image = UIImage(.onboardingPrivacy)
        let imageView = UIImageView(image: image)
        imageView.styleAsDecoration()
        
        let privacyTitle = UILabel()
        privacyTitle.styleAsPageHeader()
        privacyTitle.text = localize(.privacy_title)
        
        let stackView = UIStackView(arrangedSubviews: [logoStrapline, imageView, privacyTitle])
        stackView.axis = .vertical
        stackView.spacing = .standardSpacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .inner
        return stackView
    }
    
    private func getFooterContent() -> UIStackView {
        let linksHeader = UILabel()
        linksHeader.textColor = UIColor(.primaryText)
        linksHeader.setDynamicTextStyle(.headline)
        linksHeader.text = localize(.privacy_links_label)
        linksHeader.accessibilityLabel = localize(.privacy_links_accessibility_label)
        
        let dataDescription3 = UILabel()
        dataDescription3.styleAsBody()
        dataDescription3.text = localize(.privacy_description_paragraph4)
        
        let privacyNotice = LinkButton(
            title: localize(.privacy_notice_label)
        )
        privacyNotice.addTarget(self, action: #selector(didTapPrivacyNotice), for: .touchUpInside)
        
        let termsOfUse = LinkButton(
            title: localize(.terms_of_use_label)
        )
        termsOfUse.addTarget(self, action: #selector(didTapTermsOfUse), for: .touchUpInside)
        
        let agreeButton = UIButton()
        agreeButton.styleAsPrimary()
        agreeButton.setTitle(localize(.privacy_yes_button), for: .normal)
        agreeButton.addTarget(self, action: #selector(didTapAgree), for: .touchUpInside)
        
        let noThanksButton = UIButton()
        noThanksButton.styleAsSecondary()
        noThanksButton.setTitle(localize(.privacy_no_button), for: .normal)
        noThanksButton.addTarget(self, action: #selector(didTapNoThanks), for: .touchUpInside)
        noThanksButton.accessibilityLabel = localize(.privacy_no_button_accessibility_label)
        
        let stackView = UIStackView(arrangedSubviews: [dataDescription3, linksHeader, privacyNotice, termsOfUse, agreeButton, noThanksButton])
        stackView.axis = .vertical
        stackView.spacing = .standardSpacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .inner
        stackView.setCustomSpacing(.tripleSpacing, after: termsOfUse)
        return stackView
    }
    
    private func getPrivacyInformationView() -> UIView {
        let privacyHeader = UILabel()
        privacyHeader.styleAsTertiaryTitle()
        privacyHeader.text = localize(.privacy_header)
        
        let privacyDescription = UILabel()
        privacyDescription.styleAsBody()
        privacyDescription.text = localize(.privacy_description_paragraph1)
        
        let stackView = UIStackView(arrangedSubviews: [privacyHeader, privacyDescription])
        stackView.axis = .vertical
        stackView.spacing = .halfSpacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .inner
        return stackView
    }
    
    private func getDataInformationView() -> UIView {
        let dataHeader = UILabel()
        dataHeader.styleAsTertiaryTitle()
        dataHeader.text = localize(.data_header)
        
        let dataDescription1 = UILabel()
        dataDescription1.styleAsBody()
        dataDescription1.text = localize(.privacy_description_paragraph2)
        
        let stackView = UIStackView(arrangedSubviews: [dataHeader, dataDescription1])
        stackView.axis = .vertical
        stackView.spacing = .halfSpacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .inner
        return stackView
    }
    
    @objc func didTapPrivacyNotice() {
        interacting.didTapPrivacyNotice()
    }
    
    @objc func didTapTermsOfUse() {
        interacting.didTapTermsOfUse()
    }
    
    @objc func didTapAgree() {
        interacting.didTapAgree()
    }
    
    @objc func didTapNoThanks() {
        interacting.didTapNoThanks()
    }
}
