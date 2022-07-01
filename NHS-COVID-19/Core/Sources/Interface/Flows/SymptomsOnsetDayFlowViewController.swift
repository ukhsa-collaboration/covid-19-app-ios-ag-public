//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import UIKit

public class SymptomsOnsetDayFlowViewController: BaseNavigationController {

    fileprivate enum State: Equatable {
        case checkSymptoms
        case symptomsReview
    }

    @Published
    fileprivate var state: State = .checkSymptoms
    private var cancellables = [AnyCancellable]()
    private var didFinishAskForSymptomsOnsetDay: () -> Void
    private var setOnsetDay: (GregorianDay) -> Void
    private var recordDidHaveSymptoms: () -> Void
    private var testEndDay: GregorianDay

    public init(testEndDay: GregorianDay, didFinishAskForSymptomsOnsetDay: @escaping () -> Void, setOnsetDay: @escaping (GregorianDay) -> Void, recordDidHaveSymptoms: @escaping () -> Void) {
        self.didFinishAskForSymptomsOnsetDay = didFinishAskForSymptomsOnsetDay
        self.setOnsetDay = setOnsetDay
        self.recordDidHaveSymptoms = recordDidHaveSymptoms
        self.testEndDay = testEndDay
        super.init()
        monitorState()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func rootViewController(for state: State) -> UIViewController {
        switch state {
        case .checkSymptoms:
            let interactor = TestCheckSymptomsInteractor(
                didTapYes: {
                    self.state = .symptomsReview
                    self.recordDidHaveSymptoms()
                },
                didTapNo: {
                    self.didFinishAskForSymptomsOnsetDay()
                }
            )
            return TestCheckSymptomsViewController.viewController(for: .enterTestResult, interactor: interactor)
        case .symptomsReview:
            let interactor = TestSymptomsReviewInteractor(_confirmSymptomsDate: { selectedDay, hasCheckedNoDate in
                if selectedDay == nil, !hasCheckedNoDate {
                    return .failure(.neitherDateNorNoDateCheckSet)
                } else {
                    if let selectedDay = selectedDay {
                        self.setOnsetDay(selectedDay)
                    }
                    self.didFinishAskForSymptomsOnsetDay()
                    return .success(())
                }
            })
            return TestSymptomsReviewViewController(
                testEndDay: testEndDay,
                dateSelectionWindow: 6,
                interactor: interactor
            )
        }
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
        pushViewController(rootViewController(for: state), animated: false)
    }
}

private struct TestCheckSymptomsInteractor: TestCheckSymptomsViewController.Interacting {
    var didTapYes: () -> Void
    var didTapNo: () -> Void

}

private struct TestSymptomsReviewInteractor: TestSymptomsReviewViewController.Interacting {
    var _confirmSymptomsDate: (GregorianDay?, Bool) -> Result<Void, TestSymptomsReviewUIError>
    func confirmSymptomsDate(selectedDay: GregorianDay?, hasCheckedNoDate: Bool) -> Result<Void, TestSymptomsReviewUIError> {
        _confirmSymptomsDate(selectedDay, hasCheckedNoDate)
    }
}
