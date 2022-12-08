//
// Copyright © 2022 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation
import Localization
import UIKit
import ExposureNotification

public protocol SelfReportingFlowViewControllerInteracting {
    func getDiagnosisKeys() -> AnyPublisher<[ENTemporaryExposureKey], Error>
    func submit(selfReportingInfo: SelfReportingInfo, completion: @escaping (Bool) -> Void)
    func share(keys: Result<[ENTemporaryExposureKey], Error>, selfReportingInfo: SelfReportingInfo, completion: @escaping (SelfReportingFlowViewController.State) -> Void)
    func doNotShareKeys()
    func recordNegativeTestResultMetrics()
    func recordVoidTestResultMetrics()
    var alreadyInIsolation: Bool { get }
}

public class SelfReportingInfo {
    public var testResult: TestResult?
    public var testKitType: TestKitType?
    public var nhsTest: Bool?
    public var testDay: SelectedDay?
    public var symptoms: Bool?
    public var symptomsDay: SelectedDay?
    public var reportedResult: Bool?

    public init(
        testResult: TestResult? = nil,
        testKitType: TestKitType? = nil,
        nhsTest: Bool? = nil,
        testDay: SelectedDay? = nil,
        symptoms: Bool? = nil,
        symptomsDay: SelectedDay? = nil,
        reportedResult: Bool? = nil
    ) {
        self.testResult = testResult
        self.testKitType = testKitType
        self.nhsTest = nhsTest
        self.testDay = testDay
        self.symptoms = symptoms
        self.symptomsDay = symptomsDay
        self.reportedResult = reportedResult
    }
}

public class SelfReportingFlowViewController: BaseNavigationController {
    public typealias Interacting = SelfReportingFlowViewControllerInteracting

    public enum ShareResult {
        case sent
        case notSent
    }

    public enum State: Equatable {
        case testResult
        case negativeOrVoidResult
        case shareResults
        case willNotNotifyOthers
        case loading
        case testKitType
        case testSupplier
        case testDate
        case symptoms
        case symptomsDate
        case reportedResult
        case checkAnswers
        case submit
        case error
        case thankYou(reportedResult: Bool, shareResult: ShareResult)
        case advice(reportedResult: Bool, outOfIsolation: Bool)
    }

    @Published fileprivate var state: State = .testResult

    fileprivate let selfReportingInfo = SelfReportingInfo()
    fileprivate let interactor: Interacting
    fileprivate let currentDateProvider: DateProviding
    fileprivate let currentCountry: () -> Country
    fileprivate let testDateSelectionWindow: () -> Int
    fileprivate let symptomsDateSelectionWindow: () -> Int
    fileprivate var temporaryExposureKeyResult: Result<[ENTemporaryExposureKey], Error>?
    fileprivate var putIntoIsolation: Bool = false
    fileprivate let openURL: (URL) -> Void
    fileprivate let isolationEndDate: () -> Date?

    private var diagnosisKeysCancellables: AnyCancellable?
    private var cancellables = [AnyCancellable]()

    public init(
        _ interactor: Interacting,
        currentDateProvider: DateProviding,
        currentCountry: @escaping () -> Country,
        testDateSelectionWindow: @escaping () -> Int,
        symptomsDateSelectionWindow: @escaping () -> Int,
        openURL: @escaping (URL) -> Void,
        isolationEndDate: @escaping () -> Date?
    ) {
        self.interactor = interactor
        self.currentDateProvider = currentDateProvider
        self.currentCountry = currentCountry
        self.testDateSelectionWindow = testDateSelectionWindow
        self.symptomsDateSelectionWindow = symptomsDateSelectionWindow
        self.openURL = openURL
        self.isolationEndDate = isolationEndDate

        super.init()
        monitorState()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func cancel() {
        interactor.doNotShareKeys()
        state = .thankYou(reportedResult: selfReportingInfo.reportedResult ?? true, shareResult: .notSent)
    }

    func shareKeys() {
        guard let temporaryExposureKeyResult = temporaryExposureKeyResult else {
            self.state = .error
            return
        }

        interactor.share(keys: temporaryExposureKeyResult, selfReportingInfo: selfReportingInfo) { state in
            self.state = state
        }
    }

    func getDiagnosisKeys() {
        diagnosisKeysCancellables = interactor.getDiagnosisKeys()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.state = .testKitType
                case .failure(let error):
                    self.temporaryExposureKeyResult = .failure(error)
                    self.state = .willNotNotifyOthers
                }
            }, receiveValue: { tempKeys in
                self.temporaryExposureKeyResult = .success(tempKeys)
            })
    }

    private func monitorState() {
        $state
            .regulate(as: .modelChange)
            .sink { [weak self] state in
                self?.update(for: state)
            }
            .store(in: &cancellables)
    }

    private func update(for state: State) {
        if let viewControllerToPresent = viewControllers.first(where: { type(of: $0) == type(of: rootViewController(for: state)) }) {
            popToViewController(viewControllerToPresent, animated: true)
        } else {
            pushViewController(rootViewController(for: state), animated: state != .testResult)
            if state == .loading {
                getDiagnosisKeys()
            }
        }
        if state == .submit {
            if !putIntoIsolation {
                interactor.submit(selfReportingInfo: selfReportingInfo) { completed in
                    if completed {
                        self.putIntoIsolation = true
                        self.shareKeys()
                    } else {
                        self.state = .error
                    }
                }
            } else {
                self.shareKeys()
            }
        }
    }

    private func rootViewController(for state: State) -> UIViewController {
        switch state {
        case .testResult:
            let interactor = SelfReportingTestTypeViewControllerInteractor(controller: self)
            return SelfReportingTestTypeViewController(interactor: interactor, testResult: selfReportingInfo.testResult)
        case .negativeOrVoidResult:
            let interactor = SelfReportingNegativeOrVoidTestResultViewControllerInteractor(controller: self, openURL: openURL)
            return SelfReportingNegativeOrVoidTestResultViewController(interactor: interactor, country: self.currentCountry())
        case .shareResults:
            let interactor = SelfReportingShareTestResultViewControllerInteractor(controller: self)
            return SelfReportingShareTestResultViewController(interactor: interactor)
        case .willNotNotifyOthers:
            let interactor = SelfReportingWillNotNotifyOthersViewControllerInteractor(controller: self)
            return SelfReportingWillNotNotifyOthersViewController(interactor: interactor)
        case .loading:
            let interactor = LoadingViewControllerInteractor(controller: self)
            return LoadingViewController(interactor: interactor, title: "")
        case .testKitType:
            return SelfReportingTestKitTypeViewController(controller: self)
        case .testSupplier:
            return SelfReportingTestSupplierViewController(controller: self)
        case .testDate:
            return SelfReportingTestDateViewController(controller: self)
        case .symptoms:
            return SelfReportingSymptomsViewController(controller: self)
        case .symptomsDate:
            return SelfReportingSymptomsDateViewController(controller: self)
        case .reportedResult:
            return SelfReportingResultReportedViewController(controller: self)
        case .checkAnswers:
            let interactor = SelfReportingCheckAnswersViewControllerInteractor(controller: self)
            return SelfReportingCheckAnswersViewController(interactor: interactor, info: selfReportingInfo)
        case .submit:
            return SubmitViewController(controller: self)
        case .error:
            let interactor = LoadingErrorViewControllerInteractor(controller: self)
            return LoadingErrorViewController(interacting: interactor, title: "")
        case .thankYou(let reportedResult, let shareResult):
            let interactor = SelfReportingAnswersSubmittedViewControllerInteractor(controller: self)
            let state: SelfReportingAnswersSubmittedViewController.State = shareResult == .sent ? .shared(reportedResult: reportedResult) : .notShared(reportedResult: reportedResult)
            return SelfReportingAnswersSubmittedViewController(interactor: interactor, state: state)
        case .advice(let reportedResult, let outOfIsolation):
            let interactor = SelfReportingAdviceViewControllerInteractor(controller: self, openURL: openURL)
            let isolationEndDate = isolationEndDate() ?? Date()
            let isolationDuration = currentDateProvider.currentLocalDay.daysRemaining(until: isolationEndDate)

            switch (reportedResult, outOfIsolation) {
            case (true, true):
                return SelfReportingAdviceViewController(interactor: interactor, state: .reportedResultOutOfIsolation)
            case (true, false):
                return SelfReportingAdviceViewController(interactor: interactor, state: .reportedResult(isolationDuration: isolationDuration))
            case (false, true):
                return SelfReportingAdviceViewController(interactor: interactor, state: .notReportedResultOutOfIsolation)
            case (false, false):
                return SelfReportingAdviceViewController(interactor: interactor, state: .notReportedResult(isolationDuration: isolationDuration, endDate: isolationEndDate))
            }
        }
    }
}

private class SelfReportingTestTypeViewControllerInteractor: SelfReportingTestTypeViewController.Interacting {
    private var controller: SelfReportingFlowViewController

    init(controller: SelfReportingFlowViewController) {
        self.controller = controller
    }

    func didTapPrimaryButton(_ testResult: TestResult) {
        controller.selfReportingInfo.testResult = testResult
        switch testResult {
        case .positive:
            controller.state = .shareResults
        case .negative:
            controller.state = .negativeOrVoidResult
        case .void:
            controller.state = .negativeOrVoidResult
        }
    }

    func didTapBackButton() {
        controller.dismiss(animated: true, completion: nil)
    }
}

private class SelfReportingNegativeOrVoidTestResultViewControllerInteractor: SelfReportingNegativeOrVoidTestResultViewController.Interacting {

    private var controller: SelfReportingFlowViewController
    private var openURL: (URL) -> Void

    init(controller: SelfReportingFlowViewController, openURL: @escaping (URL) -> Void) {
        self.controller = controller
        self.openURL = openURL
    }

    func didTapFindOutMoreLink() {
        openURL(ExternalLink.negativeOrVoidTestResultEnglandFindMoreLink.url)
    }

    func didTapNHS111Online() {
        openURL(ExternalLink.nhs111Online.url)
    }

    func didTapPrimaryButton() {
        let testResult = controller.selfReportingInfo.testResult
        if testResult == .negative {
            controller.interactor.recordNegativeTestResultMetrics()
        } else if testResult == .void {
            controller.interactor.recordVoidTestResultMetrics()
        }

        controller.dismiss(animated: true)
    }

    func didTapBackButton() {
        controller.state = .testResult
    }
}

private class SelfReportingShareTestResultViewControllerInteractor: SelfReportingShareTestResultViewController.Interacting {
    private var controller: SelfReportingFlowViewController

    init(controller: SelfReportingFlowViewController) {
        self.controller = controller
    }

    func didTapPrimaryButton() {
        controller.state = .loading
    }

    func didTapBackButton() {
        controller.state = .testResult
    }
}

private class SelfReportingWillNotNotifyOthersViewControllerInteractor: SelfReportingWillNotNotifyOthersViewController.Interacting {
    private var controller: SelfReportingFlowViewController

    init(controller: SelfReportingFlowViewController) {
        self.controller = controller
    }

    func didTapPrimaryButton() {
        controller.state = .testKitType
    }

    func didTapBackButton() {
        controller.state = .shareResults
    }
}

private class LoadingViewControllerInteractor: LoadingViewController.Interacting {
    private var controller: SelfReportingFlowViewController

    init(controller: SelfReportingFlowViewController) {
        self.controller = controller
    }

    func didTapCancel() {
        controller.state = .shareResults
    }
}

private class SelfReportingTestKitTypeViewController: SelfReportingQuestionViewController {
    init(controller: SelfReportingFlowViewController) {
        let interactor = SelfReportingTestKitTypeViewControllerInteractor(controller: controller)
        let firstChoice = controller.selfReportingInfo.testKitType == nil
        ? nil : controller.selfReportingInfo.testKitType == .labResult
        ? false : true

        var keysShared: Bool {
            if let result = controller.temporaryExposureKeyResult {
                switch result {
                case .success:
                    return true
                case .failure:
                    return false
                }
            } else {
                return false
            }
        }

        super.init(
            interactor: interactor,
            firstChoice: firstChoice,
            state: .testKitType(keysShared: keysShared)
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class SelfReportingTestKitTypeViewControllerInteractor: SelfReportingQuestionViewController.Interacting {
    private var controller: SelfReportingFlowViewController

    init(controller: SelfReportingFlowViewController) {
        self.controller = controller
    }

    func didTapPrimaryButton(_ firstChoice: Bool) {
        controller.selfReportingInfo.testKitType = firstChoice ? .rapidSelfReported : .labResult

        if controller.selfReportingInfo.testKitType != .rapidSelfReported {
            controller.selfReportingInfo.nhsTest = nil
            controller.selfReportingInfo.reportedResult = nil
        }

        controller.state = firstChoice ? .testSupplier : .testDate
    }

    func didTapBackButton() {
        if let result = controller.temporaryExposureKeyResult {
            switch result {
            case .success:
                controller.state = .shareResults
            case .failure:
                controller.state =  .willNotNotifyOthers
            }
        } else {
            controller.state = .shareResults
        }
    }
}

private class SelfReportingTestSupplierViewController: SelfReportingQuestionViewController {
    init(controller: SelfReportingFlowViewController) {
        let interactor = SelfReportingTestSupplierViewControllerInteractor(controller: controller)
        super.init(interactor: interactor, firstChoice: controller.selfReportingInfo.nhsTest, state: .testSupplier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class SelfReportingTestSupplierViewControllerInteractor: SelfReportingQuestionViewController.Interacting {
    private var controller: SelfReportingFlowViewController

    init(controller: SelfReportingFlowViewController) {
        self.controller = controller
    }

    func didTapPrimaryButton(_ firstChoice: Bool) {
        controller.selfReportingInfo.nhsTest = firstChoice

        if controller.selfReportingInfo.nhsTest == false {
            controller.selfReportingInfo.reportedResult = nil
        }

        controller.state = .testDate
    }

    func didTapBackButton() {
        controller.state = .testKitType
    }
}

private class SelfReportingTestDateViewController: SelfReportingSelectDateViewController {
    init(controller: SelfReportingFlowViewController) {
        let interactor = SelfReportingTestDateViewControllerInteractor(controller: controller)
        super.init(
            interactor: interactor,
            selectedDay: controller.selfReportingInfo.testDay,
            dateSelectionWindow: controller.testDateSelectionWindow(),
            lastSelectionDate: controller.currentDateProvider.currentGregorianDay(timeZone: .current),
            state: .testDate(testKitType: controller.selfReportingInfo.testKitType == .rapidSelfReported ? .rapidSelfReported : .labResult)
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class SelfReportingTestDateViewControllerInteractor: SelfReportingSelectDateViewController.Interacting {
    private var controller: SelfReportingFlowViewController

    init(controller: SelfReportingFlowViewController) {
        self.controller = controller
    }

    func didTapPrimaryButton(selectedDay: SelectedDay) {
        if let testDay = controller.selfReportingInfo.testDay, testDay.day != selectedDay.day {
            controller.selfReportingInfo.symptomsDay = nil
        }
        controller.selfReportingInfo.testDay = selectedDay

        if controller.interactor.alreadyInIsolation {
            if controller.selfReportingInfo.testResult == .positive,
               controller.selfReportingInfo.testKitType == .rapidSelfReported,
               controller.selfReportingInfo.nhsTest == true {
                controller.state = .reportedResult
            } else {
                controller.state = .checkAnswers
            }
        } else {
            controller.state = .symptoms
        }
    }

    func didTapBackButton() {
        controller.state = controller.selfReportingInfo.testKitType == .labResult ? .testKitType : .testSupplier
    }
}

private class SelfReportingSymptomsViewController: SelfReportingQuestionViewController {
    init(controller: SelfReportingFlowViewController) {
        let interactor = SelfReportingSymptomsViewControllerInteractor(controller: controller)
        super.init(
            interactor: interactor,
            firstChoice: controller.selfReportingInfo.symptoms,
            state: .symptoms
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class SelfReportingSymptomsViewControllerInteractor: SelfReportingQuestionViewController.Interacting {
    private var controller: SelfReportingFlowViewController

    init(controller: SelfReportingFlowViewController) {
        self.controller = controller
    }

    func didTapPrimaryButton(_ firstChoice: Bool) {
        controller.selfReportingInfo.symptoms = firstChoice

        if controller.selfReportingInfo.symptoms == false {
            controller.selfReportingInfo.symptomsDay = nil
        }

        if controller.selfReportingInfo.testResult == .positive,
           controller.selfReportingInfo.testKitType == .rapidSelfReported,
           controller.selfReportingInfo.nhsTest == true,
           controller.selfReportingInfo.symptoms == false {
            controller.state = .reportedResult
            return
        }

        controller.state = firstChoice ? .symptomsDate : .checkAnswers
    }

    func didTapBackButton() {
        controller.state = .testDate
    }
}

private class SelfReportingSymptomsDateViewController: SelfReportingSelectDateViewController {
    init(controller: SelfReportingFlowViewController) {
        let interactor = SelfReportingSymptomsDateViewControllerInteractor(controller: controller)
        super.init(
            interactor: interactor,
            selectedDay: controller.selfReportingInfo.symptomsDay,
            dateSelectionWindow: controller.symptomsDateSelectionWindow(),
            lastSelectionDate: controller.selfReportingInfo.testDay?.day ?? controller.currentDateProvider.currentGregorianDay(timeZone: .current),
            state: .symptomsDate
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class SelfReportingSymptomsDateViewControllerInteractor: SelfReportingSelectDateViewController.Interacting {
    private var controller: SelfReportingFlowViewController

    init(controller: SelfReportingFlowViewController) {
        self.controller = controller
    }

    func didTapPrimaryButton(selectedDay: SelectedDay) {
        controller.selfReportingInfo.symptomsDay = selectedDay
        if controller.selfReportingInfo.testResult == .positive,
           controller.selfReportingInfo.testKitType == .rapidSelfReported,
           controller.selfReportingInfo.nhsTest == true {
            controller.state = .reportedResult
            return
        }
        controller.state = .checkAnswers
    }

    func didTapBackButton() {
        controller.state = .symptoms
    }
}

private class SelfReportingResultReportedViewController: SelfReportingQuestionViewController {
    init(controller: SelfReportingFlowViewController) {
        let interactor = SelfReportingResultReportedInteractor(controller: controller)
        super.init(
            interactor: interactor,
            firstChoice: controller.selfReportingInfo.reportedResult,
            state: .reportedResult(symptoms: controller.selfReportingInfo.symptoms)
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class SelfReportingResultReportedInteractor: SelfReportingQuestionViewController.Interacting {
    private var controller: SelfReportingFlowViewController

    init(controller: SelfReportingFlowViewController) {
        self.controller = controller
    }

    func didTapPrimaryButton(_ firstChoice: Bool) {
        controller.selfReportingInfo.reportedResult = firstChoice
        controller.state = .checkAnswers
    }

    func didTapBackButton() {
        if controller.selfReportingInfo.symptoms == nil {
            controller.state = .testDate
        } else if controller.selfReportingInfo.symptoms == true {
            controller.state = .symptomsDate
        } else {
            controller.state = .symptoms
        }
    }
}

private class SelfReportingCheckAnswersViewControllerInteractor: SelfReportingCheckAnswersViewController.Interacting {
    private var controller: SelfReportingFlowViewController

    init(controller: SelfReportingFlowViewController) {
        self.controller = controller
    }

    func didTapPrimaryButton() {
        controller.state = .submit
    }

    func didTapBackButton() {
        if controller.selfReportingInfo.reportedResult != nil {
            controller.state = .reportedResult
        } else if controller.selfReportingInfo.symptoms == nil {
            controller.state = .testDate
        } else if controller.selfReportingInfo.symptoms == true {
            controller.state = .symptomsDate
        } else {
            controller.state = .symptoms
        }
    }

    func didTapChangeTestKitType() {
        controller.state = .testKitType
    }

    func didTapChangeTestSupplier() {
        controller.state = .testSupplier
    }

    func didTapChangeTestDay() {
        controller.state = .testDate
    }

    func didTapChangeSymptoms() {
        controller.state = .symptoms
    }

    func didTapChangeSymptomsDay() {
        controller.state = .symptomsDate
    }

    func didTapChangeReportedResult() {
        controller.state = .reportedResult
    }
}

private class SubmitViewControllerInteractor: LoadingViewController.Interacting {
    private var controller: SelfReportingFlowViewController

    init(controller: SelfReportingFlowViewController) {
        self.controller = controller
    }

    func didTapCancel() {
        controller.cancel()
    }
}

private class SubmitViewController: LoadingViewController {
    init(controller: SelfReportingFlowViewController) {
        let interactor = SubmitViewControllerInteractor(controller: controller)
        super.init(interactor: interactor, title: "")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private struct LoadingErrorViewControllerInteractor: LoadingErrorViewController.Interacting {
    private var controller: SelfReportingFlowViewController

    init(controller: SelfReportingFlowViewController) {
        self.controller = controller
    }

    func didTapRetry() {
        controller.state = .submit
    }

    func didTapCancel() {
        if controller.putIntoIsolation {
            controller.cancel()
        } else {
            controller.dismiss(animated: true)
        }
    }
}

private class SelfReportingAnswersSubmittedViewControllerInteractor: SelfReportingAnswersSubmittedViewController.Interacting {
    private var controller: SelfReportingFlowViewController

    init(controller: SelfReportingFlowViewController) {
        self.controller = controller
    }

    func didTapPrimaryButton() {
        controller.state = .advice(
            reportedResult: controller.selfReportingInfo.reportedResult ?? true,
            outOfIsolation: !controller.interactor.alreadyInIsolation
        )
    }
}

private class SelfReportingAdviceViewControllerInteractor: SelfReportingAdviceViewController.Interacting {
    private var controller: SelfReportingFlowViewController

    var openURL: (URL) -> Void

    init(controller: SelfReportingFlowViewController, openURL: @escaping (URL) -> Void) {
        self.controller = controller
        self.openURL = openURL
    }

    func didTapReadMoreLink() {
        openURL(ExternalLink.selfIsolationInfo.url)
    }

    func didTapReportResult() {
        openURL(ExternalLink.reportLFDResultsOnGovDotUK.url)
    }

    func didTapBackToHome() {
        controller.dismiss(animated: true)
    }
}
