//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Integration
import Interface
import SwiftUI

public class RadioButtonGroupScenario: Scenario {
    
    public static let name = "Radio Button Group "
    public static let kind = ScenarioKind.component
    
    static var appController: AppController {
        let navigation = UINavigationController()
        navigation.pushViewController(RadioButtonGroupViewController(), animated: false)
        return BasicAppController(rootViewController: navigation)
    }
}

private class RadioButtonGroupViewController: UIViewController {
    private typealias Scenario = RadioButtonGroupScenario
    private var subscriptions = [AnyCancellable]()
    private var hostingVC: UIHostingController<RadioButtonGroup>!
    private var yesRadioButtonID: UUID?
    
    override func viewDidLoad() {
        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)
        
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(title: "Select YES", style: .plain, target: self, action: #selector(selectYesButton)),
        ]
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Reset selection", style: .done, target: self, action: #selector(resetSelection)),
            
        ]
        
        let buttonsViewModels = [
            RadioButtonGroup.ButtonViewModel(title: "Yes", accessibilityText: "Yes, I have", action: { print("Func to execute for Yes button") }),
            RadioButtonGroup.ButtonViewModel(title: "No", accessibilityText: "No, I haven't", action: { print("Func to execute for No button") }),
        ]
        yesRadioButtonID = buttonsViewModels.first?.id
        
        let radioButtonGroup = RadioButtonGroup(buttonViewModels: buttonsViewModels)
        
        let hostingVC = UIHostingController(rootView: radioButtonGroup)
        hostingVC.view.backgroundColor = UIColor(.background)
        self.hostingVC = hostingVC
        view.addAutolayoutSubview(hostingVC.view)
        
        NSLayoutConstraint.activate([
            hostingVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .standardSpacing),
            hostingVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: .standardSpacing),
            hostingVC.view.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: .standardSpacing),
        ])
    }
    
    @objc private func resetSelection() {
        hostingVC.rootView.state.selectedID = nil
    }
    
    @objc private func selectYesButton() {
        hostingVC.rootView.state.selectedID = yesRadioButtonID
    }
}
