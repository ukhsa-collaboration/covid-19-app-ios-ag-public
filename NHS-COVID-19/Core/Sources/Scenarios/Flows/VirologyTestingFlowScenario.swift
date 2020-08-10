//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Domain
import Integration
import Interface
import UIKit

public class VirologyTestingFlowScenario: Scenario {
    
    public static var name = "Virology Testing"
    public static var kind = ScenarioKind.flow
    
    static var appController: AppController {
        Controller()
    }
    
    private class Controller: AppController {
        
        let rootViewController = UIViewController()
        
        init() {
            let flow = VirologyTestingFlowViewController(VirologyTestingInteractor(viewController: rootViewController))
            rootViewController.addFilling(flow)
        }
    }
}

private struct VirologyTestingInteractor: VirologyTestingFlowViewController.Interacting {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func fetchVirologyTestingInfo() -> AnyPublisher<InterfaceVirologyTestingInfo, NetworkRequestError> {
        Future<InterfaceVirologyTestingInfo, NetworkRequestError>({ promise in
            promise(.success(
                InterfaceVirologyTestingInfo(referenceCode: "RFNC-CDE")
            ))
//             promise(.failure(URLError(.badServerResponse)))
        }).eraseToAnyPublisher()
    }
    
    func didTapCopyReferenceCode() {
        viewController?.showAlert(title: "Did tap copy reference code")
    }
    
    func didTapOrderTestLink() {
        viewController?.showAlert(title: "Did tap order test link")
    }
}
