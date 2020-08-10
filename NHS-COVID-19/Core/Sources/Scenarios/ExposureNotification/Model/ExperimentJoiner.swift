//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Foundation

class ExperimentJoiner: ObservableObject, Identifiable {
    
    private var cancellables = [AnyCancellable]()
    
    @Published
    private(set) var isCreatingExperiment = false
    
    @Published
    private(set) var error: Error?
    
    init() {}
    
    func joinExperiment(storeIn experimentManager: ExperimentManager, complete: @escaping () -> Void) {
        isCreatingExperiment = true
        error = nil
        cancellables.append(
            experimentManager.exposureManager
                .enabledManager()
                .flatMap { experimentManager.joinExperiment(manager: $0) }
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
