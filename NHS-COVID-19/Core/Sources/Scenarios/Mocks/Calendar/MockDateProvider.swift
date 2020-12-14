//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import Common
import Combine

public struct MockDateProvider: DateProviding {
    public var currentDate: Date {
        getDate()
    }
    
    public var today: AnyPublisher<LocalDay, Never> {
        Just(currentLocalDay).eraseToAnyPublisher()
    }
    
    private let getDate: () -> Date
    
    public init(getDate: @escaping () -> Date = { Date() }) {
        self.getDate = getDate
    }
}
