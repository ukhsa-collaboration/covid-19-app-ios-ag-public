//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
@testable import Domain

struct QRCodeCheckIn {
    let context: RunningAppContext
    
    init(context: RunningAppContext) {
        self.context = context
    }
    
    func checkIn(date: Date) throws {
        _ = try _checkIn(date)
    }
    
    func checkInAndCancel(date: Date) throws {
        let (_, cancel) = try _checkIn(date)
        cancel()
    }
    
    private func _checkIn(_ date: Date) throws -> (String, () -> Void) {
        return try context.checkInContext!.checkInsStore.checkIn(with: validQrPayload, currentDate: date)
    }
}

private let validQrPayload = "UKC19TRACING:1:eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjMifQ.eyJpZCI6IjRXVDU5TTVZIiwib3BuIjoiR292ZXJubWVudCBPZmZpY2UgT2YgSHVtYW4gUmVzb3VyY2VzIn0.ZIvwm9rxiRTm4o-koafL6Bzre9pakcyae8m6_MSyvAl-CFkUgfm6gcXYn4gg5OScKZ1-XayHBGwEdps0RKXs4g"
