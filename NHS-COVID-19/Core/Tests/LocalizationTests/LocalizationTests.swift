//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation
import XCTest
@testable import Localization

class LocalizationTests: XCTestCase {

    func testLocalizationKeysExistForAllLanguages() throws {
        let languageSet = try LanguageSet()

        let errors1 = StringLocalizableKey.allCases.compactMap { key in
            languageSet.errorMessage(for: key)
        }

        let errors2 = ParameterisedStringLocalizable.Key.allCases.compactMap { key in
            languageSet.errorMessage(for: key)
        }

        let allErrors = errors1 + errors2

        if !allErrors.isEmpty {
            let message = allErrors.joined(separator: "\n\n")
            XCTFail("Keys with issues: \(allErrors.count)\n\(message)")
        }
    }

}

private extension String {

    var containsForbiddenCharacters: Bool {
        rangeOfCharacter(from: .forbidden) != nil
    }

}

private extension CharacterSet {

    // ' and " are not allowed. Ensure you use the correct character, for example ‘ or ’
    static let forbidden = CharacterSet(charactersIn: #"'""#)

}

private class LanguageSet {

    let primaryConfiguration: LanguageConfiguration
    let otherConfigurations: [LanguageConfiguration]

    init() throws {
        let otherLanguages = Bundle.main.localizations.filter {
            $0 != "en" && $0 != "Base"
        }
        primaryConfiguration = LanguageConfiguration(language: "en")
        otherConfigurations = otherLanguages.map {
            LanguageConfiguration(language: $0)
        }
    }

    var allLanguages: [LanguageConfiguration] {
        [primaryConfiguration] + otherConfigurations
    }

    func errorMessage<Key: RawRepresentable>(for key: Key) -> String? where Key.RawValue == String {
        let lines = _errorMessage(for: key)
        if lines.isEmpty {
            return nil
        } else {
            return ([key.rawValue, primaryConfiguration.localize(key)] + lines).joined(separator: "\n")
        }
    }

    private func _errorMessage<Key: RawRepresentable>(for key: Key) -> [String] where Key.RawValue == String {
        if !primaryConfiguration.hasLocalizedValue(for: key) {
            return ["No primary translation."]
        }

        return allLanguages.compactMap {
            $0.errorMessage(for: key)
        }
    }

}

private class LanguageConfiguration {

    let language: String

    init(language: String) {
        self.language = language
    }

    func errorMessage<Key: RawRepresentable>(for key: Key) -> String? where Key.RawValue == String {
        guard language == "en" else {
            return nil // No checks on non-base language for now.
        }

        if !hasLocalizedValue(for: key) {
            return "\(language): No translation."
        }

        let translation = localize(key)
        if language == "en" {
            if translation.containsForbiddenCharacters {
                return "\(language): Using forbidden characters."
            }
        }

        return nil
    }

    func hasLocalizedValue<Key: RawRepresentable>(for key: Key) -> Bool where Key.RawValue == String {
        withConfiguration {
            Localization.current.hasLocalizedValue(for: key)
        }
    }

    func localize<Key: RawRepresentable>(_ key: Key) -> String where Key.RawValue == String {
        withConfiguration {
            Localization.current.localize(key)
        }
    }

    private func withConfiguration<Result>(perform work: () -> Result) -> Result {
        LocaleConfiguration.custom(localeIdentifier: language).becomeCurrent()
        defer { LocaleConfiguration.systemPreferred.becomeCurrent() }

        return work()
    }

}
