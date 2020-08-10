//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class InformationBoxComponentScenario: Scenario {
    public static let name = "InformationBox"
    public static let kind = ScenarioKind.component
    public static let shortLabel = "Single short label"
    public static let longLabel = "This is a single label with a longer text. It should provoke a linebreak and everything should work fine."
    public static let title = "This is a title"
    public static let shortStackLabel = "This is a stack label with a short text"
    public static let longStackLabel = "This is a stack Label with a longer text. It should provoke a linebreak and everything should work fine."
    public static let link = "Clickable Component"
    public static let linkActionText = "Link tapped"
    public static let warningLabel = "This box has the warning style and should have a yellow bar"
    public static let goodNewsLabel = "This box has the goodNews style and should have a green bar"
    public static let badNewsLabel = "This box has the badNews style and should have a red bar"
    
    public static let indicationLabel = "Indication boxes can be constructed with just text. Styling is handled automatically"
    public static let informationLabel = "Information boxes can be constructed with a title and body, or just a body. Styling is handled automatically"
    
    public static let informationNoTitleLabel = "This is an information box without a title"
    public static let informationTitleLabel = "This is an information box with a title"
    public static let informationBodyLabel = "The body is styled differently to the title"
    
    public static let informationBodyMultipleLabel = [
        "The body is given as a list of text.",
        "This text will be split into multiple labels.",
        "Multiple labels equates to multiple accessability elements for better readability.",
    ]
    
    static var appController: AppController {
        let navigation = UINavigationController()
        navigation.pushViewController(InformationBoxViewController(), animated: false)
        return BasicAppController(rootViewController: navigation)
    }
}

private class InformationBoxViewController: UIViewController {
    private typealias Scenario = InformationBoxComponentScenario
    
    private lazy var singleLabelShortInformationBox: UIView = {
        let label = UILabel()
        label.styleAsBody()
        label.text = Scenario.shortLabel
        
        return InformationBox(views: [label], style: .information)
    }()
    
    private lazy var singleLabelLongInformationBox: UIView = {
        let label = UILabel()
        label.styleAsBody()
        label.text = Scenario.longLabel
        label.numberOfLines = 0
        
        return InformationBox(views: [label], style: .information)
    }()
    
    private lazy var stackViewInformationBox: UIView = {
        let title = UILabel()
        title.styleAsHeading()
        title.text = Scenario.title
        
        let stackLabel1 = UILabel()
        stackLabel1.styleAsBody()
        stackLabel1.text = Scenario.shortStackLabel
        
        let stackLabel2 = UILabel()
        stackLabel2.styleAsBody()
        stackLabel2.text = Scenario.longStackLabel
        stackLabel2.numberOfLines = 0
        
        return InformationBox(views: [title, stackLabel1, stackLabel2], style: .information)
    }()
    
    private lazy var clickableComponentInformationBox: UIView = {
        let link = LinkButton(title: Scenario.link)
        link.addTarget(self, action: #selector(didTapLink), for: .touchUpInside)
        
        return InformationBox(views: [link], style: .information)
    }()
    
    private lazy var warningInformationBox: UIView = {
        let label = UILabel()
        label.styleAsBody()
        label.text = Scenario.warningLabel
        
        return InformationBox(views: [label], style: .warning)
    }()
    
    private lazy var goodNewsInformationBox: UIView = {
        let label = UILabel()
        label.styleAsBody()
        label.text = Scenario.goodNewsLabel
        
        return InformationBox(views: [label], style: .goodNews)
    }()
    
    private lazy var badNewsInformationBox: UIView = {
        let label = UILabel()
        label.styleAsBody()
        label.text = Scenario.badNewsLabel
        
        return InformationBox(views: [label], style: .badNews)
    }()
    
    private lazy var indicationStack: UIView = {
        let stack = UIStackView(arrangedSubviews: [
            UILabel().styleAsSecondaryTitle().set(text: Scenario.indicationLabel),
            InformationBox.indication.goodNews(Scenario.goodNewsLabel),
            InformationBox.indication.badNews(Scenario.badNewsLabel),
            InformationBox.indication.warning(Scenario.warningLabel),
        ])
        
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        stack.spacing = .bigSpacing
        return stack
    }()
    
    private lazy var informationStack: UIView = {
        let stack = UIStackView(arrangedSubviews: [
            UILabel().styleAsSecondaryTitle().set(text: Scenario.informationLabel),
            InformationBox.information(Scenario.informationNoTitleLabel),
            InformationBox.information(
                title: Scenario.informationTitleLabel,
                body: [Scenario.informationBodyLabel]
            ),
            InformationBox.information(
                title: Scenario.informationTitleLabel,
                body: Scenario.informationBodyMultipleLabel
            ),
        ])
        
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        stack.spacing = .bigSpacing
        return stack
    }()
    
    override func viewDidLoad() {
        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)
        
        let contentStackView = UIStackView(arrangedSubviews: [
            singleLabelShortInformationBox,
            singleLabelLongInformationBox,
            stackViewInformationBox,
            clickableComponentInformationBox,
            warningInformationBox,
            goodNewsInformationBox,
            badNewsInformationBox,
            indicationStack,
            informationStack,
        ])
        
        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.distribution = .equalSpacing
        contentStackView.spacing = .bigSpacing
        
        let scrollView = UIScrollView()
        scrollView.addFillingSubview(contentStackView)
        
        view.addAutolayoutSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            contentStackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 1),
        ])
    }
    
    @objc private func didTapLink() {
        showAlert(title: Scenario.linkActionText)
    }
}
