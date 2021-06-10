//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Domain
import Foundation
import Interface
import Localization

struct LinkTestResultInteractor: LinkTestResultViewController.Interacting {
    
    var shouldShowDCTInfoView: Bool {
        switch dailyContactTestingEarlyTerminationSupport {
        case .disabled: return false
        case .enabled: return true
        }
    }
    
    var dailyContactTestingEarlyTerminationSupport: DailyContactTestingEarlyIsolationTerminationSupport
    var showNextScreen: (@escaping () -> Void) -> Void
    var openURL: (URL) -> Void
    var onCancel: () -> Void
    var onSubmit: (String) -> AnyPublisher<Void, LinkTestValidationError>
    
    func cancel() {
        onCancel()
    }
    
    #warning("Refactor this")
    func submit(testCode: String, isCheckBoxChecked: Bool?) -> AnyPublisher<Void, LinkTestValidationError> {
        
        // With DCT
        switch dailyContactTestingEarlyTerminationSupport {
        case .disabled:
            return onSubmit(testCode)
                .eraseToAnyPublisher()
        case .enabled(let terminate):
            if isCheckBoxChecked == false, testCode.isEmpty {
                // return an erorr "both are not selected
                return Result.failure(LinkTestValidationError.noneEntered).publisher.eraseToAnyPublisher()
            }
            
            if isCheckBoxChecked == true, !testCode.isEmpty {
                // return an erorr "both are selected
                
                return Result.failure(LinkTestValidationError.testCodeEnteredAndCheckBoxChecked).publisher.eraseToAnyPublisher()
            }
            
            if isCheckBoxChecked == true, testCode.isEmpty {
                showNextScreen(terminate)
                return Result.success(()).publisher.eraseToAnyPublisher()
            }
            
            return onSubmit(testCode)
                .eraseToAnyPublisher()
        }
    }
    
    func reportRapidTestResultsOnGovDotUKTapped() {
        openURL(ExternalLink.reportLFDResultsOnGovDotUK.url)
    }
}
