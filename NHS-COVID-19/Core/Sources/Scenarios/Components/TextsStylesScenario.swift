//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class TextStylesScenario: Scenario {
    public static let name = "Text Styles"
    public static let kind = ScenarioKind.component
    
    static var appController: AppController {
        let navigation = UINavigationController()
        navigation.pushViewController(TextStylesViewController(), animated: false)
        return BasicAppController(rootViewController: navigation)
    }
}

private class TextStylesViewController: UITableViewController {
    
    enum Styles: CaseIterable {
        case pageHeader
        case body
        case heading
        
        var name: String {
            switch self {
            case .pageHeader:
                return "Page Header"
            case .body:
                return "Body"
            case .heading:
                return "Heading"
            }
        }
        
        func style(_ label: UILabel) {
            switch self {
            case .pageHeader:
                label.styleAsPageHeader()
            case .body:
                label.styleAsBody()
            case .heading:
                label.styleAsHeading()
            }
        }
    }
    
    let texts = ExampleText.allCases
    
    let reuseId = UUID().uuidString
    
    init() {
        super.init(style: .grouped)
        title = TextStylesScenario.name
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseId)
        tableView.allowsSelection = false
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        Styles.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        texts.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        Styles.allCases[section].name
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath)
        Styles.allCases[indexPath.section].style(cell.textLabel!)
        cell.textLabel?.text = texts[indexPath.row].rawValue
        
        // Set this, so we can verify the label’s accessibility traits, etc.
        cell.accessibilityElements = [cell.textLabel!]
        
        return cell
    }
    
}
