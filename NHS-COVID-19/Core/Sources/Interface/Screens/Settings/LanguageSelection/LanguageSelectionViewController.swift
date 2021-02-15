//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol LanguageSelectionViewControllerInteracting {
    func didSelect(configuration: LocaleConfiguration)
}

public class LanguageSelectionViewController: UITableViewController {
    public struct ViewModel {
        let currentSelection: LocaleConfiguration
        let selectableDefault: SelectableLanguage
        let selectableOverrides: [SelectableLanguage]
        
        public init(currentSelection: LocaleConfiguration,
                    selectableDefault: SelectableLanguage,
                    selectableOverrides: [SelectableLanguage]) {
            self.currentSelection = currentSelection
            self.selectableDefault = selectableDefault
            self.selectableOverrides = selectableOverrides
        }
    }
    
    public typealias Interacting = LanguageSelectionViewControllerInteracting
    
    var interacting: Interacting
    var viewModel: ViewModel
    
    public init(viewModel: ViewModel,
                interacting: Interacting) {
        self.viewModel = viewModel
        self.interacting = interacting
        super.init(style: .grouped)
        
        title = localize(.settings_language_title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        view.styleAsScreenBackground(with: traitCollection)
        tableView.tableFooterView = UIView()
        
        tableView.register(LanguageSelectionCell.self, forCellReuseIdentifier: LanguageSelectionCell.reuseIdentifier)
        tableView.register(SectionHeader.self, forHeaderFooterViewReuseIdentifier: SectionHeader.reuseIdentifier)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func getLanguageFor(_ configuration: LocaleConfiguration) -> String {
        switch configuration {
        case .systemPreferred:
            return viewModel.selectableDefault.exonym
        case .custom(let localeIdentifier):
            if let exonym = SupportedLanguage.getLanguageTermsFrom(localeIdentifier: localeIdentifier)?.exonym {
                return exonym
            } else {
                return viewModel.selectableDefault.exonym
            }
        }
    }
    
    private func showConfirmAlertFor(_ configuration: LocaleConfiguration) {
        let language = getLanguageFor(configuration)
        let alertController = UIAlertController(
            title: "",
            message: localize(.settings_language_confirm_selection_alert_description(selectedLanguage: language)),
            preferredStyle: .alert
        )
        
        let noAction = UIAlertAction(title: localize(.settings_language_confirm_selection_alert_no), style: .cancel)
        alertController.addAction(noAction)
        
        let yesAction = UIAlertAction(title: localize(.settings_language_confirm_selection_alert_yes), style: .default, handler: { [weak self] _ in
            self?.didConfirmLanguageSelection(configuration: configuration)
        })
        alertController.addAction(yesAction)
        
        alertController.preferredAction = yesAction
        present(alertController, animated: true)
    }
    
    #warning("See if we can find a better way of passing this snapshot around")
    static var snapshotBeforeChangingLanguage: UIView?
    
    private func didConfirmLanguageSelection(configuration: LocaleConfiguration) {
        Self.snapshotBeforeChangingLanguage = view.window?.snapshotView(afterScreenUpdates: false)
        interacting.didSelect(configuration: configuration)
    }
    
    override public func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        switch viewModel.currentSelection {
        case .systemPreferred:
            if indexPath.section == 0 {
                return LanguageSelectionCell.create(tableView: tableView, language: viewModel.selectableDefault, selected: true)
            } else {
                return LanguageSelectionCell.create(tableView: tableView, language: viewModel.selectableOverrides[indexPath.row], selected: false)
            }
        case .custom(let localeIdentifier):
            if indexPath.section == 0 {
                return LanguageSelectionCell.create(tableView: tableView, language: viewModel.selectableDefault, selected: false)
            } else {
                let rowLanguage = viewModel.selectableOverrides[indexPath.row]
                let selected = rowLanguage.isoCode == localeIdentifier
                return LanguageSelectionCell.create(tableView: tableView, language: rowLanguage, selected: selected)
            }
        }
        
    }
    
    override public func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        switch section {
        case 0: // Default (system) language
            return 1
        case 1: // Selectable languages
            return viewModel.selectableOverrides.count
        default:
            return 0
        }
    }
    
    override public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return SectionHeader.create(tableView: tableView, title: localize(.settings_language_system_language))
        case 1:
            return SectionHeader.create(tableView: tableView, title: localize(.settings_language_override_languages))
        default:
            return SectionHeader.create(tableView: tableView, title: "")
        }
        
    }
    
    override public func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            showConfirmAlertFor(.systemPreferred)
        case 1:
            showConfirmAlertFor(.custom(localeIdentifier: viewModel.selectableOverrides[indexPath.row].isoCode))
        default:
            break
        }
    }
}

extension LanguageSelectionViewController {
    class SectionHeader: UITableViewHeaderFooterView {
        static let reuseIdentifier = String(describing: SectionHeader.self)
        let label: UILabel
        
        override init(reuseIdentifier: String?) {
            label = BaseLabel().styleAsSectionHeader()
            
            super.init(reuseIdentifier: reuseIdentifier)
            
            addAutolayoutSubview(label)
            
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor, constant: .halfSpacing),
                label.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor, constant: -.halfSpacing),
                
                heightAnchor.constraint(greaterThanOrEqualToConstant: .buttonMinimumHeight).withPriority(.almostRequest),
                
                label.centerYAnchor.constraint(equalTo: centerYAnchor),
            ])
        }
        
        private func setting(title: String) -> Self {
            label.set(text: title)
            return self
        }
        
        static func create(tableView: UITableView, title: String) -> LanguageSelectionViewController.SectionHeader {
            let dequeued = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeader.reuseIdentifier) as? SectionHeader
            return (dequeued ?? SectionHeader()).setting(title: title)
        }
        
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }
    
    class LanguageSelectionCell: UITableViewCell {
        static let reuseIdentifier = String(describing: LanguageSelectionCell.self)
        
        let endonymLabel: UILabel
        let exonymLabel: UILabel
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            endonymLabel = BaseLabel().styleAsBody()
            exonymLabel = BaseLabel().styleAsCaption()
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            selectionStyle = .none
            
            contentView.addAutolayoutSubview(endonymLabel)
            contentView.addAutolayoutSubview(exonymLabel)
            
            let stack = UIStackView(arrangedSubviews: [endonymLabel, exonymLabel])
            stack.axis = .vertical
            stack.layoutMargins = UIEdgeInsets(top: .halfSpacing, left: .halfSpacing, bottom: .halfSpacing, right: .halfSpacing)
            stack.isLayoutMarginsRelativeArrangement = true
            
            contentView.addCellContentSubview(stack)
        }
        
        var language: SelectableLanguage? {
            didSet {
                guard let newValue = language else {
                    return
                }
                endonymLabel.attributedText = NSAttributedString(
                    string: newValue.endonym,
                    attributes: [.accessibilitySpeechLanguage: language?.isoCode ?? "en"]
                )
                
                exonymLabel.text = newValue.exonym
            }
        }
        
        private func setting(language: SelectableLanguage) -> LanguageSelectionCell {
            self.language = language
            return self
        }
        
        static func create(tableView: UITableView, language: SelectableLanguage, selected: Bool) -> LanguageSelectionCell {
            let dequeued = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? LanguageSelectionCell
            
            if selected {
                dequeued?.accessoryType = .checkmark
            } else {
                dequeued?.accessoryType = .none
            }
            
            return (dequeued ?? LanguageSelectionCell()).setting(language: language)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
}
