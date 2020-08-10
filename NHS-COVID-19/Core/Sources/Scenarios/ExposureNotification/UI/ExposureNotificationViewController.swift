//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Interface
import UIKit

class ExposureNotificationViewController: UITableViewController {
    
    private let cellReuseId = UUID().uuidString
    
    struct Row {
        var title: String
        var value: String
        var action: (() -> Void)?
    }
    
    private struct Section {
        var title: String
        var rows: [Row]
    }
    
    private let manager: ExposureManager
    private let device = DeviceManager.shared
    private var cancellables = [AnyCancellable]()
    
    private var sections = [Section]() {
        didSet {
            if isViewLoaded {
                tableView?.reloadData()
            }
        }
    }
    
    init(manager: ExposureManager) {
        self.manager = manager
        super.init(style: .grouped)
        title = "Exposure Notification"
        
        let cancellable = manager.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.reloadData()
            }
        cancellables.append(cancellable)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(InfoTableViewCell.self, forCellReuseIdentifier: cellReuseId)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].rows.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseId, for: indexPath)
        let row = self.row(at: indexPath)
        cell.textLabel?.text = row.title
        cell.detailTextLabel?.text = row.value
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard row(at: indexPath).action != nil else { return nil }
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        row(at: indexPath).action?()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func row(at indexPath: IndexPath) -> Row {
        sections[indexPath.section].rows[indexPath.row]
    }
    
    func reloadData() {
        sections = [
            stateSection,
            infoSection,
            actionsSection,
        ]
    }
    
    private var stateSection: Section {
        Section(title: "State", rows: [
            Row(title: "Activation", value: manager.activationState.title, action: nil),
            Row(title: "Authorization", value: manager.authorizationState.title, action: nil),
            Row(title: "Enabled", value: manager.isEnabled ? "Yes ✅" : "No", action: nil),
            Row(title: "Configured for experiment", value: device.isConfigured ? "Yes ✅" : "No", action: nil),
        ])
    }
    
    private var infoSection: Section {
        let update = { (name: String, path: ReferenceWritableKeyPath<DeviceManager, String>) in
            let alert = UIAlertController(title: "Set \(name)", message: nil, preferredStyle: .alert)
            var textField: UITextField?
            alert.addTextField {
                $0.text = self.device[keyPath: path]
                textField?.autocapitalizationType = .words
                textField = $0
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
                self.device[keyPath: path] = textField!.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                self.reloadData()
            }))
            self.present(alert, animated: true, completion: nil)
        }
        return Section(title: "Info", rows: [
            Row(title: "App Version", value: Bundle.main.infoDictionary!["CFBundleVersion"] as! String, action: nil),
            Row(title: "Device", value: device.deviceName, action: { update("Device Name", \.deviceName) }),
            Row(title: "Experiment", value: device.experimentName, action: { update("Experiment Name", \.experimentName) }),
        ])
    }
    
    private var actionsSection: Section {
        Section(title: "", rows: actionsSectionRows)
    }
    
    // TODO: Fix this.
    // Memory ownership hack: this object (e.g. `LocalExperimentActions`) may own resources.
    private var actions: Any!
    
    private var actionsSectionRows: [Row] {
        switch manager.authorizationState {
        case .notDetermined(let enable):
            return [
                Row(title: "Enable", value: "", action: enable),
            ]
        case .notAuthorized(isRestricted: true):
            return []
        case .notAuthorized(isRestricted: false):
            let openSettings = {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            return [
                Row(title: "Open Settings", value: "", action: openSettings),
            ]
        case .authorized(let manager):
            let actions = LocalExperimentActions(manager: manager, device: device, host: self)
            return actions.rows
        }
    }
    
}

private class InfoTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ExposureManager.ActivationState {
    
    var title: String {
        switch self {
        case .activating:
            return "Activating"
        case .activated:
            return "Activated ✅"
        case .activationFailed:
            return "Activation Failed"
        }
    }
    
}

private extension ExposureManager.AuthorizationState {
    
    var title: String {
        switch self {
        case .notDetermined:
            return "Not Determined"
        case .notAuthorized(isRestricted: true):
            return "Restricted"
        case .notAuthorized(isRestricted: false):
            return "Denied"
        case .authorized:
            return "Authorized ✅"
        }
    }
    
}
