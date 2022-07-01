//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit
import SwiftUI

private class BulletPoint: UIView {

    private let text: String
    private let symbolProperties: SymbolProperties

    private lazy var bulletPointStackView: UIStackView = {

        // Purpose of this label is to make sure that bullet point symbol is always
        // vertically centered with the first line of text — even when font size is changed
        let hiddenLabel = BaseLabel()
        hiddenLabel.styleAsBody()
        hiddenLabel.text = "A"
        hiddenLabel.isAccessibilityElement = false

        let symbol = makeSymbol(from: symbolProperties.type)
        let stackView = UIStackView(arrangedSubviews: [symbol, hiddenLabel])
        stackView.alignment = .center
        stackView.distribution = .fill

        NSLayoutConstraint.activate([
            // Hides the label but center alignment still works
            hiddenLabel.widthAnchor.constraint(equalToConstant: 0),
        ])

        return stackView
    }()

    private lazy var mainStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [bulletPointStackView])
        stackView.alignment = .firstBaseline
        stackView.distribution = .fill
        stackView.spacing = .standardSpacing

        stackView.isAccessibilityElement = true
        stackView.accessibilityTraits = .staticText
        stackView.accessibilityLabel = text

        return stackView
    }()

    private func makeSymbol(from type: BulletSymbol) -> UIView {
        switch type {
        case .fullCircle:
            return Circle(size: symbolProperties.size, color: symbolProperties.color)
        }
    }

    init(text: String, symbolProperties: SymbolProperties, boldText: Bool = false) {
        self.text = text
        self.symbolProperties = symbolProperties
        super.init(frame: .zero)

        let contentLabel = BaseLabel()
        contentLabel.text = text
        if boldText {
            contentLabel.styleAsBoldBody()
        } else {
            contentLabel.styleAsBody()
        }
        contentLabel.isAccessibilityElement = false

        mainStack.addArrangedSubview(contentLabel)

        addFillingSubview(mainStack)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension BulletPoint {
    class Circle: UIView {
        let size: CGFloat
        let color: ColorName

        init(size: CGFloat, color: ColorName) {
            self.size = size
            self.color = color
            super.init(frame: .zero)
            setup()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setup() {
            backgroundColor = UIColor(color)
            layer.cornerRadius = size / 2

            NSLayoutConstraint.activate([
                widthAnchor.constraint(equalToConstant: size),
                heightAnchor.constraint(equalTo: widthAnchor),
            ])
        }

    }
}

public class BulletedList: UIView {
    private let symbolProperties: SymbolProperties
    private let boldText: Bool

    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = .standardSpacing
        return stack
    }()

    public init(
        symbolProperties: SymbolProperties = SymbolProperties(type: .fullCircle, size: .halfSpacing, color: .nhsBlue),
        rows: [String] = [],
        stackSpaceing: CGFloat = .standardSpacing,
        boldText: Bool = false
    ) {
        self.symbolProperties = symbolProperties
        self.boldText = boldText
        super.init(frame: .zero)

        stackView.spacing = stackSpaceing

        rows.forEach {
            let bulletRow = BulletPoint(text: $0, symbolProperties: symbolProperties, boldText: boldText)
            stackView.addArrangedSubview(bulletRow)
        }

        addFillingSubview(stackView)
    }

    public func addRow(with text: String) {
        stackView.addArrangedSubview(BulletPoint(text: text, symbolProperties: symbolProperties, boldText: boldText))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public enum BulletSymbol {
    case fullCircle
}

public struct SymbolProperties {
    let type: BulletSymbol
    let size: CGFloat
    let color: ColorName

    public init(type: BulletSymbol, size: CGFloat, color: ColorName) {
        self.type = type
        self.size = size
        self.color = color
    }
}
