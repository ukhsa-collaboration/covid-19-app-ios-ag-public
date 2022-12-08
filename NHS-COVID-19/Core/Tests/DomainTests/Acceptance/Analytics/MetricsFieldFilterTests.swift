//
// Copyright © 2022 DHSC. All rights reserved.
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
class MetricsFieldFilterTests: AcceptanceTestCase {
    private var cancellables = [AnyCancellable]()
    private var metricsPayloads: [SubmissionPayload] = []

    override func setUpWithError() throws {
        subscribeToMetricsRequests()
    }

    func testPayloadWalesFeaturesOff() throws {
        configure(
            postcode: "CF71",
            localAuthority: LocalAuthority(
                name: "Vale of Glamorgan",
                id: .init("W06000014"),
                country: .wales
            ),
            enabledFeatures: []
        )

        advanceToEndOfAnalyticsWindow()

        assertOnLastFields { assertField in

            // Venue check in
            assertField.equals(expected: nil, \.receivedRiskyVenueM2Warning)
            assertField.equals(expected: nil, \.hasReceivedRiskyVenueM2WarningBackgroundTick)
            assertField.equals(expected: nil, \.didAccessRiskyVenueM2Notification)
            assertField.equals(expected: nil, \.selectedTakeTestM2Journey)
            assertField.equals(expected: nil, \.selectedTakeTestLaterM2Journey)
            assertField.equals(expected: nil, \.selectedHasSymptomsM2Journey)
            assertField.equals(expected: nil, \.selectedHasNoSymptomsM2Journey)
            assertField.equals(expected: nil, \.selectedLFDTestOrderingM2Journey)
            assertField.equals(expected: nil, \.selectedHasLFDTestM2Journey)
            assertField.equals(expected: nil, \.receivedRiskyVenueM1Warning)

            // Contact opt out flow
            assertField.equals(expected: nil, \.acknowledgedStartOfIsolationDueToRiskyContact)
            assertField.equals(expected: nil, \.isIsolatingForHadRiskyContactBackgroundTick)

            // Self isolation hub
            assertField.equals(expected: nil, \.didAccessSelfIsolationNoteLink)
            assertField.equals(expected: nil, \.receivedActiveIpcToken)
            assertField.equals(expected: nil, \.haveActiveIpcTokenBackgroundTick)
            assertField.equals(expected: nil, \.selectedIsolationPaymentsButton)
            assertField.equals(expected: nil, \.launchedIsolationPaymentsApplication)

            // Self reporting
            assertField.equals(expected: nil, \.selfReportedVoidSelfLFDTestResultEnteredManually)
            assertField.equals(expected: nil, \.selfReportedNegativeSelfLFDTestResultEnteredManually)
            assertField.equals(expected: nil, \.isPositiveSelfLFDFree)
            assertField.equals(expected: nil, \.selfReportedPositiveSelfLFDOnGov)
            assertField.equals(expected: nil, \.completedSelfReportingTestFlow)
        }
    }

    func testPayloadEnglandFeaturesOff() throws {
        configure(
            postcode: "B44",
            localAuthority: LocalAuthority(
                name: "Local Authority 1",
                id: .init("LA1"),
                country: .england
            ),
            enabledFeatures: []
        )

        advanceToEndOfAnalyticsWindow()

        assertOnLastFields { assertField in
            // Venue check in
            assertField.equals(expected: nil, \.receivedRiskyVenueM2Warning)
            assertField.equals(expected: nil, \.hasReceivedRiskyVenueM2WarningBackgroundTick)
            assertField.equals(expected: nil, \.didAccessRiskyVenueM2Notification)
            assertField.equals(expected: nil, \.selectedTakeTestM2Journey)
            assertField.equals(expected: nil, \.selectedTakeTestLaterM2Journey)
            assertField.equals(expected: nil, \.selectedHasSymptomsM2Journey)
            assertField.equals(expected: nil, \.selectedHasNoSymptomsM2Journey)
            assertField.equals(expected: nil, \.selectedLFDTestOrderingM2Journey)
            assertField.equals(expected: nil, \.selectedHasLFDTestM2Journey)
            assertField.equals(expected: nil, \.receivedRiskyVenueM1Warning)

            // Contact opt out flow
            assertField.equals(expected: nil, \.acknowledgedStartOfIsolationDueToRiskyContact)
            assertField.equals(expected: nil, \.isIsolatingForHadRiskyContactBackgroundTick)

            // Self isolation hub
            assertField.equals(expected: nil, \.didAccessSelfIsolationNoteLink)
            assertField.equals(expected: nil, \.receivedActiveIpcToken)
            assertField.equals(expected: nil, \.haveActiveIpcTokenBackgroundTick)
            assertField.equals(expected: nil, \.selectedIsolationPaymentsButton)
            assertField.equals(expected: nil, \.launchedIsolationPaymentsApplication)

            // Self reporting
            assertField.equals(expected: nil, \.selfReportedVoidSelfLFDTestResultEnteredManually)
            assertField.equals(expected: nil, \.selfReportedNegativeSelfLFDTestResultEnteredManually)
            assertField.equals(expected: nil, \.isPositiveSelfLFDFree)
            assertField.equals(expected: nil, \.selfReportedPositiveSelfLFDOnGov)
            assertField.equals(expected: nil, \.completedSelfReportingTestFlow)
        }

    }

    func testPayloadWalesFeaturesOn() throws {
        configure(
            postcode: "CF71",
            localAuthority: LocalAuthority(
                name: "Vale of Glamorgan",
                id: .init("W06000014"),
                country: .wales
            ),
            enabledFeatures: [
                .localStatistics,
                .venueCheckIn,
                .contactOptOutFlowEngland,
                .contactOptOutFlowWales,
                .testingForCOVID19,
                .selfIsolationHubEngland,
                .selfIsolationHubWales,
                .guidanceHubEngland,
                .guidanceHubWales,
                .selfReporting,
            ]
        )

        advanceToEndOfAnalyticsWindow()

        assertOnLastFields { _ in }
    }

    func testPayloadEnglandFeaturesOn() throws {
        configure(
            postcode: "B44",
            localAuthority: LocalAuthority(
                name: "Local Authority 1",
                id: .init("LA1"),
                country: .england
            ),
            enabledFeatures: [
                .localStatistics,
                .venueCheckIn,
                .contactOptOutFlowEngland,
                .contactOptOutFlowWales,
                .testingForCOVID19,
                .selfIsolationHubEngland,
                .selfIsolationHubWales,
                .guidanceHubEngland,
                .guidanceHubWales,
                .selfReporting,
            ]
        )

        advanceToEndOfAnalyticsWindow()

        assertOnLastFields { _ in }

    }

    func testPayloadWithWalesFeaturesOffAndEnglandFeatureOn() throws {
        configure(
            postcode: "CF71",
            localAuthority: LocalAuthority(
                name: "Vale of Glamorgan",
                id: .init("W06000014"),
                country: .wales
            ),
            enabledFeatures: [
                .localStatistics,
                .venueCheckIn,
                .contactOptOutFlowEngland,
                .testingForCOVID19,
                .selfIsolationHubEngland,
                .guidanceHubEngland,
                .selfReporting,
            ]
        )

        advanceToEndOfAnalyticsWindow()

        assertOnLastFields { assertField in
            // Contact opt out flow
            assertField.equals(expected: nil, \.acknowledgedStartOfIsolationDueToRiskyContact)
            assertField.equals(expected: nil, \.isIsolatingForHadRiskyContactBackgroundTick)

            // Self isolation hub
            assertField.equals(expected: nil, \.didAccessSelfIsolationNoteLink)
            assertField.equals(expected: nil, \.receivedActiveIpcToken)
            assertField.equals(expected: nil, \.haveActiveIpcTokenBackgroundTick)
            assertField.equals(expected: nil, \.selectedIsolationPaymentsButton)
            assertField.equals(expected: nil, \.launchedIsolationPaymentsApplication)
        }
    }

    func testPayloadWithEnglandFeaturesOffAndWalesFeatureOn() throws {
        configure(
            postcode: "B44",
            localAuthority: LocalAuthority(
                name: "Local Authority 1",
                id: .init("LA1"),
                country: .england
            ),
            enabledFeatures: [
                .localStatistics,
                .venueCheckIn,
                .contactOptOutFlowWales,
                .testingForCOVID19,
                .selfIsolationHubWales,
                .guidanceHubWales,
                .selfReporting,
            ]
        )

        advanceToEndOfAnalyticsWindow()

        assertOnLastFields { assertField in
            // Contact opt out flow
            assertField.equals(expected: nil, \.acknowledgedStartOfIsolationDueToRiskyContact)
            assertField.equals(expected: nil, \.isIsolatingForHadRiskyContactBackgroundTick)

            // Self isolation hub
            assertField.equals(expected: nil, \.didAccessSelfIsolationNoteLink)
            assertField.equals(expected: nil, \.receivedActiveIpcToken)
            assertField.equals(expected: nil, \.haveActiveIpcTokenBackgroundTick)
            assertField.equals(expected: nil, \.selectedIsolationPaymentsButton)
            assertField.equals(expected: nil, \.launchedIsolationPaymentsApplication)
        }
    }
}

@available(iOS 13.7, *)
extension MetricsFieldFilterTests {
    var lastMetricsPayload: SubmissionPayload? {
        metricsPayloads.last
    }

    func subscribeToMetricsRequests() {
        apiClient.$lastRequest.sink { request in
            guard let request = request,
                let body = request.body,
                request.path == "/submission/mobile-analytics" else {
                return
            }

            let decoder = JSONDecoder()
            do {
                let metricsPayload = try decoder.decode(SubmissionPayload.self, from: body.content)
                self.metricsPayloads.append(metricsPayload)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        .store(in: &cancellables)
    }

    func assertOnLastFields(assertions: (inout FieldAsserter) -> Void) {
        assertOnLastPacket(assertions: assertions)
    }

    private func assertOnLastPacket(assertions: (inout FieldAsserter) -> Void, day: Int? = nil) {
        var fieldAsserter = FieldAsserter()
        assertions(&fieldAsserter)
        fieldAsserter.runAllAssertions(metrics: lastMetricsPayload!.metrics, day: day)
    }

    private func configure(postcode: String, localAuthority: LocalAuthority, enabledFeatures: [Feature]) {
        $instance.postcode = Postcode(postcode)
        $instance.localAuthority = localAuthority
        $instance.enabledFeatures = enabledFeatures

        try! completeRunning(postcode: postcode, localAuthority: localAuthority)
    }

    private func performBackgroundTask() {
        coordinator.performBackgroundTask(task: NoOpBackgroundTask())
    }

    private func advanceToEndOfAnalyticsWindow() {
        currentDateProvider.advanceToEndOfAnalyticsWindow(
            steps: 12,
            performBackgroundTask: performBackgroundTask
        )
    }
}

@available(iOS 13.7, *)
extension MetricsFieldFilterTests {
    struct FieldAsserter {
        private var fieldAssertions: [KeyPath<SubmissionPayload.Metrics, Int?>: FieldAssertion] = [
            \.runningNormallyBackgroundTick: Ignore(path: \.runningNormallyBackgroundTick),
            \.totalBackgroundTasks: Ignore(path: \.totalBackgroundTasks),
            \.appIsContactTraceableBackgroundTick: Ignore(path: \.appIsContactTraceableBackgroundTick),
            \.appIsUsableBackgroundTick: Ignore(path: \.appIsUsableBackgroundTick),
            \.appIsUsableBluetoothOffBackgroundTick: Ignore(path: \.appIsUsableBluetoothOffBackgroundTick),
             \.hasRiskyContactNotificationsEnabledBackgroundTick: Ignore(path: \.hasRiskyContactNotificationsEnabledBackgroundTick)
        ]

        mutating func equals(expected: Int?, _ path: WritableKeyPath<SubmissionPayload.Metrics, Int?>) {
            fieldAssertions[path] = AssertEquals(expected: expected, path: path)
        }

        mutating func isPresent(_ path: WritableKeyPath<SubmissionPayload.Metrics, Int?>) {
            fieldAssertions[path] = AssertPresent(path: path)
        }

        func runAllAssertions(metrics: SubmissionPayload.Metrics, day: Int? = nil) {
            var expected = SubmissionPayload.Metrics()

            for field in fieldAssertions.values {
                if field.assert(metrics: metrics, day: day) {
                    expected[keyPath: field.path] = metrics[keyPath: field.path]
                } else {
                    expected[keyPath: field.path] = field.expected
                }
            }

            if let day = day {
                TS.assert(metrics, equals: expected, "Failed on day \(day)")
            } else {
                TS.assert(metrics, equals: expected)
            }
        }
    }

    private struct Ignore: FieldAssertion {
        let expected: Int? = -1
        let path: WritableKeyPath<SubmissionPayload.Metrics, Int?>

        func assert(metrics: SubmissionPayload.Metrics, day: Int?) -> Bool { true }
    }

    private struct AssertEquals: FieldAssertion {
        let expected: Int?
        let path: WritableKeyPath<SubmissionPayload.Metrics, Int?>

        func assert(metrics: SubmissionPayload.Metrics, day: Int?) -> Bool {
            return expected == metrics[keyPath: path]
        }
    }

    private struct AssertPresent: FieldAssertion {
        let expected: Int? = nil
        let path: WritableKeyPath<SubmissionPayload.Metrics, Int?>

        func assert(metrics: SubmissionPayload.Metrics, day: Int?) -> Bool {
            if let metricsValue: Int = metrics[keyPath: path] {
                return metricsValue > 0
            } else {
                return false
            }
        }
    }
}
