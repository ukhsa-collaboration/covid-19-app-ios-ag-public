//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Foundation

public class PublisherEventKind: Hashable, CustomStringConvertible {
    private let label: String
    fileprivate let regulator: PublisherRegulator

    public init(label: String = "\(#file).\(#function)L\(#line)", regulator: PublisherRegulator) {
        self.label = label
        self.regulator = regulator
    }

    public static func == (lhs: PublisherEventKind, rhs: PublisherEventKind) -> Bool {
        lhs === rhs
    }

    public var description: String {
        "\(Self.self)(\(label))"
    }

    public func hash(into hasher: inout Hasher) {
        label.hash(into: &hasher)
    }
}

extension Publisher {

    public func regulate(as kind: PublisherEventKind) -> AnyPublisher<Output, Failure> {
        if let testingRegulator = Thread.current.__testingRegulator {
            return testingRegulator.regulate(self, as: kind)
        } else {
            return kind.regulator.regulate(self)
        }
    }

}

extension PublisherEventKind {

    public static func receive<S>(on scheduler: S, options: S.SchedulerOptions? = nil, label: String = "\(#file).\(#function)L\(#line)") -> PublisherEventKind where S: Scheduler {
        PublisherEventKind(
            label: label,
            regulator: ReceiveOnRegulator(scheduler: scheduler, options: options)
        )
    }

    public static func debounce<S>(for dueTime: S.SchedulerTimeType.Stride, scheduler: S, options: S.SchedulerOptions? = nil, label: String = "\(#file).\(#function)L\(#line)") -> PublisherEventKind where S: Scheduler {
        PublisherEventKind(
            label: label,
            regulator: DebounceRegulator(scheduler: scheduler, options: options, dueTime: dueTime)
        )
    }

}

public protocol __CombineTestingRegulator {
    func regulate<T: Publisher>(_ publisher: T, as kind: PublisherEventKind) -> AnyPublisher<T.Output, T.Failure>
}

public enum __CombineTesting {
    public static func withRegulator<Output>(_ regulator: __CombineTestingRegulator, perform work: () throws -> Output) rethrows -> Output {
        let thread = Thread.current
        let previousRegulator = thread.__testingRegulator
        thread.__testingRegulator = regulator
        defer {
            thread.__testingRegulator = previousRegulator
        }
        return try work()
    }
}

private extension Thread {

    private static let key = UUID().uuidString

    var __testingRegulator: __CombineTestingRegulator? {
        get {
            threadDictionary[type(of: self).key] as? __CombineTestingRegulator
        }
        set {
            threadDictionary[type(of: self).key] = newValue
        }
    }

}

private struct ReceiveOnRegulator<SchedulerType: Scheduler>: PublisherRegulator {

    var scheduler: SchedulerType
    var options: SchedulerType.SchedulerOptions?

    func regulate<T>(_ publisher: T) -> AnyPublisher<T.Output, T.Failure> where T: Publisher {
        publisher
            .receive(on: scheduler, options: options)
            .eraseToAnyPublisher()
    }
}

private struct DebounceRegulator<SchedulerType: Scheduler>: PublisherRegulator {

    var scheduler: SchedulerType
    var options: SchedulerType.SchedulerOptions?
    var dueTime: SchedulerType.SchedulerTimeType.Stride

    func regulate<T>(_ publisher: T) -> AnyPublisher<T.Output, T.Failure> where T: Publisher {
        publisher
            .debounce(for: dueTime, scheduler: scheduler, options: options)
            .eraseToAnyPublisher()
    }
}
