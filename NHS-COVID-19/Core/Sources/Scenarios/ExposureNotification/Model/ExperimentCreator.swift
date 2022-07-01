//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import ExposureNotification
import Foundation

class ExperimentCreator: ObservableObject, Identifiable {

    private var cancellables = [AnyCancellable]()

    @Published
    private(set) var isCreatingExperiment = false

    @Published
    private(set) var error: Error?

    @Published
    var isPeriodicDetectionEnabled = false

    @Published
    var isMultiConfigurationEnabled = false

    init() {}

    func createExperiment(name: String, storeIn experimentManager: ExperimentManager, complete: @escaping () -> Void) {
        isCreatingExperiment = true
        error = nil
        let requestedConfigurations: [Experiment.RequestedConfiguration]
        if isMultiConfigurationEnabled {
            requestedConfigurations = [
                .init(ENExposureConfiguration()), // default
                .init(attenuationDurationThresholds: [50, 55]),
                .init(attenuationDurationThresholds: [55, 63]),
            ]
        } else {
            requestedConfigurations = [
                .init(attenuationDurationThresholds: [55, 63]),
            ]
        }
        cancellables.append(
            experimentManager.exposureManager
                .enabledManager()
                .flatMap {
                    experimentManager.createExperiment(
                        name: name,
                        automaticDetectionFrequency: self.isPeriodicDetectionEnabled ? 5 * 60 : nil,
                        requestedConfigurations: requestedConfigurations,
                        manager: $0
                    )
                }
                .receive(on: RunLoop.main)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            complete()
                        case .failure(let error):
                            self.error = error
                        }
                        self.isCreatingExperiment = false
                    },
                    receiveValue: { experiment in
                        experimentManager.set(experiment)
                    }
                )
        )
    }

}
