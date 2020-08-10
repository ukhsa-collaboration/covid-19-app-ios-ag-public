//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

public class InformationBox: UIView {
    
    /// Defines the color of the bar at the side of InformationBox
    public enum Style {
        /// Has a blue bar at the side
        case information
        /// Has a green bar at the side
        case goodNews
        /// Has a yellow bar at the side
        case warning
        /// Has a red bar at the side
        case badNews
        // Has a clear bar at the side
        case noNews
    }
    
    var style: Style = .information {
        didSet {
            setupColor(for: style)
        }
    }
    
    private let containerStackView = UIStackView()
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = .standardSpacing
        stackView.layoutMargins = .infoboxStack
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private let stripe = UIView()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setUp()
    }
    
    public init(views: [UIView], style: Style, backgroundColor: UIColor = UIColor(.background)) {
        super.init(frame: .zero)
        self.style = style
        
        setUp()
        
        views.forEach { contentStackView.addArrangedSubview($0) }
        containerStackView.addArrangedSubview(contentStackView)
        self.backgroundColor = backgroundColor
    }
    
    private func setUp() {
        setupColor(for: style)
        
        NSLayoutConstraint.activate([
            stripe.widthAnchor.constraint(equalToConstant: .stripeWidth),
        ])
        
        containerStackView.addArrangedSubview(stripe)
        containerStackView.axis = .horizontal
        containerStackView.alignment = .fill
        containerStackView.distribution = .fill
        containerStackView.spacing = .stripeSpacing
        addFillingSubview(containerStackView)
    }
    
    func setupColor(for style: Style) {
        switch style {
        case .information:
            stripe.backgroundColor = UIColor(.nhsBlue)
        case .goodNews:
            stripe.backgroundColor = UIColor(.nhsButtonGreen)
        case .warning:
            stripe.backgroundColor = UIColor(.amber)
        case .badNews:
            stripe.backgroundColor = UIColor(.errorRed)
        case .noNews:
            stripe.backgroundColor = .clear
        }
    }
}
