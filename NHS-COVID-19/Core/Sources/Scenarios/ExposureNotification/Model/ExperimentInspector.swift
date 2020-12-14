//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Foundation

class ExperimentInspector: ObservableObject, Identifiable {
    
    let experimentName: String
    
    private var cancellables = [AnyCancellable]()
    
    @Published
    var isLoading = true
    
    @Published
    private(set) var error: Error?
    
    @Published
    var experiment: Experiment?
    
    @Published
    var experimentV2: Experiment.ExperimentV2?
    
    init(manager: ExperimentManager) {
        experimentName = manager.experimentName
        precondition(!manager.experimentId.isEmpty)
               
        if #available(iOS 13.7, *), manager.usingEnApiVersion == 2 {
            let endpoint = GetExperimentEndpointV2(
                team: manager.teamName,
                experimentId: manager.experimentId
            )
            cancellables.append(
                manager.client
                    .fetch(endpoint, with: ())
                    .receive(on: RunLoop.main)
                    .sink(
                        receiveCompletion: { completion in
                            switch completion {
                            case .finished:
                                break
                            case .failure(let error):
                                self.error = error
                            }
                            self.isLoading = false
                        },
                        receiveValue: { experiment in
                            self.experimentV2 = experiment
                        }
                    )
            )
        } else {
            let endpoint = GetExperimentEndpoint(
                team: manager.teamName,
                experimentId: manager.experimentId
            )
            cancellables.append(
                manager.client
                    .fetch(endpoint, with: ())
                    .receive(on: RunLoop.main)
                    .sink(
                        receiveCompletion: { completion in
                            switch completion {
                            case .finished:
                                break
                            case .failure(let error):
                                self.error = error
                            }
                            self.isLoading = false
                        },
                        receiveValue: { experiment in
                            self.experiment = experiment
                        }
                    )
            )
        }
        

        
    }
    
}
