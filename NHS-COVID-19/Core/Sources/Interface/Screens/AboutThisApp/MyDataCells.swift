//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import UIKit

extension MyDataViewController {
    class DateCell: UITableViewCell {
        static let reuseIdentifier = String(describing: DateCell.self)
        
        let titleLabel: UILabel
        let dateLabel: UILabel
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            titleLabel = BaseLabel().styleAsBody()
            dateLabel = BaseLabel().styleAsSecondaryBody()
            
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            backgroundColor = UIColor(.surface)
            
            contentView.addAutolayoutSubview(titleLabel)
            contentView.addAutolayoutSubview(dateLabel)
            
            dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
            dateLabel.setContentHuggingPriority(.required, for: .horizontal)
            
            let headerStack = UIStackView.horizontal(with: [titleLabel, dateLabel])
            contentView.addCellContentSubview(headerStack)
        }
        
        private func setting(date: Date, title: String) -> DateCell {
            dateLabel.set(text: localize(.mydata_date_description(date: date)))
            titleLabel.set(text: title)
            return self
        }
        
        static func create(tableView: UITableView, title: String, date: Date) -> DateCell {
            let dequeued = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? DateCell
            return (dequeued ?? DateCell()).setting(date: date, title: title)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension MyDataViewController {
    class TextCell: UITableViewCell {
        static let reuseIdentifier = String(describing: TextCell.self)
        
        let titleLabel: UILabel
        let valueLabel: UILabel
        let subtitleLabel: UILabel
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            titleLabel = BaseLabel().styleAsBody()
            valueLabel = BaseLabel().styleAsSecondaryBody()
            subtitleLabel = BaseLabel().styleAsSecondaryBody()
            
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            backgroundColor = UIColor(.surface)
            
            contentView.addAutolayoutSubview(titleLabel)
            contentView.addAutolayoutSubview(valueLabel)
            contentView.addAutolayoutSubview(subtitleLabel)
            
            valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
            valueLabel.setContentHuggingPriority(.required, for: .horizontal)
        }
        
        private func setting(value: String, title: String, subtitle: String? = nil) -> TextCell {
            valueLabel.set(text: value)
            titleLabel.set(text: title)
            if let subtitle = subtitle {
                subtitleLabel.set(text: subtitle)
                let titleStack = UIStackView.horizontal(with: [titleLabel, valueLabel], layoutMargins: .none)
                let contentStack = UIStackView.vertical(with: [titleStack, subtitleLabel])
                contentView.addCellContentSubview(contentStack)
            } else {
                subtitleLabel.isHidden = true
                let headerStack = UIStackView.horizontal(with: [titleLabel, valueLabel])
                contentView.addCellContentSubview(headerStack)
            }
            return self
        }
        
        static func create(tableView: UITableView, title: String, value: String, subtitle: String? = nil) -> TextCell {
            let dequeued = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? TextCell
            return (dequeued ?? TextCell()).setting(value: value, title: title, subtitle: subtitle)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension UIStackView {
    static func horizontal(with views: [UIView], layoutMargins: UIEdgeInsets = .standard, distribution: UIStackView.Distribution = .fillProportionally) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .horizontal
        stack.alignment = .firstBaseline
        stack.distribution = distribution
        stack.spacing = .standardSpacing
        stack.layoutMargins = layoutMargins
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }
    
    static func vertical(with views: [UIView], layoutMargins: UIEdgeInsets = .standard) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .vertical
        stack.spacing = .halfSpacing
        stack.layoutMargins = layoutMargins
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }
}
