//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import Localization
import SwiftUI

public protocol RiskLevelinfoInteracting {
    func didTapWebsiteLink()
}

public class RiskLevelInfoViewModel: ObservableObject {
    public enum RiskLevel: String {
        case low
        case medium
        case high
    }
    
    var riskLevel: RiskLevel
    
    var heading: String {
        let level: String
        
        switch riskLevel {
        case .low:
            level = localize(.risk_level_low)
        case .medium:
            level = localize(.risk_level_medium)
        case .high:
            level = localize(.risk_level_high)
        }
        return localize(.risk_level_banner_text(postcode: postcode, risk: level))
        
    }
    
    var body: String {
        switch riskLevel {
        case .low: return localize(.risk_level_screen_low_body)
        case .medium: return localize(.risk_level_screen_medium_body)
        case .high: return localize(.risk_level_screen_high_body)
        }
    }
    
    var bannerImageName: ImageName {
        switch riskLevel {
        case .low: return .riskLevelLow
        case .medium: return .riskLevelMedium
        case .high: return .riskLevelHigh
        }
    }
    
    let linkButtonTitle: String
    let postcode: String
    
    public init(postcode: String, riskLevel: RiskLevel) {
        self.riskLevel = riskLevel
        self.postcode = postcode
        linkButtonTitle = localize(.risk_level_screen_button)
    }
}

public class RiskLevelInfoViewController: UIViewController {
    public typealias Interacting = RiskLevelinfoInteracting
    
    private let viewModel: RiskLevelInfoViewModel
    private let interactor: Interacting
    
    public init(viewModel: RiskLevelInfoViewModel, interactor: Interacting) {
        self.interactor = interactor
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.styleAsScreenBackground(with: traitCollection)
        
        navigationItem.title = localize(.risk_level_screen_title)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: localize(.risk_level_screen_close_button), style: .done, target: self, action: #selector(didTapCancel))
        
        let imageView = UIImageView(viewModel.bannerImageName)
        imageView.styleAsDecoration()
        
        let heading = UILabel()
        heading.styleAsTertiaryTitle()
        heading.text = viewModel.heading
        
        let body = UILabel()
        body.styleAsBody()
        body.text = viewModel.body
        
        let linkButton = LinkButton(title: viewModel.linkButtonTitle)
        linkButton.addTarget(self, action: #selector(didTapMoreInfo), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [imageView, heading, body, linkButton])
        stackView.axis = .vertical
        stackView.spacing = .standardSpacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .standard
        
        let scrollView = UIScrollView()
        
        scrollView.addFillingSubview(stackView)
        
        view.addAutolayoutSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
    }
    
    override public func accessibilityPerformEscape() -> Bool {
        dismiss(animated: true)
        return true
    }
    
    @objc func didTapCancel() {
        dismiss(animated: true)
    }
    
    @objc func didTapMoreInfo() {
        interactor.didTapWebsiteLink()
    }
    
}
