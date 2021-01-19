//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation
@_exported import Localization
@_exported import Scenarios
import SwiftUI
@_exported import TestSupport
import XCTest

struct ApplicationRunner<Scenario: TestScenario>: TestProp {
    struct Configuration: TestPropConfiguration {
        var disableAnimations = true
        let initialState = Sandbox.InitialState()
        fileprivate var useCase: UseCase?
        mutating func report(scenario: String = Scenario.name, _ name: String, _ description: () -> String = { "" }) {
            useCase = UseCase(
                kind: Scenario.kind.serializedName,
                scenario: scenario,
                name: name,
                description: description()
            )
        }
    }
    
    private var configuration: Configuration
    private var useCaseBuilder: UseCaseBuilder?
    private var testBundle = Bundle.main
    
    mutating func prepare(for test: XCTestCase) {
        testBundle = Bundle(for: type(of: test))
        test.continueAfterFailure = false
    }
    
    init(configuration: Configuration) {
        self.configuration = configuration
        if let useCase = configuration.useCase, ProcessInfo().testMode == .report || ProcessInfo().testMode == .languages {
            useCaseBuilder = UseCaseBuilder(useCase: useCase)
        }
    }
    
    var scenario: Scenario.Type {
        Scenario.self
    }
    
    var isGeneratingReport: Bool {
        useCaseBuilder != nil
    }
    
    @_transparent
    func run(file: StaticString = #file, line: UInt = #line, work: (XCUIApplication) throws -> Void) throws {
        // We use @_transparent on these types. This way, any error thrown by the guts of the application runner shows
        // up on the line that calls `run`; but we preserve line information of errors thrown by `work`.
        try _run(file: file, line: line, work: work)
    }
    
    @_transparent
    func step(_ name: String, _ description: () -> String = { "" }) {
        useCaseBuilder?.step(name: name, description: description)
    }
    
    @_transparent
    private func _run(file: StaticString, line: UInt, work: (XCUIApplication) throws -> Void) throws {
        switch ProcessInfo().testMode {
        case .standard:
            try runOnce(work: work)
        case .report:
            #if targetEnvironment(simulator)
            guard let useCaseBuilder = useCaseBuilder else {
                throw XCTSkip("Not a report use-case.", file: file, line: line)
            }
            
            let reportCollector = try ReportCollector.shared()
            
            let initialConfiguration = DeviceConfiguration(from: .shared)
            
            try DeviceConfiguration.reportConfigurationsSparse.forEach { deviceConfiguration in
                try runOnce(deviceConfiguration: deviceConfiguration, work: work)
                
                // Save screenshots after each run to avoid keeping it all in memory.
                try reportCollector.appendScreenshots(useCaseBuilder.screenshots, for: useCaseBuilder.useCase)
                useCaseBuilder.clearScreenshots()
            }
            
            initialConfiguration.configure(.shared)
            
            try reportCollector.saveManifest(for: useCaseBuilder.useCase)
            #else
            throw XCTSkip("Reporting is only supported on the simulator.")
            #endif
        case .languages:
            #warning("Replace this with logic to check if test is needed for the languages test")
            guard useCaseBuilder != nil else {
                throw XCTSkip("Not a report use-case.", file: file, line: line)
            }
            
            let initialConfiguration = DeviceConfiguration(from: .shared)
            
            try DeviceConfiguration.testConfigurationLanguages.forEach { deviceConfiguration in
                try runOnce(deviceConfiguration: deviceConfiguration, work: work)
            }
            
            initialConfiguration.configure(.shared)
        }
    }
    
    private func runOnce(deviceConfiguration: DeviceConfiguration? = nil, work: (XCUIApplication) throws -> Void) throws {
        if let deviceConfiguration = deviceConfiguration {
            deviceConfiguration.configure(.shared)
        }
        let app = XCUIApplication()
        app.launchEnvironment[Runner.disableAnimations] = configuration.disableAnimations ? "1" : "0"
        app.launchEnvironment[Runner.disableHardwareKeyboard] = "1"
        app.launchArguments = ["-\(Runner.activeScenarioDefaultKey)", Scenario.id] + configuration.initialState.launchArguments
        
        testBundle.becomeCurrentForTesting()
        
        if let deviceConfiguration = deviceConfiguration {
            app.launchArguments += [
                "-UIPreferredContentSizeCategoryName", deviceConfiguration.contentSize.rawValue,
                "-\(Runner.interfaceStyleDefaultKey)", deviceConfiguration.interfaceStyle.rawValue,
                "-AppleLanguages", "(\(deviceConfiguration.language))",
            ]
            
            let localeConfiguration = LocaleConfiguration.custom(localeIdentifier: deviceConfiguration.language)
            localeConfiguration.becomeCurrent()
        }
        
        app.launch()
        useCaseBuilder?.app = app
        useCaseBuilder?.deviceConfiguration = deviceConfiguration
        defer {
            LocaleConfiguration.systemPreferred.becomeCurrent()
            useCaseBuilder?.app = nil
            useCaseBuilder?.deviceConfiguration = nil
        }
        
        try work(app)
    }
    
}

extension ApplicationRunner where Scenario: UITestInspectable {
    
    func inspect(work: (UIViewController) throws -> Void) rethrows {
        testBundle.becomeCurrentForTesting()
        try work(Scenario.viewControllerForInspecting)
    }
    
}

private extension ProcessInfo {
    
    enum TestMode: String {
        case standard
        case report
        case languages
    }
    
    var testMode: TestMode {
        guard let mode = TestMode(rawValue: environment["test_mode"] ?? "") else { return .standard }
        return mode
    }
    
}

private extension ScenarioKind {
    var serializedName: String {
        switch self {
        case .environment: return "Environment"
        case .screen: return "Screen"
        case .screenTemplate: return "Screen Template"
        case .component: return "Component"
        case .palette: return "UI Palette"
        case .prototype: return "Prototype"
        }
    }
}

private class MainWindowNotReadyError: Error {}

private extension Bundle {
    
    func becomeCurrentForTesting() {
        UIColor.bundle = self
        Color.bundle = self
        UIImage.bundle = self
        Image.bundle = self
    }
    
}
