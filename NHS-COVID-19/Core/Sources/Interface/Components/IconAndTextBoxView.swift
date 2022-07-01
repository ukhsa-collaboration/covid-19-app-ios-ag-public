//
// Copyright © 2021 DHSC. All rights reserved.
//

import UIKit

class IconAndTextBoxView: UIView {

    var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    var infoTextLabel: UILabel = {
        let label = BaseLabel()
        label.styleAsBoldBody()
        return label
    }()

    init(imageName: ImageName, infoText: String, backgroundColor: UIColor = UIColor(.surface)) {
        super.init(frame: .zero)
        iconImageView.image = UIImage(imageName)
        infoTextLabel.text = infoText
        let stackView = UIStackView.horizontal(with: [iconImageView, infoTextLabel])
        stackView.alignment = .center
        addFillingSubview(stackView)
        self.backgroundColor = backgroundColor
        layer.borderWidth = 1
        layer.cornerRadius = 4
        layer.borderColor = UIColor(.borderColor).cgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension IconAndTextBoxView {

    static func privacy(text: String) -> IconAndTextBoxView {
        IconAndTextBoxView(imageName: .privacyIcon, infoText: text)

    }
}
