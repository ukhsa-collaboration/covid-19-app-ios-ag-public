//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest
@testable import Scenarios

final class UserDefaultTests: XCTestCase {

    private let userDefaults = UserDefaults.standard
    private let key = UUID().uuidString

    override func setUp() {
        super.setUp()

        userDefaults.removeObject(forKey: key)
    }

    func testPropertiesWithDefault() {
        let userDefault = UserDefault<Int>(key, defaultValue: 1)

        XCTAssertEqual(userDefault.wrappedValue, 1)

        userDefaults.set(5, forKey: key)

        XCTAssertEqual(userDefault.wrappedValue, 5)

        userDefaults.removeObject(forKey: key)

        XCTAssertEqual(userDefault.wrappedValue, 1)
    }

    func testPropertiesWithoutDefault() {
        let userDefault = UserDefault<Int?>(key)

        XCTAssertNil(userDefault.wrappedValue)

        userDefaults.set(5, forKey: key)

        XCTAssertEqual(userDefault.wrappedValue, 5)

        userDefaults.removeObject(forKey: key)

        XCTAssertNil(userDefault.wrappedValue)
    }

    func testRawRepresentablePropertiesWithDefault() {
        let userDefault = UserDefault<MockRawRepresentable>(key, defaultValue: MockRawRepresentable(rawValue: 1))

        XCTAssertEqual(userDefault.wrappedValue.rawValue, 1)

        userDefaults.set(5, forKey: key)

        XCTAssertEqual(userDefault.wrappedValue.rawValue, 5)

        userDefaults.removeObject(forKey: key)

        XCTAssertEqual(userDefault.wrappedValue.rawValue, 1)
    }

    func testRawRepresentablePropertiesWithoutDefault() {
        let userDefault = UserDefault<MockRawRepresentable?>(key)

        XCTAssertNil(userDefault.wrappedValue)

        userDefaults.set(5, forKey: key)

        XCTAssertEqual(userDefault.wrappedValue?.rawValue, 5)

        userDefaults.removeObject(forKey: key)

        XCTAssertNil(userDefault.wrappedValue)
    }

}

extension UserDefaultTests {

    func withTemporaryDefaultKey(perform work: (UserDefaults, String) throws -> Void) rethrows {
        let defaults = UserDefaults.standard
        let key = UUID().uuidString

        defaults.removeObject(forKey: key)
        try work(defaults, key)
        defaults.removeObject(forKey: key)
    }

}

private struct MockRawRepresentable: RawRepresentable {
    var rawValue: Int
}
