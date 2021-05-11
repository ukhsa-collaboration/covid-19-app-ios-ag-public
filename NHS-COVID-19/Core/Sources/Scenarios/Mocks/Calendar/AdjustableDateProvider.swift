//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation
import UIKit

final class AdjustableDateProvider: DateProviding {
    
    private let notificationCenter: NotificationCenter
    private let numberOfDaysFromNowSubject = CurrentValueSubject<Int, Never>(0)
    private var cancellables = Set<AnyCancellable>()
    
    init(notificationCenter: NotificationCenter = .default, dataProvider: MockDataProvider = MockScenario.mockDataProvider) {
        self.notificationCenter = notificationCenter
        
        dataProvider.numberOfDaysFromNowDidChange
            .prepend(dataProvider.numberOfDaysFromNow)
            .subscribe(numberOfDaysFromNowSubject)
            .store(in: &cancellables)
    }
    
    var currentDate: Date {
        Date().addingTimeInterval(TimeInterval(numberOfDaysFromNowSubject.value * 24 * 60 * 60))
    }
    
    var today: AnyPublisher<LocalDay, Never> {
        notificationCenter.publisher(for: UIApplication.significantTimeChangeNotification)
            .mapToVoid()
            .merge(with: numberOfDaysFromNowSubject.mapToVoid())
            .compactMap { [weak self] in self?.currentLocalDay }
            .prepend(currentLocalDay)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
}
