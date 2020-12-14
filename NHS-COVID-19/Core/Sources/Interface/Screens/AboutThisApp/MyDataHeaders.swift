//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

extension MyDataViewController {
    class VenueHistorySectionHeader: UITableViewHeaderFooterView {
        static let reuseIdentifier = String(describing: self)
        
        private let label: UILabel
        private let button: UIButton
        
        private var action: (() -> Void)?
        private var isEditing: (InterfaceProperty<Bool>)? {
            didSet {
                isEditing?.sink { [weak self] isEditing in
                    let text = isEditing ? localize(.mydata_venue_history_done_button_title) : localize(.mydata_venue_history_edit_button_title)
                    self?.button.setTitle(text, for: .normal)
                }
            }
        }
        
        override init(reuseIdentifier: String?) {
            label = UILabel().styleAsSectionHeader()
            button = UIButton()
            
            super.init(reuseIdentifier: reuseIdentifier)
            
            button.styleAsPlain(with: UIColor(.nhsBlue))
            button.setTitle(localize(.mydata_venue_history_edit_button_title), for: .normal)
            button.addTarget(self, action: #selector(act))
            
            addAutolayoutSubview(label)
            addAutolayoutSubview(button)
            
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor, constant: .standardSpacing),
                button.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor, constant: -.standardSpacing),
                button.leadingAnchor.constraint(greaterThanOrEqualTo: label.trailingAnchor, constant: .standardSpacing),
                
                heightAnchor.constraint(greaterThanOrEqualTo: label.heightAnchor, constant: .standardSpacing).withPriority(.almostRequest),
                heightAnchor.constraint(greaterThanOrEqualTo: button.heightAnchor, constant: .standardSpacing).withPriority(.almostRequest),
                
                label.centerYAnchor.constraint(equalTo: centerYAnchor),
                button.centerYAnchor.constraint(equalTo: centerYAnchor),
                
            ])
        }
        
        private func setting(title: String, action: @escaping () -> Void, isEditing: InterfaceProperty<Bool>) -> Self {
            label.text = title
            self.isEditing = isEditing
            self.action = action
            return self
        }
        
        static func create(tableView: UITableView, title: String, action: @escaping () -> Void, isEditing: InterfaceProperty<Bool>) -> MyDataViewController.VenueHistorySectionHeader {
            let dequeued = tableView.dequeueReusableHeaderFooterView(withIdentifier: EditableSectionHeader.reuseIdentifier) as? VenueHistorySectionHeader
            let header = (dequeued ?? VenueHistorySectionHeader()).setting(title: title, action: action, isEditing: isEditing)
            
            header.button.accessibilityIdentifier = "venue_history_edit_button"
            #warning("This is a hack to account for two 'Edit' buttons with the same label. For accessibility it would be better for both buttons to have a different (accessibility) label")
            return header
        }
        
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        @objc private func act() {
            action?()
        }
    }
}

extension MyDataViewController {
    class EditableSectionHeader: UITableViewHeaderFooterView {
        static let reuseIdentifier = String(describing: self)
        
        private let label: UILabel
        private let button: UIButton
        
        private var action: (() -> Void)?
        
        override init(reuseIdentifier: String?) {
            label = UILabel().styleAsSectionHeader()
            button = UIButton()
            
            super.init(reuseIdentifier: reuseIdentifier)
            
            button.styleAsPlain(with: UIColor(.nhsBlue))
            button.setTitle(localize(.mydata_venue_history_edit_button_title), for: .normal)
            button.addTarget(self, action: #selector(act))
            
            addAutolayoutSubview(label)
            addAutolayoutSubview(button)
            
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor, constant: .standardSpacing),
                button.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor, constant: -.standardSpacing),
                button.leadingAnchor.constraint(greaterThanOrEqualTo: label.trailingAnchor, constant: .standardSpacing),
                
                heightAnchor.constraint(greaterThanOrEqualTo: label.heightAnchor, constant: .standardSpacing).withPriority(.almostRequest),
                heightAnchor.constraint(greaterThanOrEqualTo: button.heightAnchor, constant: .standardSpacing).withPriority(.almostRequest),
                
                label.centerYAnchor.constraint(equalTo: centerYAnchor),
                button.centerYAnchor.constraint(equalTo: centerYAnchor),
                
            ])
        }
        
        private func setting(title: String, action: @escaping () -> Void) -> Self {
            label.set(text: title)
            self.action = action
            return self
        }
        
        static func create(tableView: UITableView, title: String, action: @escaping () -> Void) -> MyDataViewController.EditableSectionHeader {
            let dequeued = tableView.dequeueReusableHeaderFooterView(withIdentifier: EditableSectionHeader.reuseIdentifier) as? EditableSectionHeader
            let header = (dequeued ?? EditableSectionHeader()).setting(title: title, action: action)
            
            header.button.accessibilityIdentifier = "postcode_or_local_authority_edit_button"
            #warning("This is a hack to account for two 'Edit' buttons with the same label. For accessibility it would be better for both buttons to have a different (accessibility) label")
            return header
        }
        
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        @objc private func act() {
            action?()
        }
    }
}

extension MyDataViewController {
    class SectionHeader: UITableViewHeaderFooterView {
        static let reuseIdentifier = String(describing: self)
        let label: UILabel
        
        override init(reuseIdentifier: String?) {
            label = UILabel().styleAsSectionHeader()
            
            super.init(reuseIdentifier: reuseIdentifier)
            
            addAutolayoutSubview(label)
            
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor, constant: .standardSpacing),
                label.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor, constant: -.standardSpacing),
                
                heightAnchor.constraint(greaterThanOrEqualTo: label.heightAnchor, constant: .standardSpacing).withPriority(.almostRequest),
                heightAnchor.constraint(greaterThanOrEqualToConstant: .buttonMinimumHeight + .standardSpacing).withPriority(.almostRequest),
                
                label.centerYAnchor.constraint(equalTo: centerYAnchor),
            ])
        }
        
        private func setting(title: String) -> Self {
            label.set(text: title)
            return self
        }
        
        static func create(tableView: UITableView, title: String) -> MyDataViewController.SectionHeader {
            let dequeued = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeader.reuseIdentifier) as? SectionHeader
            return (dequeued ?? SectionHeader()).setting(title: title)
        }
        
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }
}
