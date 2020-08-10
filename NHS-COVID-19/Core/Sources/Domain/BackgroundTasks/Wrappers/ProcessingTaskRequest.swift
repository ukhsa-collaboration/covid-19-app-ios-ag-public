//
// Copyright © 2020 NHSX. All rights reserved.
//

import BackgroundTasks
import Foundation

public struct ProcessingTaskRequest: Equatable {
    public var earliestBeginDate: Date?
    public var requiresNetworkConnectivity: Bool
    public var requiresExternalPower: Bool
    
    public init(
        earliestBeginDate: Date? = nil,
        requiresNetworkConnectivity: Bool = false,
        requiresExternalPower: Bool = false
    ) {
        self.earliestBeginDate = earliestBeginDate
        self.requiresNetworkConnectivity = requiresNetworkConnectivity
        self.requiresExternalPower = requiresExternalPower
    }
}

extension ProcessingTaskRequest {
    
    public init(_ request: BGProcessingTaskRequest) {
        self.init(
            earliestBeginDate: request.earliestBeginDate,
            requiresNetworkConnectivity: request.requiresNetworkConnectivity,
            requiresExternalPower: request.requiresExternalPower
        )
    }
    
}

extension BGProcessingTaskRequest {
    
    public convenience init(identifier: String, request: ProcessingTaskRequest) {
        self.init(identifier: identifier)
        earliestBeginDate = request.earliestBeginDate
        requiresNetworkConnectivity = request.requiresNetworkConnectivity
        requiresExternalPower = request.requiresExternalPower
    }
    
}
