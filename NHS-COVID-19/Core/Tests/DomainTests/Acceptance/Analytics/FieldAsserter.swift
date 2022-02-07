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
        private var fieldAssertions: [KeyPath<SubmissionPayload.Metrics, SubmissionPayload.MetricField>: FieldAssertion] = [
            \.hasSelfDiagnosedPositiveBackgroundTick: Ignore(path: \.hasSelfDiagnosedPositiveBackgroundTick),
            \.runningNormallyBackgroundTick: Ignore(path: \.runningNormallyBackgroundTick),
            \.totalBackgroundTasks: Ignore(path: \.totalBackgroundTasks),
            \.appIsContactTraceableBackgroundTick: Ignore(path: \.appIsContactTraceableBackgroundTick),
            \.appIsUsableBackgroundTick: Ignore(path: \.appIsUsableBackgroundTick),
            \.appIsUsableBluetoothOffBackgroundTick: Ignore(path: \.appIsUsableBluetoothOffBackgroundTick),
        ]
        
        mutating func equals(expected: SubmissionPayload.MetricField, _ path: WritableKeyPath<SubmissionPayload.Metrics, SubmissionPayload.MetricField>) {
            fieldAssertions[path] = AssertEquals(expected: expected, path: path)
        }
        
        mutating func isPresent(_ path: WritableKeyPath<SubmissionPayload.Metrics, SubmissionPayload.MetricField>) {
            fieldAssertions[path] = AssertPresent(path: path)
        }
        
        mutating func isNotPresent(_ path: WritableKeyPath<SubmissionPayload.Metrics, SubmissionPayload.MetricField>) {
            fieldAssertions[path] = AssertNotPresent(path: path)
        }
        
        mutating func isLessThanTotalBackgroundTasks(_ path: WritableKeyPath<SubmissionPayload.Metrics, SubmissionPayload.MetricField>) {
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
        let expected: SubmissionPayload.MetricField = -1
        let path: WritableKeyPath<SubmissionPayload.Metrics, SubmissionPayload.MetricField>
        
        func assert(metrics: SubmissionPayload.Metrics, day: Int?) -> Bool { true }
    }
    
    private struct AssertEquals: FieldAssertion {
        let expected: SubmissionPayload.MetricField
        let path: WritableKeyPath<SubmissionPayload.Metrics, SubmissionPayload.MetricField>
        
        func assert(metrics: SubmissionPayload.Metrics, day: Int?) -> Bool {
            return expected == metrics[keyPath: path]
        }
    }
    
    private struct AssertPresent: FieldAssertion {
        let expected: SubmissionPayload.MetricField = .notZero
        let path: WritableKeyPath<SubmissionPayload.Metrics, SubmissionPayload.MetricField>
        
        func assert(metrics: SubmissionPayload.Metrics, day: Int?) -> Bool {
            return metrics[keyPath: path].value > 0
        }
    }
    
    private struct AssertNotPresent: FieldAssertion {
        let expected: SubmissionPayload.MetricField = 0
        let path: WritableKeyPath<SubmissionPayload.Metrics, SubmissionPayload.MetricField>
        
        func assert(metrics: SubmissionPayload.Metrics, day: Int?) -> Bool {
            return metrics[keyPath: path] == 0
        }
    }
    
    private struct AssertLessThanTotalBackgroundTasks: FieldAssertion {
        let expected: SubmissionPayload.MetricField = .lessThanTotalBackgroundTasks
        let path: WritableKeyPath<SubmissionPayload.Metrics, SubmissionPayload.MetricField>
        
        func assert(metrics: SubmissionPayload.Metrics, day: Int?) -> Bool {
            let actual = metrics[keyPath: path]
            let totalBackgroundTasks = metrics[keyPath: \.totalBackgroundTasks]
            return actual.value < totalBackgroundTasks.value
        }
    }
}

protocol FieldAssertion {
    var path: WritableKeyPath<SubmissionPayload.Metrics, SubmissionPayload.MetricField> { get }
    var expected: SubmissionPayload.MetricField { get }
    
    func assert(metrics: SubmissionPayload.Metrics, day: Int?) -> Bool
}
