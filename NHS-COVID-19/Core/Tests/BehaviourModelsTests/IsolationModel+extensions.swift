//
// Copyright © 2020 NHSX. All rights reserved.
//

import BehaviourModels
import Foundation
import TestSupport

extension IsolationModel.State: CustomStringConvertible {
    
    public var description: String {
        TS.description(for: self)
    }
}
