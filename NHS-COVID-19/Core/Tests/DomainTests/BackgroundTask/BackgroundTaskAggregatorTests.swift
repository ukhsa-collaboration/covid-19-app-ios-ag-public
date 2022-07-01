//
// Copyright © 2021 DHSC. All rights reserved.
//

import BackgroundTasks
import Combine
import Scenarios
import XCTest
@testable import Domain

class BackgroundTaskAggregatorTests: XCTestCase {

    func testBackgroundTaskRequestedOnInit() throws {
        let manager = MockProcessingTaskRequestManager()

        let work: () -> AnyPublisher<Void, Never> = {
            Empty().eraseToAnyPublisher()
        }

        let job = BackgroundTaskAggregator.Job(work: work)

        let before = Date()
        _ = BackgroundTaskAggregator(manager: manager, jobs: [job])

        let request = try XCTUnwrap(manager.request)
        XCTAssert(request.requiresNetworkConnectivity)
        let earliestBeginDate = try XCTUnwrap(request.earliestBeginDate)
        XCTAssertEqual(earliestBeginDate.timeIntervalSinceNow, 2.0 * 60 * 60, accuracy: max(1, -2 * before.timeIntervalSinceNow))
    }

    func testBackgroundTaskNotRequestedOnInitIfAlreadyRequestedAndTaskIsInFuture() throws {
        let work: () -> AnyPublisher<Void, Never> = {
            Empty().eraseToAnyPublisher()
        }

        let job = BackgroundTaskAggregator.Job(work: work)

        let manager = MockProcessingTaskRequestManager()
        manager.request = ProcessingTaskRequest()
        manager.request?.earliestBeginDate = Date(timeIntervalSinceNow: 100)

        _ = BackgroundTaskAggregator(manager: manager, jobs: [job])

        XCTAssertEqual(manager.submitCallCount, 0)
    }

    func testBackgroundTaskNotRequestedOnInitIfAlreadyRequestedAndTaskDateHasRecentlyPassed() throws {
        let work: () -> AnyPublisher<Void, Never> = {
            Empty().eraseToAnyPublisher()
        }

        let job = BackgroundTaskAggregator.Job(work: work)

        let manager = MockProcessingTaskRequestManager()
        manager.request = ProcessingTaskRequest()
        manager.request?.earliestBeginDate = Date(timeIntervalSinceNow: -3 * 60)

        _ = BackgroundTaskAggregator(manager: manager, jobs: [job])

        XCTAssertEqual(manager.submitCallCount, 0)
    }

    func testBackgroundTaskIsRequestedAgainOnInitIfAlreadyRequestedButIsInThePastMoreThanADay() throws {
        let work: () -> AnyPublisher<Void, Never> = {
            Empty().eraseToAnyPublisher()
        }

        let job = BackgroundTaskAggregator.Job(work: work)

        let manager = MockProcessingTaskRequestManager()
        manager.request = ProcessingTaskRequest()
        manager.request?.earliestBeginDate = Date(timeIntervalSinceNow: -86500)

        _ = BackgroundTaskAggregator(manager: manager, jobs: [job])

        XCTAssertEqual(manager.submitCallCount, 1)
    }

    func testBackgroundTaskNotRequestedOnInitIfThereAreNoJobs() throws {
        let manager = MockProcessingTaskRequestManager()

        _ = BackgroundTaskAggregator(manager: manager, jobs: [])

        XCTAssertEqual(manager.submitCallCount, 0)
    }

    func testTaskExpirationStopsWork() {
        let manager = MockProcessingTaskRequestManager()

        let task = MockBackgroundTask()
        var taskCancelled = false

        let job = BackgroundTaskAggregator.Job {
            PassthroughSubject<Void, Never>()
                .handleEvents(receiveCancel: {
                    taskCancelled = true
                })
                .eraseToAnyPublisher()
        }

        let backgroundTaskAggregator = BackgroundTaskAggregator(manager: manager, jobs: [job])

        backgroundTaskAggregator.performBackgroundTask(backgroundTask: task)

        task.expirationHandler?()

        XCTAssertTrue(taskCancelled)
    }

    func testBackgroundTaskJobIsExecuted() throws {
        let manager = MockProcessingTaskRequestManager()
        var workExecutionCount = 0

        let work: () -> AnyPublisher<Void, Never> = {
            workExecutionCount += 1
            return Empty().eraseToAnyPublisher()
        }

        let job = BackgroundTaskAggregator.Job(work: work)

        let backgroundTaskAggregator = BackgroundTaskAggregator(manager: manager, jobs: [job])

        backgroundTaskAggregator.performBackgroundTask(backgroundTask: MockBackgroundTask())
        XCTAssertEqual(workExecutionCount, 1)
    }

    func testBackgroundTaskJobNotExecutedAfterStop() throws {
        let manager = MockProcessingTaskRequestManager()

        let work: () -> AnyPublisher<Void, Never> = {
            Empty().eraseToAnyPublisher()
        }

        let job = BackgroundTaskAggregator.Job(work: work)

        let backgroundTaskAggregator = BackgroundTaskAggregator(manager: manager, jobs: [job])

        backgroundTaskAggregator.stop()
        XCTAssertNil(manager.request)
    }
}
