//
// Copyright © 2021 DHSC. All rights reserved.
//

import BehaviourModels
import Domain
import Foundation

struct IsolationModelAdapter {
    
    func storeRepresentations(for state: IsolationModel.State) throws -> [String] {
        throw IsolationModelUndefinedMappingError()
    }
    
    func verify(_ context: RunningAppContext, isIn state: IsolationModel.State) throws {
        throw IsolationModelUndefinedMappingError()
    }
    
}
