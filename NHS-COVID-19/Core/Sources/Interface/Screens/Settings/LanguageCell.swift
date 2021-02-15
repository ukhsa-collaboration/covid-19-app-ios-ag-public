//
// Copyright © 2020 NHSX. All rights reserved.
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
}
