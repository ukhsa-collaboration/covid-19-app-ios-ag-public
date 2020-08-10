//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Domain
import Integration
import Interface
import SwiftUI
import UIKit

public class HomeFlowScenario: Scenario {
    
    public static var name = "Home"
    public static var kind = ScenarioKind.flow
    public static var showDiagnosisAlertTitle = "Show Diagnosis"
    public static var showAdviceAlertTitle = "Show Advice"
    public static var showIsolationAdviceAlertTitle = "Show Isolation Advice"
    public static var showCheckInAlertTitle = "Show Check-in"
    public static var showTestingInformationAlertTitle = "Show testing information"
    public static var showFAQAlertTitle = "Show FAQ"
    public static var showDeleteDataAlertTitle = "Delete data"
    public static var showPrivacyAlertTitle = "Show Privacy"
    public static var showTermsOfUseAlertTitle = "Show Terms of Use"
    public static var showAccessibilityStatementTitle = "Show Accessibility Statement"
    public static var showAboutContactTracing = "Show About contact tracing"
    
    static var appController: AppController {
        Controller()
    }
    
    private class Controller: AppController {
        
        let rootViewController = UIViewController()
        
        init() {
            let interactor = HomeFlowInteractor(viewController: rootViewController)
            let postcodeViewModel = RiskLevelBanner.ViewModel(postcode: "SW12", riskLevel: .constant(.low), moreInfo: {})
            let riskLevelIndicatorViewModel = RiskLevelIndicator.ViewModel(isolationState: .constant(.notIsolating), paused: .constant(false))
            let flow = HomeFlowViewController(
                interactor: interactor,
                postcodeViewModel: postcodeViewModel,
                isolationViewModel: riskLevelIndicatorViewModel,
                exposureNotificationsEnabled: Just(true).eraseToAnyPublisher(),
                showOrderTestButton: .constant(false),
                shouldShowSelfDiagnosis: Empty().property(initialValue: true)
            )
            rootViewController.addFilling(flow)
        }
    }
}

private struct HomeFlowInteractor: HomeFlowViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func makeDiagnosisViewController() -> UIViewController? {
        UIHostingController(rootView: ViewController(title: HomeFlowScenario.showDiagnosisAlertTitle, dismiss: dismiss))
    }
    
    func makeCheckInViewController() -> UIViewController? {
        UIHostingController(rootView: ViewController(title: HomeFlowScenario.showCheckInAlertTitle, dismiss: dismiss))
    }
    
    func makeTestingInformationViewController() -> UIViewController? {
        UIHostingController(rootView: ViewController(title: HomeFlowScenario.showTestingInformationAlertTitle, dismiss: dismiss))
    }
    
    func setExposureNotifcationEnabled(_ enabled: Bool) -> AnyPublisher<Void, Never> {
        Just(()).eraseToAnyPublisher()
    }
    
    var shouldShowCheckIn: Bool {
        true
    }
    
    func getAppData() -> AppData {
        AppData(
            postcode: nil,
            testResult: nil,
            venueHistory: [],
            symptomsOnsetDate: nil,
            encounterDate: nil
        )
    }
    
    func openAdvice() {
        viewController?.showAlert(title: HomeFlowScenario.showAdviceAlertTitle)
    }
    
    func openIsolationAdvice() {
        viewController?.showAlert(title: HomeFlowScenario.showIsolationAdviceAlertTitle)
    }
    
    func openAboutContactTracingLink() {
        viewController?.showAlert(title: HomeFlowScenario.showAboutContactTracing)
    }
    
    func deleteAppData() {
        viewController?.showAlert(title: HomeFlowScenario.showDeleteDataAlertTitle)
    }
    
    func openPrivacyLink() {
        viewController?.showAlert(title: HomeFlowScenario.showPrivacyAlertTitle)
    }
    
    func openTearmsOfUseLink() {
        viewController?.showAlert(title: HomeFlowScenario.showTermsOfUseAlertTitle)
    }
    
    func openFAQ() {
        viewController?.showAlert(title: HomeFlowScenario.showFAQAlertTitle)
    }
    
    private func dismiss() {
        viewController?.dismiss(animated: true, completion: nil)
    }
    
    func openAccessibilityStatementLink() {
        viewController?.showAlert(title: HomeFlowScenario.showAccessibilityStatementTitle)
    }
    
}

private struct ViewController: View {
    var title: String
    var dismiss: () -> Void
    var body: some View {
        VStack {
            Text(title)
            Button(action: {
                self.dismiss()
            }) { Text("Close") }
        }
        
    }
}
