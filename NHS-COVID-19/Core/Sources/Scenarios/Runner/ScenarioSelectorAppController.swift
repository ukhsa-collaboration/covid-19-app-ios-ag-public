//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Domain
import Integration
import SwiftUI

class ScenarioSelectorAppController: AppController {
    
    let rootViewController: UIViewController
    
    init(openDebug: @escaping () -> Void, select: @escaping (ScenarioId) -> Void) {
        
        let navigationController = UINavigationController()
        rootViewController = navigationController
        
        let sections = ScenarioKind.allCases
            .map { ListSection(scenariosOfKind: $0, select: select, showInfo: { [weak self] info in self?.showInfo(info) }) }
            .filter { !$0.rows.isEmpty }
        
        let listViewController = ScenarioSelectorViewController(title: "Scenarios", sections: sections)
        listViewController._openDebug = openDebug
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.pushViewController(listViewController, animated: false)
    }
    
    private func showInfo(_ info: ScenarioInfo) {
        rootViewController.showAlert(title: info.name, message: info.description, preferredStyle: .actionSheet)
    }
    
}

class ScenarioSelectorViewController: SearchableListViewController {
    
    var _openDebug: () -> Void = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Debug",
            style: .plain,
            target: self,
            action: #selector(openDebug)
        )
    }
    
    @objc private func openDebug() {
        _openDebug()
    }
}

private extension ListSection {
    
    init(scenariosOfKind kind: ScenarioKind, select: @escaping (ScenarioId) -> Void, showInfo: @escaping (ScenarioInfo) -> Void) {
        let rows = ScenarioId.allCases.lazy
            .filter { $0.scenarioType.kind == kind }
            .sorted { $0.scenarioType.nameForSorting < $1.scenarioType.nameForSorting }
            .map { id -> ListRow in
                let infoAction: (() -> Void)? = id.scenarioType.info.map { info in
                    { showInfo(info) }
                }
                return ListRow(title: id.scenarioType.name, infoAction: infoAction) { select(id) }
            }
        self.init(title: kind.name, rows: rows)
    }
    
}
