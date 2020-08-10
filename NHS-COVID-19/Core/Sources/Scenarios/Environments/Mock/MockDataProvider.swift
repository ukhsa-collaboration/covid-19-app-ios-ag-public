//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation

class MockDataProvider: ObservableObject {
    static let testResults = ["POSITIVE", "NEGATIVE", "VOID"]
    
    private let _objectWillChange = PassthroughSubject<Void, Never>()
    
    var objectWillChange: AnyPublisher<Void, Never> {
        _objectWillChange.eraseToAnyPublisher()
    }
    
    @UserDefault("mocks.highRiskPostcodes", defaultValue: "")
    var highRiskPostcodes: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.mediumRiskPostcodes", defaultValue: "")
    var mediumRiskPostcodes: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.lowRiskPostcodes", defaultValue: "")
    var lowRiskPostcodes: String {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.riskyVenueIDs", defaultValue: "")
    var riskyVenueIDs: String {
        didSet {
            _objectWillChange.send()
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
    
    @UserDefault("mocks.receivedTestResult", defaultValue: 0)
    var receivedTestResult: Int {
        didSet {
            _objectWillChange.send()
        }
    }
    
    @UserDefault("mocks.useFakeENContacts", defaultValue: false)
    var useFakeENContacts: Bool {
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
    
    var numberOfContactsString: String {
        get {
            String(numberOfContacts)
        }
        set {
            if let value = Int(newValue) {
                numberOfContacts = value
            }
        }
    }
    
    @UserDefault("mocks.contactDaysAgo", defaultValue: 1)
    var contactDaysAgo: Int {
        didSet {
            _objectWillChange.send()
        }
    }
    
    var contactDaysAgoString: String {
        get {
            String(contactDaysAgo)
        }
        set {
            if let value = Int(newValue) {
                contactDaysAgo = value
            }
        }
    }
    
}
