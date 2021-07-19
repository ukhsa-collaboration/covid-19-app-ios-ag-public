//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Integration
import SwiftUI
import UIKit

public class Runner {
    
    public static let activeScenarioDefaultKey = "activeScenario"
    public static let devViewDefaultKey = "devView"
    public static let interfaceStyleDefaultKey = "interfaceStyle"
    public static let disableAnimations = "disable_animations"
    public static let disableHardwareKeyboard = "disable_hardware_keyboard"
    
    private let loggingManager: LoggingManager
    private let appController = WrappingAppController()
    private var cancellables = [AnyCancellable]()
    
    @UserDefault(Runner.activeScenarioDefaultKey)
    private var activeScenarioId: ScenarioId? {
        didSet {
            updateContent()
        }
    }
    
    @UserDefault(Runner.devViewDefaultKey, defaultValue: false)
    private var showDevView: Bool? {
        didSet {
            updateContent()
        }
    }
    
    private lazy var shortcuts: [ApplicationShort] = [
        ApplicationShort(
            type: "resetActiveScenario",
            title: "Reset Scenario",
            systemImageName: "arrowtriangle.left.circle",
            action: { [weak self] in
                self?.activeScenarioId = nil
            }
        ),
        ApplicationShort(
            type: "openSettings",
            title: "Settings",
            systemImageName: "gear",
            action: {
                DispatchQueue.main.async {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
        ),
        ApplicationShort(
            type: "performBackgroundTasks",
            title: "Run Tasks",
            systemImageName: "arrow.2.circlepath",
            action: { [weak self] in
                DispatchQueue.main.async {
                    self?.performBackgroundTasks()
                }
            }
        ),
        ApplicationShort( // TODO: Register this only if we’re in the Mock Scenario
            type: "debug",
            title: "Debug",
            systemImageName: "doc.text.magnifyingglass",
            action: { [weak self] in
                DispatchQueue.main.async {
                    self?.showDebugUI()
                }
            }
        ),
    ]
    
    public init(loggingManager: LoggingManager) {
        self.loggingManager = loggingManager
        UIApplication.shared.shortcutItems = shortcuts.map { $0.item }
        updateContent()
    }
    
    public func prepare(_ window: UIWindow) {
        window.accessibilityLabel = "MainWindow"
        if
            let disableAnimations = Int(ProcessInfo.processInfo.environment[Self.disableAnimations] ?? ""),
            disableAnimations > 0 {
            UIView.setAnimationsEnabled(false)
            window.layer.speed = 2000
        }
        
        if
            let disableHardwareKeyboard = Int(ProcessInfo.processInfo.environment[Self.disableHardwareKeyboard] ?? ""),
            disableHardwareKeyboard > 0 {
            // From https://stackoverflow.com/a/57618331
            let setHardwareLayout = NSSelectorFromString("setHardwareLayout:")
            UITextInputMode.activeInputModes
                .filter { $0.responds(to: setHardwareLayout) }
                .forEach { $0.perform(setHardwareLayout, with: nil) }
        }
        
        if #available(iOS 13.0, *) {
            switch UserDefaults.standard.string(forKey: Self.interfaceStyleDefaultKey) {
            case "dark":
                window.overrideUserInterfaceStyle = .dark
            case "light":
                window.overrideUserInterfaceStyle = .light
            default:
                break
            }
        }
    }
    
    public func performAction(for shortcutItem: UIApplicationShortcutItem) -> Bool {
        for shortcut in shortcuts where shortcut.item.type == shortcutItem.type {
            shortcut.action()
            return true
        }
        return false
    }
    
    public func makeAppController() -> AppController {
        appController
    }
    
    private func updateContent() {
        if let activeScenarioId = activeScenarioId {
            appController.content = activeScenarioId.scenarioType.appController
            if showDevView ?? false {
                if activeScenarioId.scenarioType.kind == .environment {
                    if activeScenarioId.scenarioType.name == "Mock" {
                        (appController.rootViewController as! WrappingViewController)
                            .addDeveloperOptions { [weak self] in
                                self?.showDebugUI()
                            } onLongPress: { [weak self] in
                                self?.performBackgroundTasks()
                            }
                    }
                } else {
                    (appController.rootViewController as! WrappingViewController)
                        .addDeveloperOptions { [weak self] in
                            self?.activeScenarioId = nil
                        } onLongPress: {}
                }
            }
        } else {
            appController.content = ScenarioSelectorAppController(openDebug: { [weak self] in self?.showDebugUI(showFeatureGuard: true) }) { [weak self] id in
                self?.activeScenarioId = id
            }
        }
    }
    
    private func performBackgroundTasks() {
        let viewController = appController.rootViewController
        
        let alert = UIAlertController(title: "Run background tasks", message: "When should the tasks start?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Immediately", style: .default) { _ in self.startTasks() })
        alert.addAction(UIAlertAction(title: "When app enters background", style: .default) { _ in self.startTasksWhenEnteringBackground() })
        alert.addAction(UIAlertAction(title: "Cancel", style: .default) { _ in })
        // Wait a bit before showing the alert so that the rootViewController is already loaded
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    private func startTasksWhenEnteringBackground() {
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification).first()
            .sink { [weak self] _ in
                self?.startTasks()
            }
            .store(in: &cancellables)
    }
    
    private func startTasks() {
        let task = MockBackgroundTask()
        let identifier = UIApplication.shared.beginBackgroundTask(withName: "ScenarioTriggeredTask") {
            task.expirationHandler?()
        }
        task.taskCompletion = { _ in
            UIApplication.shared.endBackgroundTask(identifier)
        }
        appController.performBackgroundTask(task: task)
    }
    
    private func showDebugUI(showFeatureGuard: Bool = false) {
        let tabBar = UITabBarController()
        let mocks = UIHostingController(
            rootView: ConfigureMocksView(
                dataProvider: MockScenario.mockDataProvider,
                lokaliseState: LokaliseState(dataProvider: MockScenario.mockDataProvider),
                showDevView: Binding(
                    get: { [weak self] in self?.showDevView ?? false },
                    set: { [weak self] value in self?.showDevView = value }
                ),
                adjustableDateProvider: AdjustableDateProvider()
            )
        )
        mocks.title = "Mocks"
        mocks.tabBarItem.image = UIImage(systemName: "doc.text")
        
        var viewControllers = [
            mocks,
            UINavigationController(rootViewController: LogsViewController(loggingManager: loggingManager)),
            UINavigationController(rootViewController: FilesViewController()),
        ]
        
        if showFeatureGuard {
            viewControllers.append(UINavigationController(rootViewController: ConfigurationViewController()))
        }
        
        tabBar.setViewControllers(viewControllers, animated: false)
        appController.rootViewController.present(tabBar, animated: true, completion: nil)
    }
}
