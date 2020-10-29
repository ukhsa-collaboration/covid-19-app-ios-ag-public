//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import XCTest
@testable import Localization

class LocalizationTests: XCTestCase {
    
    func testLocalizationKeysExistForAllLanguages() throws {
        let languageSet = try LanguageSet()
        
        let errors1 = StringLocalizationKey.allCases.compactMap { key in
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
    
    let primaryBundle: LanguageBundle
    let otherBundles: [LanguageBundle]
    
    init() throws {
        let otherLanguages = Bundle.main.localizations.filter {
            $0 != "en" && $0 != "Base"
        }
        primaryBundle = try LanguageBundle(language: "en")
        otherBundles = try otherLanguages.map {
            try LanguageBundle(language: $0)
        }
    }
    
    var allLanguages: [LanguageBundle] {
        [primaryBundle] + otherBundles
    }
    
    func errorMessage<Key: RawRepresentable>(for key: Key) -> String? where Key.RawValue == String {
        let lines = _errorMessage(for: key)
        if lines.isEmpty {
            return nil
        } else {
            return ([key.rawValue, primaryBundle.localize(key)] + lines).joined(separator: "\n")
        }
    }
    
    private func _errorMessage<Key: RawRepresentable>(for key: Key) -> [String] where Key.RawValue == String {
        if !primaryBundle.hasLocalizedValue(for: key) {
            return ["No primary translation."]
        }
        
        return allLanguages.compactMap {
            $0.errorMessage(for: key)
        }
    }
    
}

private class LanguageBundle {
    
    let testBundle: Bundle
    let language: String
    
    init(language: String) throws {
        self.language = language
        
        guard
            let url = Bundle.main.url(forResource: language, withExtension: "lproj"),
            let testBundle = Bundle(url: url)
        else {
            throw LocalizationError(language: language)
        }
        
        self.testBundle = testBundle
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
        withBundle {
            Localization.hasLocalizedValue(for: key)
        }
    }
    
    func localize<Key: RawRepresentable>(_ key: Key) -> String where Key.RawValue == String {
        withBundle {
            Localization.localize(key)
        }
    }
    
    private func withBundle<Result>(perform work: () -> Result) -> Result {
        let originalBundle = Localization.bundle
        Localization.bundle = testBundle
        defer { Localization.bundle = originalBundle }
        
        return work()
    }
    
}

private struct LocalizationError: Error, CustomStringConvertible {
    var language: String
    
    var description: String {
        "No localization for \(language)"
    }
}
