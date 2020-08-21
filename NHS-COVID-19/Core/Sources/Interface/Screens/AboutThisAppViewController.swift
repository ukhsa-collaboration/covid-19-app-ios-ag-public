//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol AboutThisAppViewControllerInteracting {
    
    func didTapCommonQuestions()
    func didTapTermsOfUse()
    func didTapPrivacyNotice()
    func didTapAccessibilityStatement()
    func didTapSeeData()
    func didTapHowThisAppWorks()
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
    
    private let aboutThisAppSection = InformationBox.information.purple([
        .heading(localize(.about_this_app_how_this_app_works_heading)),
        .body(localize(.about_this_app_how_this_app_works_paragraph1)),
        .body(localize(.about_this_app_how_this_app_works_paragraph2)),
        .body(localize(.about_this_app_how_this_app_works_paragraph3)),
        .view(mutating(LinkButton(title: localize(.about_this_app_how_this_app_works_button))) {
            $0.addTarget(self, action: #selector(didTapHowThisAppWorks))
        }),
    ])
    
    private lazy var commonQuestionsSection = InformationBox.information.orange([
        .heading(localize(.about_this_app_common_questions_heading)),
        .body(localize(.about_this_app_common_questions_description)),
        .view(mutating(LinkButton(title: localize(.about_this_app_common_questions_button))) {
            $0.addTarget(self, action: #selector(didTapCommonQuestions))
        }),
    ])
    
    private lazy var ourPoliciesSection: UIView = InformationBox.information.lightBlue([
        .heading(localize(.about_this_app_our_policies_heading)),
        .body(localize(.about_this_app_our_policies_description)),
        .view(mutating(LinkButton(title: localize(.about_this_app_our_policies_terms_of_use_button))) {
            $0.addTarget(self, action: #selector(didTapTermsOfUse))
        }),
        .view(mutating(LinkButton(title: localize(.about_this_app_our_policies_privacy_notice_button))) {
            $0.addTarget(self, action: #selector(didTapPrivacyNotice))
        }),
        .view(mutating(LinkButton(title: localize(.about_this_app_our_policies_accessibility_statement_button))) {
            $0.addTarget(self, action: #selector(didTapAccessibilityStatement))
        }),
    ])
    
    private lazy var showMyDataSection: UIView = InformationBox.information.turquoise([
        .heading(localize(.about_this_app_my_data_heading)),
        .body(localize(.about_this_app_my_data_description)),
        .view(mutating(LinkButton(title: localize(.about_this_app_my_data_button))) {
            $0.addTarget(self, action: #selector(didTapSeeData))
        }),
    ])
    
    private lazy var softwareInformationSection = InformationBox.information.darkBlue([
        .heading(localize(.about_this_app_software_information_heading)),
        .body(localize(.about_this_app_software_information_app_name(name: appName ?? ""))),
        .body(localize(.about_this_app_software_information_version(version: version ?? ""))),
        .body(localize(.about_this_app_software_information_date_of_release)),
        .body(localize(.about_this_app_software_information_entity_name_and_address)),
    ])
    
    private lazy var footerLabel: UILabel = {
        let label = UILabel()
        label.styleAsHeading()
        label.text = localize(.about_this_app_footer_text)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var footerImage: UIImageView = {
        let image = UIImage(named: "Onboarding/Protect")
        let imageView = UIImageView(image: image)
        imageView.styleAsDecoration()
        return imageView
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
            footerLabel,
            footerImage,
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
    
    @objc func didTapHowThisAppWorks() {
        interacting.didTapHowThisAppWorks()
    }
}
