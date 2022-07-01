//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Domain
import ExposureNotification
import Foundation
import Localization

@available(iOSApplicationExtension, unavailable)
class SimulatedExposureNotificationManager: ExposureNotificationManaging {
    private var cancellables = Set<AnyCancellable>()

    private let queue = DispatchQueue.main
    private let dataProvider = MockDataProvider.shared
    private let dateProvider: DateProviding
    private let bluetoothEnabled: AnyPublisher<Bool, Never>

    var instanceAuthorizationStatus: AuthorizationStatus

    @Published
    var exposureNotificationStatus: Status
    var exposureNotificationStatusPublisher: AnyPublisher<Status, Never> {
        $exposureNotificationStatus
            .eraseToAnyPublisher()
    }

    @Published
    var exposureNotificationEnabled: Bool
    var exposureNotificationEnabledPublisher: AnyPublisher<Bool, Never> {
        $exposureNotificationEnabled
            .eraseToAnyPublisher()
    }

    init(dateProvider: DateProviding, bluetoothEnabled: AnyPublisher<Bool, Never>) {
        self.dateProvider = dateProvider
        self.bluetoothEnabled = bluetoothEnabled
        instanceAuthorizationStatus = .unknown
        exposureNotificationStatus = .unknown
        exposureNotificationEnabled = false
        bluetoothEnabled.sink { [weak self] bluetoothEnabled in
            self?.queue.async {
                self?.exposureNotificationStatus = bluetoothEnabled ? .active : .bluetoothOff
            }
        }.store(in: &cancellables)
    }

    func activate(completionHandler: @escaping ErrorHandler) {
        queue.async {
            self.instanceAuthorizationStatus = .authorized
            self.exposureNotificationEnabled = true
            completionHandler(nil)
        }
    }

    func setExposureNotificationEnabled(_ enabled: Bool, completionHandler: @escaping ErrorHandler) {
        queue.async {
            self.exposureNotificationEnabled = enabled
            completionHandler(nil)
        }
    }

    func getDiagnosisKeys(completionHandler: @escaping ENGetDiagnosisKeysHandler) {
        var diagnosisKeys = [ENTemporaryExposureKey]()
        let calendar = Calendar.current
        let today = dateProvider.currentGregorianDay(timeZone: .current)

        (1 ... 14).forEach { index in
            let diagnosisKey = ENTemporaryExposureKey()
            var date = today.advanced(by: -index).dateComponents
            date.calendar = calendar
            diagnosisKey.keyData = "\(date.day!).\(date.month!).\(date.year!)".data(using: .utf8)!
            diagnosisKey.rollingStartNumber = UInt32(exactly: date.date!.timeIntervalSince1970 / (60 * 10))!
            diagnosisKey.rollingPeriod = UInt32(24 * (60 / 10)) // Amount of 10 minute periods in 24 hours
            diagnosisKeys.append(diagnosisKey)
        }

        queue.async {
            completionHandler(diagnosisKeys, nil)
        }
    }

    func detectExposures(configuration: ENExposureConfiguration, diagnosisKeyURLs: [URL], completionHandler: @escaping ENDetectExposuresHandler) -> Progress {
        queue.async {
            let summary = ENExposureDetectionSummary()
            completionHandler(summary, nil)
        }
        return Progress()
    }

    func getExposureInfo(summary: ENExposureDetectionSummary, userExplanation: String, completionHandler: @escaping ENGetExposureInfoHandler) -> Progress {
        let info = repeatElement(SimulatedExposureInfo(daysAgo: dataProvider.contactDaysAgo, currentDateProvider: dateProvider), count: dataProvider.numberOfContacts)
        queue.async {
            completionHandler(Array(info), nil)
        }
        return Progress()
    }

    func getExposureInfo(summary: ENExposureDetectionSummary, completionHandler: @escaping ENGetExposureInfoHandler) {
        _ = getExposureInfo(summary: summary, userExplanation: UUID().uuidString, completionHandler: completionHandler)
    }

    @available(iOS 13.7, *)
    func getExposureWindows(summary: ENExposureDetectionSummary, completionHandler: @escaping ENGetExposureWindowsHandler) -> Progress {
        let windows = repeatElement(SimulatedRiskyExposureWindow(daysAgo: dataProvider.contactDaysAgo, currentDateProvider: dateProvider), count: dataProvider.numberOfContacts)
        queue.async {
            completionHandler(Array(windows), nil)
        }
        return Progress()
    }
}

private class SimulatedExposureInfo: ENExposureInfo {

    private let _date: Date
    private let _attenuationDurations: [NSNumber]

    init(daysAgo: Int, currentDateProvider: DateProviding) {
        _date = currentDateProvider.currentGregorianDay(timeZone: .current).advanced(by: -daysAgo).startDate(in: .utc)
        _attenuationDurations = [1800, 1800, 1800]
        super.init()
    }

    override var date: Date {
        _date
    }

    override var attenuationDurations: [NSNumber] {
        _attenuationDurations
    }

    override var transmissionRiskLevel: ENRiskLevel {
        7
    }

}

@available(iOS 13.7, *)
private class SimulatedRiskyExposureWindow: ENExposureWindow {

    private let _date: Date

    init(daysAgo: Int, currentDateProvider: DateProviding) {
        _date = currentDateProvider.currentGregorianDay(timeZone: .current).advanced(by: -daysAgo).startDate(in: .utc)
        super.init()
    }

    override var date: Date {
        _date
    }

    override var infectiousness: ENInfectiousness {
        .high
    }

    override var scanInstances: [ENScanInstance] {
        [
            SimulatedScanInstance(minimumAttenuation: 97, secondsSinceLastScan: 201),
            SimulatedScanInstance(minimumAttenuation: 85, secondsSinceLastScan: 225),
            SimulatedScanInstance(minimumAttenuation: 83, secondsSinceLastScan: 279),
            SimulatedScanInstance(minimumAttenuation: 64, secondsSinceLastScan: 215),
            SimulatedScanInstance(minimumAttenuation: 78, secondsSinceLastScan: 263),
            SimulatedScanInstance(minimumAttenuation: 83, secondsSinceLastScan: 211),
            SimulatedScanInstance(minimumAttenuation: 73, secondsSinceLastScan: 228),
            SimulatedScanInstance(minimumAttenuation: 76, secondsSinceLastScan: 183),
            SimulatedScanInstance(minimumAttenuation: 66, secondsSinceLastScan: 189),
            SimulatedScanInstance(minimumAttenuation: 70, secondsSinceLastScan: 190),
        ]
    }

}

@available(iOS 13.7, *)
private class SimulatedScanInstance: ENScanInstance {

    private var _minimumAttenuation: ENAttenuation
    private var _secondsSinceLastScan: Int

    init(minimumAttenuation: ENAttenuation, secondsSinceLastScan: Int) {
        _minimumAttenuation = minimumAttenuation
        _secondsSinceLastScan = secondsSinceLastScan
    }

    override var minimumAttenuation: ENAttenuation {
        _minimumAttenuation
    }

    override var secondsSinceLastScan: Int {
        _secondsSinceLastScan
    }

}
