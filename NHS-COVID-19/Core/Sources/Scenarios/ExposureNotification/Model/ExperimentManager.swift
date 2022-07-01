//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import ExposureNotification
import ScenariosConfiguration
import UIKit

class ExperimentManager: ObservableObject {

    let client: HTTPClient
    let exposureManager = ExposureManager()

    private let application: UIApplication

    private var _objectWillChange = PassthroughSubject<Void, Never>()

    private var cancellables = [AnyCancellable]()

    @available(iOSApplicationExtension, unavailable)
    init() {
        application = .shared
        let fieldTestRemote = FieldTestConfiguration.shared.remote
        client = URLSessionHTTPClient(
            remote: HTTPRemote(
                host: fieldTestRemote.host,
                path: fieldTestRemote.path,
                headers: HTTPHeaders(fields: fieldTestRemote.headers)
            )
        )
        if deviceName.isEmpty, !UIDevice.current.name.lowercased().contains("iphone") {
            deviceName = UIDevice.current.name
        }
    }

    var objectWillChange: AnyPublisher<Void, Never> {
        _objectWillChange.eraseToAnyPublisher()
    }

    var isProcessingResults = false {
        didSet {
            _objectWillChange.send()
            application.isIdleTimerDisabled = isProcessingResults
        }
    }

    var usingEnApiVersion: Int {
        if let enApiVersionString = Bundle.main.object(forInfoDictionaryKey: "ENAPIVersion") as? String,
            let enApiVersionInt = Int(enApiVersionString) {
            return enApiVersionInt
        }
        return 1
    }

    var processingError: Error? {
        didSet {
            _objectWillChange.send()
        }
    }

    @UserDefault("experiment_role")
    var role: Experiment.Role? {
        didSet {
            _objectWillChange.send()
        }
    }

    @UserDefault("experiment_device_name", defaultValue: "")
    var deviceName: String {
        didSet {
            _objectWillChange.send()
        }
    }

    @UserDefault("experiment_team_name", defaultValue: "")
    var teamName: String {
        didSet {
            _objectWillChange.send()
        }
    }

    @UserDefault("experiment_id", defaultValue: "")
    var experimentId: String {
        didSet {
            _objectWillChange.send()
        }
    }

    @UserDefault("experiment_name", defaultValue: "")
    var experimentName: String {
        didSet {
            _objectWillChange.send()
        }
    }

    @UserDefault("experiment_automatic_detection_frequency", defaultValue: 0)
    var automaticDetectionFrequency: TimeInterval {
        didSet {
            _objectWillChange.send()
        }
    }

    func set(_ experiment: Experiment) {
        experimentName = experiment.experimentName
        experimentId = experiment.experimentId
        automaticDetectionFrequency = experiment.automaticDetectionFrequency ?? 0
    }

}

extension ExperimentManager {

    func startAutomaticDetection() {
        precondition(automaticDetectionFrequency > 0)
        isProcessingResults = true
        processingError = nil
        cancellables.append(
            Timer.publish(every: automaticDetectionFrequency, on: RunLoop.main, in: .common)
                .autoconnect()
                .prepend(Date())
                .flatMap { _ in self.postResults().replaceError(with: ()) }
                .sink { _ in }
        )
    }

    @available(iOS 13.7, *)
    func startAutomaticDetectionV2() {
        precondition(automaticDetectionFrequency > 0)
        isProcessingResults = true
        processingError = nil
        cancellables.append(
            Timer.publish(every: automaticDetectionFrequency, on: RunLoop.main, in: .common)
                .autoconnect()
                .prepend(Date())
                .flatMap { _ in self.postResultsV2().replaceError(with: ()) }
                .sink { _ in }
        )
    }

    func endAutomaticDetection() {
        isProcessingResults = false
        cancellables.removeAll()
    }

    func processResults() {
        isProcessingResults = true
        processingError = nil
        _processResults()
    }

    private func _processResults() {
        cancellables.append(
            postResults()
                .receive(on: RunLoop.main)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            self.processingError = nil
                        case .failure(let error):
                            self.processingError = error
                        }
                        self.isProcessingResults = false
                    },
                    receiveValue: { _ in
                    }
                )
        )
    }

    @available(iOS 13.7, *)
    func processResultsV2() {
        isProcessingResults = true
        processingError = nil
        _processResultsV2()
    }

    @available(iOS 13.7, *)
    private func _processResultsV2() {
        cancellables.append(
            postResultsV2()
                .receive(on: RunLoop.main)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            self.processingError = nil
                        case .failure(let error):
                            self.processingError = error
                        }
                        self.isProcessingResults = false
                    },
                    receiveValue: {}
                )
        )
    }

    private func postResults() -> AnyPublisher<Void, Error> {
        exposureManager.enabledManager()
            .flatMap { manager in
                self.getExperiment()
                    .flatMap { experiment in
                        manager.results(for: experiment)
                    }
                    .flatMap(Publishers.Sequence.init)
                    .flatMap { self.post($0) }
            }
            .eraseToAnyPublisher()
    }

    @available(iOS 13.7, *)
    private func postResultsV2() -> AnyPublisher<Void, Error> {
        exposureManager.enabledManager()
            .flatMap { manager in
                self.getExperimentV2()
                    .flatMap { experiment in
                        manager.resultsV2(for: experiment)
                    }
                    .flatMap(Publishers.Sequence.init)
                    .flatMap { self.post($0) }
            }
            .eraseToAnyPublisher()
    }

    private func getExperiment() -> AnyPublisher<Experiment, Error> {
        precondition(!experimentId.isEmpty)
        precondition(!teamName.isEmpty)
        let endpoint = GetExperimentEndpoint(
            team: teamName,
            experimentId: experimentId
        )
        return client.fetch(endpoint, with: ())
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

    @available(iOS 13.7, *)
    private func getExperimentV2() -> AnyPublisher<Experiment.ExperimentV2, Error> {
        precondition(!experimentId.isEmpty)
        precondition(!teamName.isEmpty)
        let endpoint = GetExperimentEndpointV2(
            team: teamName,
            experimentId: experimentId
        )
        return client.fetch(endpoint, with: ())
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

    private static let sema = DispatchSemaphore(value: 1)

    private func post(_ results: Experiment.DetectionResults) -> AnyPublisher<Void, Error> {
        precondition(!experimentId.isEmpty)
        precondition(!teamName.isEmpty)
        // synchronise posts to work around issue in the backend
        Self.sema.wait()
        let endpoint = SendResultsEndpoint(
            team: teamName,
            experimentId: experimentId,
            deviceName: deviceName
        )
        return client.fetch(endpoint, with: results)
            .mapError { $0 as Error }
            .handleEvents(
                receiveCompletion: { _ in Self.sema.signal() },
                receiveCancel: { Self.sema.signal() }
            )
            .eraseToAnyPublisher()
    }

    @available(iOS 13.7, *)
    private func post(_ results: Experiment.DetectionResultsV2) -> AnyPublisher<Void, Error> {
        precondition(!experimentId.isEmpty)
        precondition(!teamName.isEmpty)
        // synchronise posts to work around issue in the backend
        Self.sema.wait()
        let endpoint = SendResultsV2Endpoint(
            team: teamName,
            experimentId: experimentId,
            deviceName: deviceName
        )
        return client.fetch(endpoint, with: results)
            .mapError { $0 as Error }
            .handleEvents(
                receiveCompletion: { _ in Self.sema.signal() },
                receiveCancel: { Self.sema.signal() }
            )
            .eraseToAnyPublisher()
    }

}

extension ExperimentManager {

    func joinExperiment(manager: EnabledExposureManager) -> AnyPublisher<Experiment, Error> {
        let experimentEndpoint = GetExperimentEndpoint(team: teamName)
        return client.fetch(experimentEndpoint, with: ())
            .mapError { $0 as Error }
            .flatMap { experiment in
                self.localParticipant(manager: manager)
                    .flatMap { participant -> AnyPublisher<Experiment, Error> in
                        let enrolEndpoint = EnrolParticipantEndpoint(
                            team: self.teamName,
                            experimentId: experiment.experimentId
                        )
                        return self.client.fetch(enrolEndpoint, with: participant)
                            .mapError { $0 as Error }
                            .map { experiment }
                            .eraseToAnyPublisher()
                    }
            }
            .eraseToAnyPublisher()
    }

    func createExperiment(name: String, automaticDetectionFrequency: TimeInterval?, requestedConfigurations: [Experiment.RequestedConfiguration], manager: EnabledExposureManager) -> AnyPublisher<Experiment, Error> {
        let endpoint = CreateExperimentEndpoint(team: teamName)
        return localParticipant(manager: manager)
            .map {
                Experiment.Create(
                    usedExposureNotificationApiVersion: String(self.usingEnApiVersion),
                    experimentName: name,
                    automaticDetectionFrequency: automaticDetectionFrequency,
                    requestedConfigurations: requestedConfigurations,
                    lead: $0
                )
            }
            .flatMap {
                self.client.fetch(endpoint, with: $0)
                    .mapError { $0 as Error }
            }
            .eraseToAnyPublisher()
    }

    private func localParticipant(manager: EnabledExposureManager) -> AnyPublisher<Experiment.Participant, Error> {
        manager.getKeys()
            .map { Experiment.Participant(deviceName: self.deviceName, temporaryTracingKeys: $0) }
            .eraseToAnyPublisher()
    }

}

private extension EnabledExposureManager {

    func results(for experiment: Experiment) -> AnyPublisher<[Experiment.DetectionResults], Error> {
        Publishers.Sequence(sequence: experiment.requestedConfigurations)
            .flatMap { self.result(for: experiment, configuration: ENExposureConfiguration(from: $0)) }
            .collect()
            .eraseToAnyPublisher()
    }

    private func result(for experiment: Experiment, configuration: ENExposureConfiguration) -> AnyPublisher<Experiment.DetectionResults, Error> {
        Publishers.Sequence(sequence: experiment.participants)
            .flatMap { self.exposure(to: $0, configuration: configuration) }
            .collect()
            .map {
                Experiment.DetectionResults(
                    timestamp: Date(),
                    configuration: .init(configuration),
                    counterparts: $0
                )
            }
            .eraseToAnyPublisher()
    }

    @available(iOS 13.7, *)
    func resultsV2(for experiment: Experiment.ExperimentV2) -> AnyPublisher<[Experiment.DetectionResultsV2], Error> {
        Publishers.Sequence(sequence: experiment.requestedConfigurations)
            .flatMap { self.resultV2(for: experiment, configuration: ENExposureConfiguration(from: $0)) }
            .collect()
            .eraseToAnyPublisher()
    }

    @available(iOS 13.7, *)
    private func resultV2(for experiment: Experiment.ExperimentV2, configuration: ENExposureConfiguration) -> AnyPublisher<Experiment.DetectionResultsV2, Error> {
        Publishers.Sequence(sequence: experiment.participants)
            .flatMap { self.exposureV2(to: $0, configuration: configuration) }
            .collect()
            .map {
                Experiment.DetectionResultsV2(
                    timestamp: Date(),
                    counterparts: $0
                )
            }
            .eraseToAnyPublisher()
    }

    func getKeys() -> AnyPublisher<[Experiment.Key], Error> {
        Future { promise in
            self.getDiagnosisKeys(mode: .testing) { result in
                let mappedResult = result.flatMap { keys -> Result<[Experiment.Key], Error> in
                    guard !keys.isEmpty else {
                        return .failure(SimpleError("No exposure keys exist yet. Please try again."))
                    }
                    return .success(keys.map(Experiment.Key.init))
                }
                promise(mappedResult)
            }
        }.eraseToAnyPublisher()
    }

}

private extension ENExposureConfiguration {

    convenience init(from configuration: Experiment.RequestedConfiguration) {
        self.init()
        attenuationDurationThresholds = configuration.attenuationDurationThresholds.map { NSNumber(value: $0) }

        if #available(iOS 13.7, *) {
            var map: [NSNumber: NSNumber] = [:]

            for x in -14 ... 14 {
                map[NSNumber(value: x)] = NSNumber(value: ENInfectiousness.high.rawValue)
            }

//            map[NSNumber(value:ENDaysSinceOnsetOfSymptomsUnknown)] = NSNumber(value: ENInfectiousness.standard.rawValue)

            infectiousnessForDaysSinceOnsetOfSymptoms = map
            reportTypeNoneMap = .confirmedTest
        }
    }

}
