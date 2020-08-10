//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Domain
import Interface
import UIKit

public class CoordinatedAppController: AppController {
    
    #warning("Make private when possible")
    // After all of the extension in `Integration` is dissolved, we can make this property private.
    let coordinator: ApplicationCoordinator
    private var cancellable: AnyCancellable?
    
    public var rootViewController = UIViewController()
    
    private var content: UIViewController? {
        didSet {
            oldValue?.remove()
            if let content = content {
                rootViewController.addFilling(content)
                UIAccessibility.post(notification: .screenChanged, argument: nil)
            }
        }
    }
    
    fileprivate init(coordinator: ApplicationCoordinator) {
        self.coordinator = coordinator
        
        cancellable = coordinator.$state
            .regulate(as: .modelChange)
            .sink { [weak self] state in
                self?.update(for: state)
            }
        
        setupUI()
    }
    
    public func performBackgroundTask(task: BackgroundTask) {
        coordinator.performBackgroundTask(task: task)
    }
    
    private func update(for state: ApplicationState) {
        content = makeContent(for: state)
    }
    
    private func setupUI() {
        let appearance = UINavigationBar.appearance()
        appearance.tintColor = UIColor(.lightSurface)
        appearance.barTintColor = UIColor(.navigationBar)
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(.lightSurface)]
        appearance.shadowImage = UIImage()
        appearance.isTranslucent = false
    }
    
}

extension CoordinatedAppController {
    
    /// Convenience initialiser; primarily to be used internally with modified services
    public convenience init(services: ApplicationServices, enabledFeatures: [Feature]) {
        let coordinator = ApplicationCoordinator(services: services, enabledFeatures: enabledFeatures)
        self.init(coordinator: coordinator)
    }
    
    /// Convenience initialiser used by the main app
    /// - Parameters:
    ///   - environment: Defaults to standard production environment.
    ///   - enabledFeatures: Defaults to all features.
    public convenience init(environment: Environment = .standard(), enabledFeatures: [Feature] = Feature.allCases) {
        let services = ApplicationServices(standardServicesFor: environment)
        self.init(services: services, enabledFeatures: enabledFeatures)
    }
    
}
