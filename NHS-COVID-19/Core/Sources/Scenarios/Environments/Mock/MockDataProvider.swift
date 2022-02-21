//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation

class MockDataProvider: ObservableObject {
    static let shared = MockDataProvider()
    
    static let testResults = ["POSITIVE", "NEGATIVE", "VOID", "PLOD", "UNKNOWN_TEST_RESULT_TYPE"]
    static let testKitType = ["LAB_RESULT", "RAPID_RESULT", "RAPID_SELF_REPORTED", "UNKNOWN_TEST_KIT_TYPE"]
    
    static let covidStatsDirection = ["DOWN", "UP", "SAME"]
    
    private let _numberOfDaysFromNowDidChange = PassthroughSubject<Int, Never>()
    private let _riskyLocalAuthorityMinimumBackgroundTaskUpdateIntervalDidChange = PassthroughSubject<Int, Never>()
    private let _objectWillChange = PassthroughSubject<Void, Never>()
    
    var objectWillChange: AnyPublisher<Void, Never> {
        _objectWillChange.eraseToAnyPublisher()
    }
    
    // MARK: Time Manipulation
    
    @UserDefault("mocks.numberOfDaysFromNow", defaultValue: 0)
    var numberOfDaysFromNow: Int {
        didSet {
            _numberOfDaysFromNowDidChange.send(numberOfDaysFromNow)
            _objectWillChange.send()
        }
    }
    
    var numberOfDaysFromNowDidChange: AnyPublisher<Int, Never> {
        _numberOfDaysFromNowDidChange.eraseToAnyPublisher()
    }
    
    // MARK: Postcode risk
    
    @UserDefault("mocks.blackPostcodes", defaultValue: "")
    var blackPostcodes: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.maroonPostcodes", defaultValue: "")
    var maroonPostcodes: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.redPostcodes", defaultValue: "")
    var redPostcodes: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.amberPostcodes", defaultValue: "")
    var amberPostcodes: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.yellowPostcodes", defaultValue: "")
    var yellowPostcodes: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.greenPostcodes", defaultValue: "")
    var greenPostcodes: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.neutralPostcodes", defaultValue: "")
    var neutralPostcodes: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    // MARK: Variants of Concern / Local Messages
    
    @UserDefault("mocks.vocLocalAuthorities", defaultValue: "")
    var vocLocalAuthorities: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.vocMessageId", defaultValue: "exampleMessage")
    var vocMessageId: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault(
        "mocks.vocMessageNotificationTitle",
        defaultValue: "A new variant of concern is in [postcode]"
    )
    var vocMessageNotificationTitle: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault(
        "mocks.vocMessageNotificationBody",
        defaultValue: "There have been cases of a new variant in [local authority]. Tap for information to help you stay safe in [postcode]."
    )
    var vocMessageNotificationBody: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.vocContentVersion", defaultValue: 1)
    var vocContentVersion: Int {
        didSet {
            _objectWillChange.send()
        }
    }
    
    // MARK: Local Authority Risk
    
    @UserDefault("mocks.blackLocalAuthorities", defaultValue: "")
    var blackLocalAuthorities: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.maroonLocalAuthorities", defaultValue: "")
    var maroonLocalAuthorities: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.redLocalAuthorities", defaultValue: "")
    var redLocalAuthorities: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.amberLocalAuthorities", defaultValue: "")
    var amberLocalAuthorities: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.yellowLocalAuthorities", defaultValue: "")
    var yellowLocalAuthorities: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.greenLocalAuthorities", defaultValue: "")
    var greenLocalAuthorities: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.neutralLocalAuthorities", defaultValue: "")
    var neutralLocalAuthorities: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    // MARK: Local Authority Risk - Minimum Update Interval
    
    @UserDefault(
        "mocks.riskyLocalAuthorityMinimumBackgroundTaskUpdateInterval",
        defaultValue: 600
    )
    var riskyLocalAuthorityMinimumBackgroundTaskUpdateInterval: Int {
        didSet {
            _riskyLocalAuthorityMinimumBackgroundTaskUpdateIntervalDidChange.send(riskyLocalAuthorityMinimumBackgroundTaskUpdateInterval)
            _objectWillChange.send()
        }
    }
    
    var riskyLocalAuthorityMinimumBackgroundTaskUpdateIntervalString: String {
        get {
            String(riskyLocalAuthorityMinimumBackgroundTaskUpdateInterval)
        }
        set {
            if let intValue = Int(newValue) {
                riskyLocalAuthorityMinimumBackgroundTaskUpdateInterval = intValue
            }
        }
    }
    
    var riskyLocalAuthorityMinimumBackgroundTaskUpdateIntervalDidChange: AnyPublisher<Int, Never> {
        _riskyLocalAuthorityMinimumBackgroundTaskUpdateIntervalDidChange.eraseToAnyPublisher()
    }
    
    // MARK: Local Covid Stats
    
    @UserDefault("mocks.localCovidStatsLAId", defaultValue: "")
    var localCovidStatsLAId: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.localCovidStats", defaultValue: 0)
    var localCovidStatsDirection: Int {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.peopleTestedPositiveHasData", defaultValue: true)
    var peopleTestedPositiveHasData: Bool {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.casesPer100K", defaultValue: true)
    var casesPer100KHasData: Bool {
        didSet {
            _objectWillChange.send()
        }
    }
    
    // MARK: Risky Venues
    
    @UserDefault("mocks.riskyVenueIDsWarnAndInform", defaultValue: "")
    var riskyVenueIDsWarnAndInform: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.riskyVenueIDsWarnAndBookTest", defaultValue: "")
    var riskyVenueIDsWarnAndBookTest: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    // MARK: Test Ordering Parameters
    
    @UserDefault("mocks.optionToBookATest", defaultValue: 11)
    var optionToBookATest: Int {
        didSet {
            _objectWillChange.send()
        }
    }
    
    var optionToBookATestString: String {
        get {
            String(optionToBookATest)
        }
        set {
            if let value = Int(newValue) {
                optionToBookATest = value
            }
        }
    }
    
    @UserDefault("mocks.orderTestWebsite", defaultValue: "")
    var orderTestWebsite: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.testReferenceCode", defaultValue: "d23f - gre4")
    var testReferenceCode: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    // MARK: Minimum Versions
    
    @UserDefault("mocks.minimumOSVersion", defaultValue: "13.5.0")
    var minimumOSVersion: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.minimumAppVersion", defaultValue: "1.0.0")
    var minimumAppVersion: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.latestAppVersion", defaultValue: "1.0.0")
    var latestAppVersion: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.recommendedAppVersion", defaultValue: "1.0.0")
    var recommendedAppVersion: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.recommendedOSVersion", defaultValue: "1.0.0")
    var recommendedOSVersion: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    // MARK: Received Test Result Parameters
    
    @UserDefault("mocks.receivedTestResult", defaultValue: 0)
    var receivedTestResult: Int {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.testKitType", defaultValue: 0)
    var testKitType: Int {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.keySubmissionSupported", defaultValue: true)
    var keySubmissionSupported: Bool {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.requiresConfirmatoryTest", defaultValue: false)
    var requiresConfirmatoryTest: Bool {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.shouldOfferFollowUpTest", defaultValue: true)
    var shouldOfferFollowUpTest: Bool {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.testResultEndDateDaysAgo", defaultValue: 0)
    var testResultEndDateDaysAgo: Int {
        didSet {
            _objectWillChange.send()
        }
    }
    
    // MARK: Isolation Configuration
    
    @UserDefault("mocks.confirmatoryDayLimit")
    var confirmatoryDayLimit: Int? {
        didSet {
            _objectWillChange.send()
        }
    }
    
    var confirmatoryDayLimitString: String {
        get {
            if let confirmatoryDayLimit = confirmatoryDayLimit {
                return String(confirmatoryDayLimit)
            } else {
                return ""
            }
        }
        set {
            if let value = Int(newValue) {
                confirmatoryDayLimit = value
            } else {
                confirmatoryDayLimit = nil
            }
        }
    }
    
    // MARK: Fake Exposure Notifications
    
    @UserDefault("mocks.useFakeENContacts", defaultValue: false)
    var useFakeENContacts: Bool {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.bluetoothEnabled", defaultValue: true)
    var bluetoothEnabled: Bool {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.numberOfContacts", defaultValue: 0)
    var numberOfContacts: Int {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.contactDaysAgo", defaultValue: 1)
    var contactDaysAgo: Int {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.lokaliseLastUpdate")
    var lokaliseLastUpdate: Date? {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.lokaliseShowDownloadedStrings", defaultValue: true)
    var lokaliseShowDownloadedStrings: Bool {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.lokaliseShowKeysOnly", defaultValue: false)
    var lokaliseShowKeysOnly: Bool {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.useFakeCheckins", defaultValue: false)
    var useFakeCheckins: Bool {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.fakeCheckinsVenueID", defaultValue: "TEST001")
    var fakeCheckinsVenueID: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.fakeCheckinsVenueOrg", defaultValue: "Test Venue 001")
    var fakeCheckinsVenueOrg: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.fakeCheckinsVenuePostcode", defaultValue: "SW1H0EU")
    var fakeCheckinsVenuePostcode: String {
        didSet {
            _objectWillChange.send()
        }
    }
}
