//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Localization
import Scenarios
import TestSupport
import XCTest
@testable import Domain

class ChangeNotifierTests: XCTestCase {
    
    private var subject: PassthroughSubject<Bool, Never>!
    private var notificationManager: MockUserNotificationsManager!
    private var notifier: ChangeNotifier!
    
    override func setUp() {
        super.setUp()
        
        subject = PassthroughSubject()
        notificationManager = MockUserNotificationsManager()
        notifier = ChangeNotifier(notificationManager: notificationManager)
    }
    
    func testNoAlertIsSentBasedOnInitialStateOfNonRisky() {
        
        let cancellable = notifier.alertUserToChanges(in: subject, type: .postcode)
        defer { cancellable.cancel() }
        
        subject.send(false)
        XCTAssertNil(notificationManager.notificationType)
        XCTAssertNil(notificationManager.triggerAt)
    }
    
    func testNoAlertIsSentBasedOnInitialStateOfRisky() {
        let cancellable = notifier.alertUserToChanges(in: subject, type: .postcode)
        defer { cancellable.cancel() }
        
        subject.send(true)
        XCTAssertNil(notificationManager.notificationType)
        XCTAssertNil(notificationManager.triggerAt)
    }
    
    func testAlertIsSentWhenBecomingRisky() throws {
        let cancellable = notifier.alertUserToChanges(in: subject, type: .postcode)
        defer { cancellable.cancel() }
        
        subject.send(false)
        subject.send(true)
        
        XCTAssertEqual(notificationManager.notificationType, .postcode)
        XCTAssertNil(notificationManager.triggerAt)
    }
    
    func testAlertIsSentWhenBecomingNonRisky() throws {
        let cancellable = notifier.alertUserToChanges(in: subject, type: .postcode)
        defer { cancellable.cancel() }
        
        subject.send(true)
        subject.send(false)
        
        XCTAssertEqual(notificationManager.notificationType, .postcode)
        XCTAssertNil(notificationManager.triggerAt)
    }
    
    func testAlertIsNotSentWhenReSettingTheSameRisk() {
        
        let cancellable = notifier.alertUserToChanges(in: subject, type: .postcode)
        defer { cancellable.cancel() }
        
        subject.send(true)
        subject.send(true)
        
        XCTAssertNil(notificationManager.notificationType)
        XCTAssertNil(notificationManager.triggerAt)
    }
    
}
