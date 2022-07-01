//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Integration
import Interface
import SwiftUI
import UIKit

public class MyDataScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "My Data"

    public static let didTapEditPostcode = "Tapped edit postcode"
    public static let confirmedDeleteAllData = "Confirmed delete all data"

    public static let testResult = TestResult.positive
    public static let testKitType = TestKitType.labResult
    public static let completionStatus = MyDataViewController.ViewModel.TestResultDetails.CompletionStatus.completed(onDay: GregorianDay(year: 2021, month: 1, day: 26))

    public static let testEndDate = Calendar.utc.date(from: DateComponents(year: 2020, month: 5, day: 6, hour: 8))!
    public static let testAcknowledgmentDate = Calendar.utc.date(from: DateComponents(year: 2020, month: 5, day: 7, hour: 8))!
    public static let symptomsDate = Calendar.utc.date(from: DateComponents(year: 2020, month: 5, day: 7, hour: 8))!
    public static let encounterDate = Calendar.utc.date(from: DateComponents(year: 2020, month: 5, day: 8, hour: 8))!
    public static let notificationDate = Calendar.utc.date(from: DateComponents(year: 2020, month: 5, day: 11, hour: 8))!
    public static let endSelfIsolationDate = Calendar.utc.date(from: DateComponents(year: 2020, month: 5, day: 22, hour: 8))!
    public static let venueOfRiskDate = Calendar.utc.date(from: DateComponents(year: 2021, month: 2, day: 25, hour: 21))!
    public static let optOutOfIsolationDate = Calendar.utc.date(from: DateComponents(year: 2020, month: 5, day: 8, hour: 8))!

    static var appController: AppController {
        NavigationAppController { parent in
            MyDataViewController(
                viewModel: .init(
                    testResultDetails: .init(
                        result: testResult,
                        acknowledgementDate: testAcknowledgmentDate,
                        testEndDate: testEndDate,
                        testKitType: testKitType,
                        completionStatus: completionStatus
                    ),
                    symptomsOnsetDate: symptomsDate,
                    exposureNotificationDetails: .init(
                        encounterDate: encounterDate,
                        notificationDate: notificationDate,
                        optOutOfIsolationDate: optOutOfIsolationDate
                    ),
                    selfIsolationEndDate: endSelfIsolationDate,
                    venueOfRiskDate: venueOfRiskDate
                )
            )
        }
    }
}
