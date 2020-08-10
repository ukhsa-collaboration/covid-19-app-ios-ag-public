//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public protocol NoSymptomsViewControllerInteracting {
    func didTapReturnHome()
    func didTapNHS111Link()
}

public class NoSymptomsViewController: UIViewController {
    
    public typealias Interacting = NoSymptomsViewControllerInteracting
    
    private let interactor: Interacting
    
    public init(interactor: Interacting) {
        self.interactor = interactor
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)
        
        navigationController?.navigationBar.isHidden = true
        
        let clipboardImage = UIImageView(.medicalRecord)
        clipboardImage.contentMode = .scaleAspectFit
        clipboardImage.adjustsImageSizeForAccessibilityContentSizeCategory = true
        
        let heading = UILabel()
        heading.text = localize(.no_symptoms_heading)
        heading.textColor = UIColor(.primaryText)
        heading.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        heading.numberOfLines = 0
        heading.adjustsFontForContentSizeCategory = true
        
        let description1 = UILabel()
        description1.text = localize(.no_symptoms_body_1)
        description1.styleAsBody()
        
        let description2 = UILabel()
        description2.text = localize(.no_symptoms_body_2)
        description2.styleAsBody()
        
        let link = LinkButton(title: localize(.no_symptoms_link))
        link.addTarget(self, action: #selector(didTapNHS111Link), for: .touchUpInside)
        
        let contentStack = UIStackView(arrangedSubviews: [clipboardImage, heading, description1, description2, link])
        contentStack.axis = .vertical
        contentStack.spacing = .standardSpacing
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = .standard
        
        let scrollView = UIScrollView()
        scrollView.addFillingSubview(contentStack)
        
        view.addAutolayoutSubview(scrollView)
        
        let returnHomeButton = UIButton()
        returnHomeButton.setTitle(localize(.no_symptoms_return_home_button), for: .normal)
        returnHomeButton.styleAsPrimary()
        returnHomeButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        returnHomeButton.addTarget(self, action: #selector(didTapReturnHome), for: .touchUpInside)
        
        let buttonStack = UIStackView(arrangedSubviews: [returnHomeButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = .standardSpacing
        buttonStack.isLayoutMarginsRelativeArrangement = true
        buttonStack.layoutMargins = .standard
        
        view.addAutolayoutSubview(buttonStack)
        
        NSLayoutConstraint.activate([
            contentStack.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    @objc func didTapReturnHome() {
        interactor.didTapReturnHome()
    }
    
    @objc func didTapNHS111Link() {
        interactor.didTapNHS111Link()
    }
}
