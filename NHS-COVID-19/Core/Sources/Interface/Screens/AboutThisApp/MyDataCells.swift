//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

extension MyDataViewController {
    class PostcodeCell: UITableViewCell {
        static let reuseIdentifier = String(describing: self)
        let postcodeLabel: UILabel
        let localAuthorityLabel: UILabel
        
        let stack: UIStackView = {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.alignment = .firstBaseline
            stack.distribution = .fillProportionally
            stack.spacing = .halfSpacing
            return stack
        }()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            postcodeLabel = BaseLabel().styleAsBody()
            localAuthorityLabel = BaseLabel().styleAsBody()
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            backgroundColor = UIColor(.surface)
            stack.addArrangedSubview(localAuthorityLabel)
            stack.addArrangedSubview(postcodeLabel)
            contentView.addCellContentSubview(stack, inset: .standardSpacing)
        }
        
        var postcode: (InterfaceProperty<String?>)? {
            didSet {
                postcode?.sink { [weak self] postcode in
                    self?.postcodeLabel.text = postcode
                }
            }
        }
        
        var localAuthority: (InterfaceProperty<String?>)? {
            didSet {
                localAuthority?.sink { [weak self] authority in
                    self?.localAuthorityLabel.text = authority
                }
            }
        }
        
        private func setting(postcode: InterfaceProperty<String?>, localAuthority: InterfaceProperty<String?>) -> PostcodeCell {
            self.postcode = postcode
            self.localAuthority = localAuthority
            return self
        }
        
        static func create(tableView: UITableView, postcode: InterfaceProperty<String?>, localAuthority: InterfaceProperty<String?>) -> PostcodeCell {
            let dequeued = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? PostcodeCell
            return (dequeued ?? PostcodeCell()).setting(postcode: postcode, localAuthority: localAuthority)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension MyDataViewController {
    class VenueHistoryCell: UITableViewCell {
        static let reuseIdentifier = String(describing: self)
        
        let titleLabel: UILabel
        let idLabel: UILabel
        let dateLabel: UILabel
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            titleLabel = BaseLabel().styleAsBody()
            idLabel = BaseLabel().styleAsSecondaryBody()
            dateLabel = BaseLabel().styleAsSecondaryBody()
            
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            backgroundColor = UIColor(.surface)
            
            contentView.addAutolayoutSubview(titleLabel)
            contentView.addAutolayoutSubview(dateLabel)
            contentView.addAutolayoutSubview(idLabel)
            
            idLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
            idLabel.setContentHuggingPriority(.required, for: .horizontal)
            
            let headerStack = UIStackView(arrangedSubviews: [titleLabel, idLabel])
            headerStack.axis = .horizontal
            headerStack.alignment = .firstBaseline
            headerStack.distribution = .fillProportionally
            headerStack.spacing = .standardSpacing
            
            let cellStack = UIStackView(arrangedSubviews: [headerStack, dateLabel])
            cellStack.axis = .vertical
            cellStack.spacing = .standardSpacing
            cellStack.layoutMargins = .standard
            cellStack.isLayoutMarginsRelativeArrangement = true
            
            contentView.addCellContentSubview(cellStack)
        }
        
        private func setting(venueHistory: VenueHistory) -> VenueHistoryCell {
            titleLabel.set(text: venueHistory.organisation)
            idLabel.set(text: venueHistory.id)
            dateLabel.set(text: localize(.mydata_date_interval_description(
                startdate: venueHistory.checkedIn,
                endDate: venueHistory.checkedOut
            )))
            return self
        }
        
        static func create(tableView: UITableView, venueHistory: VenueHistory) -> VenueHistoryCell {
            let dequeued = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? VenueHistoryCell
            return (dequeued ?? VenueHistoryCell()).setting(venueHistory: venueHistory)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension MyDataViewController {
    class DateCell: UITableViewCell {
        static let reuseIdentifier = String(describing: self)
        
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
            
            let headerStack = UIStackView(arrangedSubviews: [titleLabel, dateLabel])
            headerStack.axis = .horizontal
            headerStack.alignment = .firstBaseline
            headerStack.distribution = .fillProportionally
            headerStack.spacing = .standardSpacing
            headerStack.layoutMargins = .standard
            headerStack.isLayoutMarginsRelativeArrangement = true
            
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
        static let reuseIdentifier = String(describing: self)
        
        let titleLabel: UILabel
        let valueLabel: UILabel
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            titleLabel = BaseLabel().styleAsBody()
            valueLabel = BaseLabel().styleAsSecondaryBody()
            
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            backgroundColor = UIColor(.surface)
            
            contentView.addAutolayoutSubview(titleLabel)
            contentView.addAutolayoutSubview(valueLabel)
            
            valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
            valueLabel.setContentHuggingPriority(.required, for: .horizontal)
            
            let headerStack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
            headerStack.axis = .horizontal
            headerStack.alignment = .firstBaseline
            headerStack.distribution = .fillProportionally
            headerStack.spacing = .standardSpacing
            headerStack.layoutMargins = .standard
            headerStack.isLayoutMarginsRelativeArrangement = true
            
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
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
