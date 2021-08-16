//
// Copyright © 2021 DHSC. All rights reserved.
//

import UIKit

public class WelcomePoint: UIView {
    public init(image: ImageName,
                header: String? = nil,
                body: String,
                link: (title: String, action: () -> Void)? = nil) {
        super.init(frame: .zero)
        
        let bodyLabel = BaseLabel()
        bodyLabel.text = body
        bodyLabel.styleAsBody()
        
        let imageView = UIImageView(image)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(.surface)
        
        let containerView = UIView()
        containerView.addAutolayoutSubview(imageView)
        containerView.layer.cornerRadius = .hitAreaMinHeight / 2.0
        containerView.backgroundColor = UIColor(.nhsBlue)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            containerView.heightAnchor.constraint(equalToConstant: .hitAreaMinHeight),
            containerView.widthAnchor.constraint(equalToConstant: .hitAreaMinHeight),
        ])
        
        let vStack = UIStackView(arrangedSubviews: [
            bodyLabel,
        ])
        
        if let header = header {
            let headerLabel = BaseLabel()
            headerLabel.text = header
            headerLabel.styleAsTertiaryTitle()
            vStack.insertArrangedSubview(headerLabel, at: 0)
        }
        
        if let link = link {
            let linkButton = LinkButton(
                title: link.title,
                action: link.action
            )
            vStack.addArrangedSubview(linkButton)
        }
        
        vStack.axis = .vertical
        vStack.spacing = .halfSpacing
        
        let hStack = UIStackView(arrangedSubviews: [
            containerView,
            vStack,
        ])
        hStack.spacing = .bigSpacing
        hStack.alignment = .top
        
        addFillingSubview(hStack)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
