//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Foundation

public enum TestResultAcknowledgementState {
    case notNeeded
    case neededForNegativeResult(acknowledge: () -> Void, isolationEndDate: Date)
    case neededForNegativeResultNoIsolation(acknowledge: () -> Void)
    case neededForPositiveResult(PositiveResultAcknowledgement, isolationEndDate: Date)
    case neededForPositiveResultNoIsolation(PositiveResultAcknowledgement)
    
    public struct PositiveResultAcknowledgement {
        public var acknowledge: () -> AnyPublisher<Void, Error>
        public var acknowledgeWithoutSending: () -> Void
    }
    
    public static func neededForPositiveResult(acknowledge: @escaping () -> AnyPublisher<Void, Error>, isolationEndDate: Date) -> Self {
        .neededForPositiveResult(PositiveResultAcknowledgement(acknowledge: acknowledge, acknowledgeWithoutSending: {}), isolationEndDate: isolationEndDate)
    }
    
    public static func neededForPositiveResultNoIsolation(acknowledge: @escaping () -> AnyPublisher<Void, Error>) -> Self {
        .neededForPositiveResultNoIsolation(PositiveResultAcknowledgement(acknowledge: acknowledge, acknowledgeWithoutSending: {}))
    }
}
