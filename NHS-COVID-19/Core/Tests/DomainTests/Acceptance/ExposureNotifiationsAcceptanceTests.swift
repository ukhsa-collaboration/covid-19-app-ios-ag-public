//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import ExposureNotification
import TestSupport
import XCTest
@testable import Domain
@testable import Integration
@testable import Scenarios

@available(iOS 13.7, *)
class ExposureNotifiationsAcceptanceTests: AcceptanceTestCase {
    private var cancellables = [AnyCancellable]()

    private let startDay = GregorianDay(year: 2020, month: 1, day: 1)
    private var riskyContact: RiskyContact!

    func testAppSkipsDownloadingENBatchFilesThatItHasAlreadyProcessed() throws {
        try completeRunningAndProcessENUntilStartDay()

        // four hours pass without any background tasks…
        // *note* the 1 minute is there because we skip running EN unless it's been *more than* 4 hours since the last run
        let futureDate = UTCHour(day: startDay, hour: 4, minutes: 1).date
        currentDateProvider.setDate(futureDate)

        distributeClient.reset()
        distributeClient.register(ExposureConfigurationHandler())
        registerExtraAPIClients()

        try performAndCompleteBackgorundTasks()

        let requestPaths = Set(distributeClient.requests.map { $0.path })

        // There should be no (daily or two-hourly) requests for files that are already processed
        for day in 20191219 ... 20191231 {
            let unexpectedRequestPath = requestPaths.filter { $0.contains("\(day)") }.sorted()
            XCTAssert(unexpectedRequestPath.isEmpty, "Unexpectedly requested old files: \(unexpectedRequestPath)")
        }

        // There should be two-hourly requests for recent times
        // There should be a request for the oldest, valid daily requests
        XCTAssert(requestPaths.contains("/distribution/two-hourly/2020010102.zip"))
        XCTAssert(requestPaths.contains("/distribution/two-hourly/2020010104.zip"))

        // but not for future dates
        XCTAssertFalse(requestPaths.contains("/distribution/two-hourly/2020010106.zip"))
    }

    func testAppSkipsDownloadingENFilesUnlessMoreThanFourHoursHasPassed() throws {
        try completeRunningAndProcessENUntilStartDay()

        // four hours pass without any background tasks…
        let futureDate = UTCHour(day: startDay, hour: 4).date
        currentDateProvider.setDate(futureDate)

        distributeClient.reset()
        distributeClient.register(ExposureConfigurationHandler())
        registerExtraAPIClients()

        try performAndCompleteBackgorundTasks()

        let requestPaths = Set(distributeClient.requests.map { $0.path })

        // There should be no (daily or two-hourly) requests for files that are already processed
        let unexpectedRequestPath = requestPaths.filter { $0.contains(".zip") }.sorted()
        XCTAssertFalse(unexpectedRequestPath.contains("/distribution/exposure-configuration"), "Should not run EN unless more than 4 hours has passed")
    }

    func testAppSkipsDownloadingENBatchFilesThatAreTooOld() throws {
        try completeRunningAndProcessENUntilStartDay()

        // one month passes without any background tasks…
        let futureDate = GregorianDay(year: 2020, month: 2, day: 1).startDate(in: .utc)
        currentDateProvider.setDate(futureDate)

        distributeClient.reset()
        distributeClient.register(ExposureConfigurationHandler())
        registerExtraAPIClients()

        try performAndCompleteBackgorundTasks()

        let requestPaths = Set(distributeClient.requests.map { $0.path })

        // There should be no (daily or two-hourly) requests for files that are too old
        for day in 20200101 ... 20200118 {
            let unexpectedRequestPath = requestPaths.filter { $0.contains("\(day)") }.sorted()
            XCTAssert(unexpectedRequestPath.isEmpty, "Unexpectedly requested old files: \(unexpectedRequestPath)")
        }

        // There should be a request for the oldest, valid daily requests
        XCTAssertTrue(requestPaths.contains("/distribution/daily/2020011900.zip"))
    }

    private func completeRunningAndProcessENUntilStartDay() throws {
        $instance.exposureNotificationManager = MockWindowsExposureNotificationManager()
        currentDateProvider.setDate(startDay.startDate(in: .utc))

        distributeClient.register(ExposureConfigurationHandler())
        registerExtraAPIClients()

        for day in 20191219 ... 20191231 {
            distributeClient.response(for: "/distribution/daily/\(day)00.zip", response: KeysDistributionHandler.response())
        }
        ["/distribution/two-hourly/2019123102.zip", "/distribution/two-hourly/2019123104.zip", "/distribution/two-hourly/2019123106.zip", "/distribution/two-hourly/2019123108.zip", "/distribution/two-hourly/2019123110.zip", "/distribution/two-hourly/2019123112.zip", "/distribution/two-hourly/2019123114.zip", "/distribution/two-hourly/2019123116.zip", "/distribution/two-hourly/2019123118.zip", "/distribution/two-hourly/2019123120.zip", "/distribution/two-hourly/2019123122.zip", "/distribution/two-hourly/2020010100.zip"].forEach {
            distributeClient.response(for: $0, response: KeysDistributionHandler.response())
        }

        try completeRunning()

        struct BGState: Decodable {
            var lastKeyDownloadDate: Date
        }

        let state = try JSONDecoder().decode(BGState.self, from: XCTUnwrap($instance.encryptedStore.stored["background_task_state"]))
        // Note, it's important to assert that this is saved to make sure background tasks as part of `completeRunning` have finished.
        TS.assert(state.lastKeyDownloadDate, equals: startDay.startDate(in: .utc))

    }

    private func registerExtraAPIClients() {
        #warning("This should not be necessary")
        // For some reason `CircuitBreakerClient.sendObfuscatedTraffic` can end in a way that blocks the background
        // tasks from completing. This seems to be some concurrency issue around when publisher event messages are sent.
        // Not sure if it’s our bug or OS bug.
        //
        // For now, register an empty handler so we don't run into that edge case.
        apiClient.register(EmptyHandler())
    }
}

private extension AcceptanceTestCase {

    func performAndCompleteBackgorundTasks() throws {
        let task = AcceptanceBackgroundTask()
        coordinator.performBackgroundTask(task: task)

        if !(try task.$completed.filter { $0 }.await(timeout: 5).get()) {
            throw TestError("Did not complete")
        }
    }

}

private class AcceptanceBackgroundTask: BackgroundJob {
    var identifier = ""

    @Published
    private(set) var completed = false

    var expirationHandler: (() -> Void)? {
        get {
            nil
        }
        set {}
    }

    func setTaskCompleted(success: Bool) {
        completed = true
    }
}
