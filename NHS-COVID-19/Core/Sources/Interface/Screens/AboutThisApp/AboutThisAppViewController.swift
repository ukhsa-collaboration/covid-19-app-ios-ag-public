//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol AboutThisAppContentInteracting {
    func didTapCommonQuestions()
    func didTapTermsOfUse()
    func didTapPrivacyNotice()
    func didTapAccessibilityStatement()
    func didTapSeeData()
    func didTapHowThisAppWorks()
    func didTapProvideFeedback()
}

extension AboutThisAppViewController {
    
    static func content(interactor: Interacting, appName: String?, version: String?) -> [UIView] {
        
        func makeStackView(with symbol: ImageName, and title: String) -> UIStackView {
            let icon = UIImageView(symbol).color(.primaryText).styleAsDecoration()
            let imageSize = icon.image!.size
            let aspectRatio = imageSize.height / imageSize.width
            
            let titleLabel = BaseLabel()
            titleLabel.text = title
            titleLabel.styleAsBody()
            titleLabel.isAccessibilityElement = false
            
            let symbolWithTitleStackview = UIStackView(arrangedSubviews: [icon, titleLabel])
            symbolWithTitleStackview.alignment = .center
            symbolWithTitleStackview.spacing = .halfSpacing
            
            NSLayoutConstraint.activate([
                icon.widthAnchor.constraint(equalToConstant: .symbolIconWidth),
                icon.heightAnchor.constraint(equalTo: icon.widthAnchor, multiplier: aspectRatio),
            ])
            
            return symbolWithTitleStackview
            
        }
        
        func makeIdentedStackView(text: [String]) -> UIStackView {
            let labels: [UILabel] = text.map {
                let label = BaseLabel()
                label.text = $0
                label.styleAsBody()
                label.isAccessibilityElement = false
                return label
            }
            
            let indentedStackView = UIStackView(arrangedSubviews: labels)
            indentedStackView.axis = .vertical
            indentedStackView.distribution = .fill
            indentedStackView.spacing = .hairSpacing
            indentedStackView.layoutMargins = UIEdgeInsets(
                top: 0,
                left:
                .symbolIconWidth + .halfSpacing,
                bottom: 0,
                right: 0
            )
            indentedStackView.isLayoutMarginsRelativeArrangement = true
            
            return indentedStackView
        }
        
        let appNameView = makeIdentedStackView(
            text: [localize(.about_this_app_software_information_app_name), appName ?? ""]
        )
        appNameView.isAccessibilityElement = true
        appNameView.accessibilityTraits = .staticText
        appNameView.accessibilityLabel = "\(localize(.about_this_app_software_information_app_name)) \(appName ?? "")"
        
        let instructionForUseView: UIView = {
            let stackView = makeStackView(with: .symbolInstructionForUse, and: localize(.about_this_app_how_this_app_works_instruction_for_use))
            stackView.isAccessibilityElement = true
            stackView.accessibilityTraits = .staticText
            stackView.accessibilityLabel = localize(.about_this_app_how_this_app_works_instruction_for_use)
            return stackView
        }()
        
        let versionView: UIView = {
            let versionTitleView = makeStackView(with: .symbolRef, and: localize(.about_this_app_software_information_version))
            let versionDescriptionView = makeIdentedStackView(text: [version ?? ""])
            
            let stackView = UIStackView(arrangedSubviews: [versionTitleView, versionDescriptionView])
            stackView.axis = .vertical
            stackView.spacing = .halfSpacing
            
            stackView.isAccessibilityElement = true
            stackView.accessibilityTraits = .staticText
            stackView.accessibilityLabel = "\(localize(.about_this_app_software_information_version)) \(version ?? "")"
            return stackView
        }()
        
        let dateOfReleaseView: UIView = {
            let dateOfReleaseTitleView = makeStackView(
                with: .symbolRelease,
                and: localize(.about_this_app_software_information_date_of_release_title)
            )
            let dateOfReleaseDescriptionView = makeIdentedStackView(
                text: [localize(.about_this_app_software_information_date_of_release_description)])
            
            let stackView = UIStackView(arrangedSubviews: [dateOfReleaseTitleView, dateOfReleaseDescriptionView])
            stackView.axis = .vertical
            stackView.spacing = .halfSpacing
            
            stackView.isAccessibilityElement = true
            stackView.accessibilityTraits = .staticText
            stackView.accessibilityLabel = localize(.about_this_app_software_information_date_of_release_title) + " "
                + localize(.about_this_app_software_information_date_of_release_description)
            return stackView
        }()
        
        let manufacturerView: UIView = {
            let manufacturerTitleView = makeStackView(
                with: .symbolManufacturer,
                and: localize(.about_this_app_software_information_manufacturer_title)
            )
            let manufacturerViewDescriptionView = makeIdentedStackView(
                text: [localize(.about_this_app_software_information_manufacturer_description)])
            
            let stackView = UIStackView(arrangedSubviews: [manufacturerTitleView, manufacturerViewDescriptionView])
            stackView.axis = .vertical
            stackView.spacing = .halfSpacing
            
            stackView.isAccessibilityElement = true
            stackView.accessibilityTraits = .staticText
            stackView.accessibilityLabel = localize(.about_this_app_software_information_manufacturer_title) + " "
                + localize(.about_this_app_software_information_manufacturer_description)
            return stackView
        }()
        
        let ceImage: UIView = {
            let ceImage = UIImageView(.symbolUKCA).color(.primaryText).styleAsDecoration()
            let ceImageStackView = UIStackView(arrangedSubviews: [ceImage, UIView()])
            ceImageStackView.alignment = .firstBaseline
            
            let indentedStackView = UIStackView(arrangedSubviews: [ceImageStackView])
            indentedStackView.axis = .vertical
            indentedStackView.distribution = .fill
            indentedStackView.spacing = .hairSpacing
            indentedStackView.layoutMargins = UIEdgeInsets(
                top: 0,
                left:
                .symbolIconWidth + .halfSpacing,
                bottom: 0,
                right: 0
            )
            indentedStackView.isLayoutMarginsRelativeArrangement = true
            
            return indentedStackView
        }()
        
        let views = [
            InformationBox.information.purple([
                .heading(.about_this_app_how_this_app_works_heading),
                .body(.about_this_app_how_this_app_works_paragraph1),
                .body(.about_this_app_how_this_app_works_paragraph2),
                .body(.about_this_app_how_this_app_works_paragraph3),
                .view(instructionForUseView),
                .linkButton(.about_this_app_how_this_app_works_button, interactor.didTapHowThisAppWorks),
            ]),
            InformationBox.information.orange([
                .heading(.about_this_app_my_data_heading),
                .body(.about_this_app_my_data_description),
                .body(.about_this_app_my_data_app_settings),
            ]),
            InformationBox.information.pink([
                .heading(.about_this_app_our_policies_heading),
                .body(.about_this_app_our_policies_description),
                .linkButton(.about_this_app_our_policies_terms_of_use_button, interactor.didTapTermsOfUse),
                .linkButton(.about_this_app_our_policies_privacy_notice_button, interactor.didTapPrivacyNotice),
                .linkButton(.about_this_app_our_policies_accessibility_statement_button, interactor.didTapAccessibilityStatement),
            ]),
            InformationBox.information.turquoise([
                .heading(.about_this_app_common_questions_heading),
                .body(.about_this_app_common_questions_description),
                .linkButton(.about_this_app_common_questions_button, interactor.didTapCommonQuestions),
            ]),
            InformationBox.information.darkBlue([
                .heading(.about_this_app_software_information_heading),
                .view(appNameView),
                .view(versionView),
                .view(dateOfReleaseView),
                .view(manufacturerView),
                .view(ceImage),
            ]),
            InformationBox.information.purple([
                .heading(.about_this_app_feedback_information_title),
                .body(.about_this_app_feedback_information_description),
                .linkButton(.about_this_app_feedback_information_link_title, interactor.didTapProvideFeedback),
            ]),
            BaseLabel().set(text: localize(.about_this_app_footer_text)).styleAsHeading().centralized(),
            UIImageView(.onboardingStart).styleAsDecoration(),
        ]
        
        return views
    }
    
}

public class AboutThisAppViewController: ScrollingContentViewController {
    public typealias Interacting = AboutThisAppContentInteracting
    
    public init(interactor: Interacting, appName: String?, version: String?) {
        super.init(views: Self.content(interactor: interactor, appName: appName, version: version))
        title = localize(.about_this_app_title)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
