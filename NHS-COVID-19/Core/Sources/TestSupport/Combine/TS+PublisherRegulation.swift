//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation

extension TS {
    
    public class PublisherRegulationMonitor {
        private var isEnabled = [PublisherEventKind: CurrentValueSubject<Bool, Never>]()
        fileprivate var currentRegulationKind: PublisherEventKind?
        
        public func isBeingRegualted(as kind: PublisherEventKind) -> Bool {
            kind == currentRegulationKind
        }
        
        public func pauseEvents(for kind: PublisherEventKind) {
            enabledSubject(for: kind).value = false
        }
        
        public func resumeEvents(for kind: PublisherEventKind) {
            enabledSubject(for: kind).value = true
        }
        
        fileprivate func enabledSubject(for kind: PublisherEventKind) -> CurrentValueSubject<Bool, Never> {
            isEnabled.get(kind) { CurrentValueSubject<Bool, Never>(true) }
        }
    }
    
    public static func capturePublisherRegulations<Output>(in work: (PublisherRegulationMonitor) throws -> Output) rethrows -> Output {
        let monitor = PublisherRegulationMonitor()
        return try __CombineTesting.withRegulator(Regulator(monitor: monitor)) {
            try work(monitor)
        }
    }
    
}

private class Regulator: __CombineTestingRegulator {
    var monitor: TS.PublisherRegulationMonitor
    init(monitor: TS.PublisherRegulationMonitor) {
        self.monitor = monitor
    }
    
    func regulate<T>(_ publisher: T, as kind: PublisherEventKind) -> AnyPublisher<T.Output, T.Failure> where T: Publisher {
        RegulatedPublisher(base: publisher, kind: kind, monitor: monitor)
            .eraseToAnyPublisher()
    }
}

private struct RegulatedPublisher<Base: Publisher>: Publisher {
    typealias Output = Base.Output
    typealias Failure = Base.Failure
    
    var base: Base
    var kind: PublisherEventKind
    var monitor: TS.PublisherRegulationMonitor
    
    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        base.receive(subscriber: RegulatedSubscriber(base: subscriber, kind: kind, monitor: monitor))
    }
    
}

private class RegulatedSubscriber<Base: Subscriber>: Subscriber {
    typealias Input = Base.Input
    typealias Failure = Base.Failure
    
    private let base: Base
    private let kind: PublisherEventKind
    private let monitor: TS.PublisherRegulationMonitor
    
    private var isEnabledCancellable: AnyCancellable?
    private var bufferedInputs = [Base.Input]()
    private var bufferedCompletion: Subscribers.Completion<Base.Failure>?
    private var isEnabled = true {
        didSet {
            flushIfNeeded()
        }
    }
    
    init(
        base: Base,
        kind: PublisherEventKind,
        monitor: TS.PublisherRegulationMonitor
    ) {
        self.base = base
        self.kind = kind
        self.monitor = monitor
        let isEnabled = monitor.enabledSubject(for: kind)
        isEnabledCancellable = isEnabled.assign(to: \.isEnabled, on: self)
    }
    
    func receive(subscription: Subscription) {
        base.receive(subscription: subscription)
    }
    
    func receive(_ input: Base.Input) -> Subscribers.Demand {
        if isEnabled {
            regulate {
                _ = base.receive(input)
            }
        } else {
            bufferedInputs.append(input)
        }
        
        return .unlimited
    }
    
    func receive(completion: Subscribers.Completion<Base.Failure>) {
        if isEnabled {
            regulate {
                base.receive(completion: completion)
            }
        } else {
            bufferedCompletion = completion
        }
    }
    
    private func flushIfNeeded() {
        guard isEnabled else { return }
        
        regulate {
            bufferedInputs.forEach { _ = base.receive($0) }
            bufferedInputs.removeAll()
            
            if let bufferedCompletion = bufferedCompletion {
                base.receive(completion: bufferedCompletion)
            }
        }
    }
    
    private func regulate(work: () -> Void) {
        monitor.currentRegulationKind = kind
        defer { monitor.currentRegulationKind = nil }
        
        work()
    }
}
