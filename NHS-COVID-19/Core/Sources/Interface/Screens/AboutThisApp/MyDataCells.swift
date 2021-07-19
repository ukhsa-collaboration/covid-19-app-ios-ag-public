//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import UIKit

extension MyDataViewController {
    class TextCell: UITableViewCell {
        static let reuseIdentifier = String(describing: TextCell.self)
        
        let titleLabel: UILabel
        let valueLabel: UILabel
        let headerStack: UIStackView
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            titleLabel = BaseLabel().styleAsBody()
            valueLabel = BaseLabel().styleAsSecondaryBody()
            
            valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
            valueLabel.setContentHuggingPriority(.required, for: .horizontal)
            
            headerStack = UIStackView.horizontal(with: [titleLabel, valueLabel])
            
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            backgroundColor = UIColor(.surface)
            
            contentView.addCellContentSubview(headerStack)
        }
        
        private func setting(value: String, title: String) -> TextCell {
            valueLabel.set(text: value)
            titleLabel.set(text: title)
            return self
        }
        
        static func create(tableView: UITableView, title: String, value: String) -> TextCell {
            let dequeued = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? TextCell
            return (dequeued ?? TextCell()).setting(value: value, title: title)
        }
        
        private func setting(date: Date, title: String) -> Self {
            valueLabel.set(text: localize(.mydata_date_description(date: date)))
            titleLabel.set(text: title)
            return self
        }
        
        static func create(tableView: UITableView, title: String, date: Date) -> TextCell {
            let dequeued = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? TextCell
            return (dequeued ?? TextCell()).setting(date: date, title: title)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
                headerStack.axis = .vertical
                headerStack.distribution = .fill
            } else {
                headerStack.axis = .horizontal
                headerStack.distribution = .fillProportionally
            }
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
