

import Foundation
@testable import Domain
import XCTest

@available(iOS 13.7, *)
class IsolationPaymentAnalyticsTests: AnalyticsTests {
    private var riskyContact: RiskyContact!

    override func setUpFunctionalities() {
        riskyContact = RiskyContact(configuration: $instance)

        $instance.apiClient.response(for: "/isolation-payment/ipc-token/create", response: .success(.ok(with: .json("""
        {
            "ipcToken": "\(UUID().uuidString)",
            "isEnabled": true
        }
        """))))
    }
    
    func testReceivedAcitveIPCTokenAndIpcTokenBackgroundTick() {
        riskyContact.trigger(exposureDate: currentDateProvider.currentDate) {
            self.assertOnFields { assertField in
                assertField.equals(expected: 1, \.receivedRiskyContactNotification)
                assertField.equals(expected: 1, \.startedIsolation)
                assertField.equals(expected: 1, \.receivedActiveIpcToken)
                assertField.isPresent(\.haveActiveIpcTokenBackgroundTick)
                assertField.isPresent(\.isIsolatingBackgroundTick)
                assertField.isPresent(\.isIsolatingForHadRiskyContactBackgroundTick)
                assertField.isPresent(\.hasHadRiskyContactBackgroundTick)
            }
        }
    }
}
