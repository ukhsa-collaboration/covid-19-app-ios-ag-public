//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import Domain
import Combine
import Common

class AcceptanceTestMockDateProvider: DateProviding {
    @Published
    private var date: Date?
    
    var currentDate: Date {
        date ?? Date()
    }
    
    var today: AnyPublisher<LocalDay, Never> {
        let startDay = LocalDay(date: currentDate, timeZone: .current)
        return $date
            .filterNil()
            .map {
                LocalDay(date: $0, timeZone: .current)
            }
            .prepend(startDay)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    func setDate(_ date: Date) {
        self.date = date
    }
    
    func advanceToEndOfAnalyticsWindow(steps: Int, performBackgroundTask: () -> Void) {
        let endOfAnalyticsWindow = currentGregorianDay(timeZone: .utc).advanced(by: 1).startDate(in: .utc)
        let differenceToEndOfWindow = currentDate.distance(to: endOfAnalyticsWindow)
        let timeToAdvance = ceil(differenceToEndOfWindow / Double(steps))
        
        while currentDate < endOfAnalyticsWindow {
            date = currentDate.advanced(by: timeToAdvance)
            performBackgroundTask()
        }
    }
    
    func advanceToNextBackgroundTaskExecution(performBackgroundTask: () -> Void) {
        let timeToAdvance = 2 * 60 * 60
        date = currentDate.advanced(by: Double(timeToAdvance))
        performBackgroundTask()
    }
}
