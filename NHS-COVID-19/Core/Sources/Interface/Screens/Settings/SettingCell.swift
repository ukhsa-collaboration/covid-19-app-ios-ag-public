//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import Localization
import UIKit

extension SettingsViewController {
    class LanguageCell: UITableViewCell {
        static let reuseIdentifier = String(describing: LanguageCell.self)
        let languageLabel: UILabel
        let selectedLanguageLabel: UILabel
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            languageLabel = BaseLabel().styleAsBody()
            languageLabel.text = localize(.settings_row_language)
            selectedLanguageLabel = BaseLabel().styleAsSecondaryBody()
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            accessibilityLabel = localize(.settings_row_language)
            backgroundColor = UIColor(.surface)
            
            contentView.addAutolayoutSubview(languageLabel)
            contentView.addAutolayoutSubview(selectedLanguageLabel)
            
            selectedLanguageLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
            selectedLanguageLabel.setContentHuggingPriority(.required, for: .horizontal)
            
            let headerStack = UIStackView(arrangedSubviews: [languageLabel, selectedLanguageLabel])
            headerStack.axis = .horizontal
            headerStack.alignment = .firstBaseline
            headerStack.distribution = .fillProportionally
            headerStack.spacing = .standardSpacing
            headerStack.layoutMargins = .standard
            headerStack.isLayoutMarginsRelativeArrangement = true
            
            contentView.addCellContentSubview(headerStack)
        }
        
        var language: (InterfaceProperty<String>)? {
            didSet {
                language?.sink { [weak self] value in
                    self?.selectedLanguageLabel.text = value
                    self?.accessibilityValue = value
                }
            }
        }
        
        private func setting(language: InterfaceProperty<String>) -> LanguageCell {
            self.language = language
            return self
        }
        
        static func create(tableView: UITableView, language: InterfaceProperty<String>) -> LanguageCell {
            let dequeued = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? LanguageCell ?? LanguageCell()
            dequeued.accessoryType = .disclosureIndicator
            return dequeued.setting(language: language)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class TextCell: UITableViewCell {
        static let reuseIdentifier = String(describing: TextCell.self)
        let titleLabel: UILabel
        let subtitleLabel: UILabel
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            titleLabel = BaseLabel().styleAsBody()
            subtitleLabel = BaseLabel().styleAsSecondaryBody()
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            backgroundColor = UIColor(.surface)
            
            contentView.addAutolayoutSubview(titleLabel)
            contentView.addAutolayoutSubview(subtitleLabel)
            
            let stackView = UIStackView.vertical(with: [titleLabel, subtitleLabel])
            contentView.addCellContentSubview(stackView)
        }
        
        private func setting(title: String, subtitle: String) -> TextCell {
            titleLabel.set(text: title)
            subtitleLabel.set(text: subtitle)
            return self
        }
        
        static func create(tableView: UITableView, title: String, subtitle: String) -> TextCell {
            let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? TextCell ?? TextCell()
            dequeuedCell.accessoryType = .disclosureIndicator
            return dequeuedCell.setting(title: title, subtitle: subtitle)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
