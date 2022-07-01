//
// Copyright © 2021 DHSC. All rights reserved.
//

import UIKit

public class EmptySettingsView: UIView {

    private lazy var imageView: UIImageView = {
        UIImageView()
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = BaseLabel()
        label.styleAsBoldBody()
        return label
    }()

    public init(image: UIImage, description: String) {
        super.init(frame: .zero)
        descriptionLabel.text = description
        imageView.image = image
        backgroundColor = UIColor(.background)
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func layout() {
        let stackView = UIStackView(arrangedSubviews: [imageView, descriptionLabel])
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.layoutMargins = .standard
        stackView.spacing = .standardSpacing

        addAutolayoutSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalTo: widthAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
