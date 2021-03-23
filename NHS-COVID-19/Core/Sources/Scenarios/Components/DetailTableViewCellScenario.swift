//
// Copyright © 2021 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

public class DetailTableViewCellScenario: Scenario {
    
    static var appController: AppController {
        let navigation = UINavigationController()
        navigation.pushViewController(DetailTableViewController(), animated: false)
        return BasicAppController(rootViewController: navigation)
    }
    
    public static var name = "DetailTableViewCell"
    public static var kind = ScenarioKind.component
    
    enum Showcases: CaseIterable {
        case veryShortShort
        case veryShortVeryShort
        case veryShortNormal
        case shortVeryShort
        case shortShort
        case shortNormal
        case normalVeryShort
        case normalShort
        case normalNormal
        case longNormal
        
        func content() -> (label: String, value: String) {
            switch self {
            case .shortShort:
                return (ExampleText.short.rawValue, ExampleText.short.rawValue)
            case .normalNormal:
                return (ExampleText.normal.rawValue, ExampleText.normal.rawValue)
            case .veryShortShort:
                return (ExampleText.veryShort.rawValue, ExampleText.short.rawValue)
            case .veryShortVeryShort:
                return (ExampleText.veryShort.rawValue, ExampleText.veryShort.rawValue)
            case .veryShortNormal:
                return (ExampleText.veryShort.rawValue, ExampleText.normal.rawValue)
            case .shortVeryShort:
                return (ExampleText.short.rawValue, ExampleText.veryShort.rawValue)
            case .shortNormal:
                return (ExampleText.short.rawValue, ExampleText.normal.rawValue)
            case .normalVeryShort:
                return (ExampleText.normal.rawValue, ExampleText.veryShort.rawValue)
            case .normalShort:
                return (ExampleText.normal.rawValue, ExampleText.short.rawValue)
            case .longNormal:
                return (ExampleText.long.rawValue, ExampleText.normal.rawValue)
            }
        }
    }
}

private class DetailTableViewController: UITableViewController {
    let rows = DetailTableViewCellScenario.Showcases.allCases.map { $0.content() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.styleAsScreenBackground(with: traitCollection)
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        DetailTableViewCell.create(
            tableView: tableView,
            label: rows[indexPath.row].label,
            value: .constant(rows[indexPath.row].value),
            withAccessoryType: false
        )
    }
}
