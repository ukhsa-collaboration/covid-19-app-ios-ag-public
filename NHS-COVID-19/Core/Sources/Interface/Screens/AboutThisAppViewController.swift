//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public protocol AboutThisAppViewControllerInteracting {
    
    func didTapCommonQuestions()
    func didTapTermsOfUse()
    func didTapPrivacyNotice()
    func didTapAccessibilityStatement()
    func didTapSeeData()
}

public class AboutThisAppViewController: UIViewController {
    
    public typealias Interacting = AboutThisAppViewControllerInteracting
    
    private let interacting: Interacting
    
    private let appName: String?
    private let version: String?
    public init(interactor: Interacting, appName: String?, version: String?) {
        interacting = interactor
        self.appName = appName
        self.version = version
        super.init(nibName: nil, bundle: nil)
        
        title = localize(.about_this_app_title)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var aboutThisAppSection: UIView = {
        let headingLabel = UILabel()
        headingLabel.styleAsHeading()
        headingLabel.text = localize(.about_this_app_how_this_app_works_heading)
        
        let paragraph1 = UILabel()
        paragraph1.styleAsBody()
        paragraph1.text = localize(.about_this_app_how_this_app_works_paragraph1)
        
        let paragraph2 = UILabel()
        paragraph2.styleAsBody()
        paragraph2.text = localize(.about_this_app_how_this_app_works_paragraph2)
        
        let paragraph3 = UILabel()
        paragraph3.styleAsBody()
        paragraph3.text = localize(.about_this_app_how_this_app_works_paragraph3)
        
        let paragraph4 = UILabel()
        paragraph4.styleAsBody()
        paragraph4.text = localize(.about_this_app_how_this_app_works_paragraph4)
        
        return InformationBox(views: [headingLabel, paragraph1, paragraph2, paragraph3, paragraph4], style: .information)
    }()
    
    private lazy var commonQuestionsSection: UIView = {
        let headingLabel = UILabel()
        headingLabel.styleAsHeading()
        headingLabel.text = localize(.about_this_app_common_questions_heading)
        
        let descriptionLabel = UILabel()
        descriptionLabel.styleAsBody()
        descriptionLabel.text = localize(.about_this_app_common_questions_description)
        
        let commonQuestionsButton = LinkButton(
            title: localize(.about_this_app_common_questions_button)
        )
        commonQuestionsButton.addTarget(self, action: #selector(didTapCommonQuestions), for: .touchUpInside)
        
        return InformationBox(views: [headingLabel, descriptionLabel, commonQuestionsButton], style: .information)
    }()
    
    private lazy var ourPoliciesSection: UIView = {
        let headingLabel = UILabel()
        headingLabel.styleAsHeading()
        headingLabel.text = localize(.about_this_app_our_policies_heading)
        
        let descriptionLabel = UILabel()
        descriptionLabel.styleAsBody()
        descriptionLabel.text = localize(.about_this_app_our_policies_description)
        
        let termsOfUseButton = LinkButton(
            title: localize(.about_this_app_our_policies_terms_of_use_button)
        )
        termsOfUseButton.addTarget(self, action: #selector(didTapTermsOfUse), for: .touchUpInside)
        
        let privacyNoticeButton = LinkButton(
            title: localize(.about_this_app_our_policies_privacy_notice_button)
        )
        privacyNoticeButton.addTarget(self, action: #selector(didTapPrivacyNotice), for: .touchUpInside)
        
        let accessibilityStatementButton = LinkButton(
            title: localize(.about_this_app_our_policies_accessibility_statement_button)
        )
        accessibilityStatementButton.addTarget(self, action: #selector(didTapAccessibilityStatement), for: .touchUpInside)
        
        return InformationBox(views: [headingLabel, descriptionLabel, termsOfUseButton, privacyNoticeButton, accessibilityStatementButton], style: .information)
    }()
    
    private lazy var showMyDataSection: UIView = {
        let headingLabel = UILabel()
        headingLabel.styleAsHeading()
        headingLabel.text = localize(.about_this_app_my_data_heading)
        
        let descriptionLabel = UILabel()
        descriptionLabel.styleAsBody()
        descriptionLabel.text = localize(.about_this_app_my_data_description)
        
        let showMyDataButton = LinkButton(
            title: localize(.about_this_app_my_data_button),
            accessoryImage: nil
        )
        showMyDataButton.addTarget(self, action: #selector(didTapSeeData), for: .touchUpInside)
        
        return InformationBox(views: [headingLabel, descriptionLabel, showMyDataButton], style: .information)
    }()
    
    private lazy var softwareInformationSection: UIView = {
        let headingLabel = UILabel()
        headingLabel.styleAsHeading()
        headingLabel.text = localize(.about_this_app_software_information_heading)
        
        let appNameLabel = UILabel()
        appNameLabel.styleAsBody()
        
        appNameLabel.text = localize(.about_this_app_software_information_app_name(name: appName ?? ""))
        
        let versionLabel = UILabel()
        versionLabel.styleAsBody()
        versionLabel.text = localize(.about_this_app_software_information_version(version: version ?? ""))
        
        let dateOfReleaseLabel = UILabel()
        dateOfReleaseLabel.styleAsBody()
        dateOfReleaseLabel.text = localize(.about_this_app_software_information_date_of_release)
        
        let nameAndAddressLabel = UILabel()
        nameAndAddressLabel.styleAsBody()
        nameAndAddressLabel.text = localize(.about_this_app_software_information_entity_name_and_address)
        
        return InformationBox(views: [headingLabel, appNameLabel, versionLabel, dateOfReleaseLabel, nameAndAddressLabel], style: .information)
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)
        
        let sections: [UIView] = [
            aboutThisAppSection,
            showMyDataSection,
            ourPoliciesSection,
            commonQuestionsSection,
            softwareInformationSection,
        ]
        
        let stackView = UIStackView(arrangedSubviews: sections)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = .bigSpacing
        stackView.layoutMargins = .standard
        stackView.isLayoutMarginsRelativeArrangement = true
        
        let scrollView = UIScrollView()
        scrollView.addFillingSubview(stackView)
        
        view.addAutolayoutSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc func didTapCommonQuestions() {
        interacting.didTapCommonQuestions()
    }
    
    @objc func didTapPrivacyNotice() {
        interacting.didTapPrivacyNotice()
    }
    
    @objc func didTapSeeData() {
        interacting.didTapSeeData()
    }
    
    @objc func didTapTermsOfUse() {
        interacting.didTapTermsOfUse()
    }
    
    @objc func didTapAccessibilityStatement() {
        interacting.didTapAccessibilityStatement()
    }
}
 