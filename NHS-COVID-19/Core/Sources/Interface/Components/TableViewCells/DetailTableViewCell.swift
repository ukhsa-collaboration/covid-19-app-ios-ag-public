//
// Copyright © 2021 DHSC. All rights reserved.
//

import UIKit

public class DetailTableViewCell: UITableViewCell {
    static let reuseIdentifier = String(describing: DetailTableViewCell.self)

    private lazy var detailLabel = BaseLabel().styleAsSecondaryBody()
    private lazy var titleLabel = BaseLabel().styleAsBody()
    private let contentWrapperView = UIView()

    private var detail: InterfaceProperty<String?>? {
        didSet {
            detail?.sink { [weak self] in
                self?.detailLabel.text = $0
                self?.accessibilityValue = $0
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(.surface)

        contentWrapperView.addAutolayoutSubview(titleLabel)
        contentWrapperView.addAutolayoutSubview(detailLabel)
        contentView.addCellContentSubview(contentWrapperView, inset: .standardSpacing)

        // Layout based on text size
        if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
            stackVertically()
        } else {
            stackHorizontally()
        }

        titleLabel.setContentCompressionResistancePriority(.almostRequest, for: .horizontal)
    }

    public func setContent(with label: String, and value: InterfaceProperty<String?>) -> Self {
        titleLabel.text = label
        accessibilityLabel = label
        detail = value
        return self
    }

    private func stackVertically() {
        detailLabel.lineBreakMode = .byWordWrapping
        detailLabel.textAlignment = .leading
        detailLabel.numberOfLines = 0
        titleLabel.numberOfLines = 0

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentWrapperView.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentWrapperView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: detailLabel.topAnchor, constant: -.halfSpacing),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            detailLabel.bottomAnchor.constraint(equalTo: contentWrapperView.bottomAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: contentWrapperView.trailingAnchor),
            detailLabel.leadingAnchor.constraint(equalTo: contentWrapperView.leadingAnchor),
        ])

    }

    private func stackHorizontally() {
        detailLabel.lineBreakMode = .byTruncatingMiddle
        detailLabel.textAlignment = .trailing
        detailLabel.numberOfLines = 1
        titleLabel.numberOfLines = 1

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentWrapperView.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentWrapperView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentWrapperView.bottomAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: detailLabel.leadingAnchor, constant: -.halfSpacing),

            detailLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: contentWrapperView.trailingAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DetailTableViewCell {
    public static func create(
        tableView: UITableView,
        label: String,
        value: InterfaceProperty<String?>,
        withAccessoryType: Bool = false
    ) -> DetailTableViewCell {
        let dequeued = tableView.dequeueReusableCell(
            withIdentifier: DetailTableViewCell.reuseIdentifier
        ) as? DetailTableViewCell ?? DetailTableViewCell()

        if withAccessoryType {
            dequeued.accessoryType = .disclosureIndicator
        }

        return dequeued.setContent(with: label, and: value)
    }
}
