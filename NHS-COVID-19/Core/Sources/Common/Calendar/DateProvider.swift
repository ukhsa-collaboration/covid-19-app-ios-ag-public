//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit
import Combine

public protocol DateProviding {
    var currentDate: Date { get }
    
    var today: AnyPublisher<LocalDay, Never> { get }
}

public extension DateProviding {
    func currentGregorianDay(timeZone: TimeZone) -> GregorianDay {
        GregorianDay(date: currentDate, timeZone: timeZone)
    }
    
    var currentLocalDay: LocalDay {
        LocalDay(date: currentDate, timeZone: .current)
    }
}

public struct DateProvider: DateProviding {
    private let notificationCenter: NotificationCenter
    
    public init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
    }
    
    public var currentDate: Date {
        Date()
    }
    
    public var today: AnyPublisher<LocalDay, Never> {
        self.notificationCenter.publisher(for: UIApplication.significantTimeChangeNotification)
            .map { _ in currentLocalDay }
            .prepend(currentLocalDay)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
