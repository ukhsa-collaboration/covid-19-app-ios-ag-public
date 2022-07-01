//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Domain
import ExposureNotification
import TestSupport
import XCTest
@testable import Integration
@testable import Scenarios

@available(iOS 13.7, *)
extension AnalyticsTests {
    struct FieldAsserter {
        private var fieldAssertions: [KeyPath<SubmissionPayload.Metrics, Int?>: FieldAssertion] = [
            \.runningNormallyBackgroundTick: Ignore(path: \.runningNormallyBackgroundTick),
            \.totalBackgroundTasks: Ignore(path: \.totalBackgroundTasks),
            \.appIsContactTraceableBackgroundTick: Ignore(path: \.appIsContactTraceableBackgroundTick),
            \.appIsUsableBackgroundTick: Ignore(path: \.appIsUsableBackgroundTick),
            \.appIsUsableBluetoothOffBackgroundTick: Ignore(path: \.appIsUsableBluetoothOffBackgroundTick),
             \.hasRiskyContactNotificationsEnabledBackgroundTick: Ignore(path: \.hasRiskyContactNotificationsEnabledBackgroundTick),
             \.totalShareExposureKeysReminderNotifications: Ignore(path: \.totalShareExposureKeysReminderNotifications),
        ]

        mutating func equals(expected: Int?, _ path: WritableKeyPath<SubmissionPayload.Metrics, Int?>) {
            fieldAssertions[path] = AssertEquals(expected: expected, path: path)
        }

        mutating func isPresent(_ path: WritableKeyPath<SubmissionPayload.Metrics, Int?>) {
            fieldAssertions[path] = AssertPresent(path: path)
        }

        mutating func isNotPresent(_ path: WritableKeyPath<SubmissionPayload.Metrics, Int?>) {
            fieldAssertions[path] = AssertNotPresent(path: path)
        }

        mutating func isNil(_ path: WritableKeyPath<SubmissionPayload.Metrics, Int?>) {
            fieldAssertions[path] = AssertIsNil(path: path)
        }

        mutating func isLessThanTotalBackgroundTasks(_ path: WritableKeyPath<SubmissionPayload.Metrics, Int?>) {
            fieldAssertions[path] = AssertLessThanTotalBackgroundTasks(path: path)
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

    private struct AssertNotPresent: FieldAssertion {
        let expected: Int? = 0
        let path: WritableKeyPath<SubmissionPayload.Metrics, Int?>

        func assert(metrics: SubmissionPayload.Metrics, day: Int?) -> Bool {
            return metrics[keyPath: path] == 0
        }
    }

    private struct AssertIsNil: FieldAssertion {
        let expected: Int? = nil
        let path: WritableKeyPath<SubmissionPayload.Metrics, Int?>

        func assert(metrics: SubmissionPayload.Metrics, day: Int?) -> Bool {
            return metrics[keyPath: path] == expected
        }
    }

    private struct AssertLessThanTotalBackgroundTasks: FieldAssertion {
        let expected: Int? = nil
        let path: WritableKeyPath<SubmissionPayload.Metrics, Int?>

        func assert(metrics: SubmissionPayload.Metrics, day: Int?) -> Bool {
            let actualValue = metrics[keyPath: path]
            let totalBackgroundTasks = metrics[keyPath: \.totalBackgroundTasks]
            if let actualValue = actualValue, let totalBackgroundTasksValue = totalBackgroundTasks {
                return actualValue < totalBackgroundTasksValue
            } else {
                return false
            }
        }
    }
}

protocol FieldAssertion {
    var path: WritableKeyPath<SubmissionPayload.Metrics, Int?> { get }
    var expected: Int? { get }

    func assert(metrics: SubmissionPayload.Metrics, day: Int?) -> Bool
}
