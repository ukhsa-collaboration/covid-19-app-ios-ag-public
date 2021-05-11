//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import ExposureNotification
import Foundation
@testable import Domain
@testable import Scenarios

@available(iOS 13.7, *)
struct RiskyContact {
    private let apiClient: MockHTTPClient
    private let distributeClient: MockHTTPClient
    private let currentDateProvider: AcceptanceTestMockDateProvider
    private let windowsExposureNotificationManager: MockWindowsExposureNotificationManager
    
    init(
        configuration: AcceptanceTestCase.Instance.Configuration
    ) {
        apiClient = configuration.apiClient
        distributeClient = configuration.distributeClient
        currentDateProvider = configuration.currentDateProvider
        windowsExposureNotificationManager = configuration.exposureNotificationManager as! MockWindowsExposureNotificationManager
    }
    
    func trigger(exposureDate: Date, runBeforeTeardown: () -> Void) {
        setupMockAPIsForRiskyContact()
        setupMockExposureNotification(exposureDate)
        runBeforeTeardown()
        teardown()
    }
    
    private func setupMockAPIsForRiskyContact() {
        distributeClient.response(for: "/distribution/exposure-configuration", response: .success(.ok(with: .json(exposureConfiguration))))
        let day = GregorianDay(date: currentDateProvider.currentDate, timeZone: .utc)
        let increment = Increment.twoHourly(day, Increment.TwoHour(value: 0))
        distributeClient.response(for: "/distribution/two-hourly/\(increment.parse()).zip", response: .success(.ok(with: .untyped(zipFile))))
        apiClient.response(for: "/circuit-breaker/exposure-notification/request", response: .success(.ok(with: .json(circuitBreakerResponse))))
    }
    
    private func setupMockExposureNotification(_ exposureDate: Date) {
        windowsExposureNotificationManager.exposureWindows = [
            StubExposureWindow(exposureDate: exposureDate),
        ]
    }
    
    private func teardown() {
        windowsExposureNotificationManager.exposureWindows = []
        apiClient.reset()
        distributeClient.reset()
    }
    
}

@available(iOS 13.7, *)
extension RiskyContact {
    private var zipFile: Data {
        let base64Zip = "UEsDBBQACAAIAAAAAAAAAAAAAAAAAAAAAAAKAAAAZXhwb3J0LmJpbnL1VnCtKMgvKlEoM1RQUFDg/PDieBwDAwODYIHVSTBDiik0WIFRg9FIUYrRUIm9OD83NT4zRUvYUM9Iz8LEQM/QwMDEVM9Ez1jPyEqaS0Bc/0jD0xmePCbiZSzGs0WdBTgk/txbyKjACJLUTma1OtKs3PuwTGxem7ztWQFGiS6QZBEgAAD//1BLBwhQGAPXhwAAAIcAAABQSwMEFAAIAAgAAAAAAAAAAAAAAAAAAAAAAAoAAABleHBvcnQuc2ln4irkUpRiNFRiL87PTY3PTNESNtQz0rMwMdAzNDAwMdUz0TPWMxJglGBU8jBwY1JkmLft5dW1WRn9Kws2PKvhaDOJe39XQjJS725LgpfMeV8mdyZFhgm59Wc/CR4X+OGlVSnOwFq878N79SXTHTXvaZStyZD8lgUIAAD//1BLBwhEY4HtfAAAAHMAAABQSwECFAAUAAgACAAAAAAAUBgD14cAAACHAAAACgAAAAAAAAAAAAAAAAAAAAAAZXhwb3J0LmJpblBLAQIUABQACAAIAAAAAABEY4HtfAAAAHMAAAAKAAAAAAAAAAAAAAAAAL8AAABleHBvcnQuc2lnUEsFBgAAAAACAAIAcAAAAHMBAAAAAA=="
        return Data(base64Encoded: base64Zip)!
    }
}

private let circuitBreakerResponse = """
{
    "approvalToken": "QkFDQzlBREUtN0ZBMC00RTFELUE3NUMtRTZBMUFGNkMyRjNECg",
    "approval": "yes"
}
"""

private let exposureConfiguration = """
{
    "exposureNotification": {
        "minimumRiskScore": 11,
        "attenuationDurationThresholds": [55, 63],
        "attenuationLevelValues": [0, 1, 1, 1, 1, 1, 1, 1],
        "daysSinceLastExposureLevelValues": [5, 5, 5, 5, 5, 5, 5, 5],
        "durationLevelValues": [0, 0, 0, 1, 1, 1, 1, 1],
        "transmissionRiskLevelValues": [1, 2, 3, 4, 5, 6, 7, 8],
        "attenuationWeight": 50.0,
        "daysSinceLastExposureWeight": 20,
        "durationWeight": 50.0,
        "transmissionRiskWeight": 50.0
    },
    "riskCalculation": {
        "durationBucketWeights": [1.0, 0.5, 0.0],
        "riskThreshold": 20.0
    },
    "v2RiskCalculation": {
        "daysSinceOnsetToInfectiousness": [
            0, 0, 0, 0, 0, 0, 0, 0, 0,
            1, 1, 1,
            2, 2, 2, 2, 2, 2,
            1, 1, 1, 1, 1, 1,
            0, 0, 0, 0, 0
        ],
        "infectiousnessWeights": [0.0, 0.4, 1.0],
        "reportTypeWhenMissing": 1,
        "riskThreshold": 0.0
    },
    "riskScore": {
        "sampleResolution": 1.0,
        "expectedDistance": 0.1,
        "minimumDistance": 1.0,
        "rssiParameters" : {
            "weightCoefficient": 0.1270547531082051,
            "intercept": 4.2309333657856945,
            "covariance": 0.4947614361027773
        },
        "powerLossParameters": {
            "wavelength": 0.125,
            "pathLossFactor": 20.0,
            "refDeviceLoss": 0.0
        },
        "observationType": "log",
        "initialData": {
            "mean": 2.0,
            "covariance": 10.0
        },
        "smootherParameters": {
            "alpha": 1.0,
            "beta": 0.0,
            "kappa": 0.0
        }
    }
}
"""
