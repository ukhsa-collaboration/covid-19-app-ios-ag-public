//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation

protocol LocaleConsumer {
    init()
    var locale: Locale! { get nonmutating set }
}

extension DateFormatter: LocaleConsumer {}

extension DateIntervalFormatter: LocaleConsumer {}

private extension LocaleConsumer {

    func applyLocale(for locale: Locale) {
        self.locale = locale
    }

}

public protocol LocalizationOverrider {
    func localize(_ key: String, languageCode: String, tableName: String?, bundle: Bundle, value: String, comment: String) -> String?
}

public struct Localization {
    private static var localeConsumers = [LocaleConsumer]()

    let localeConfiguration: LocaleConfiguration
    var bundle: Bundle
    var locale: Locale

    public var overrider: LocalizationOverrider?

    private func _localize(_ key: String, tableName: String? = nil, bundle: Bundle = Localization.current.bundle, value: String = "", comment: String) -> String {

        // overrider is only ever set in the Scenarios app so this does not affect production code
        if let override = overrider?.localize(key, languageCode: locale.languageCode ?? "en", tableName: tableName, bundle: bundle, value: value, comment: comment) {
            return override
        }

        return NSLocalizedString(key, tableName: tableName, bundle: bundle, value: value, comment: comment)
    }

    init(bundle: Bundle, locale: Locale) {
        localeConfiguration = .systemPreferred
        self.bundle = bundle
        self.locale = locale
    }

    init(configuration: LocaleConfiguration) {
        localeConfiguration = configuration
        switch configuration {
        case .systemPreferred:
            bundle = Bundle.module
            locale = .autoupdatingCurrent
        case .custom(let localeIdentifier):
            bundle = Bundle.module.localizedBundle(for: localeIdentifier) ?? Bundle.module
            locale = Locale(identifier: localeIdentifier)
        }
    }

    #warning("LocalConsures.applyLocale will not have effect on Localization instance")
    public static var current = Localization(configuration: .systemPreferred) {
        didSet {
            localeConsumers.forEach {
                $0.applyLocale(for: Localization.current.locale)
            }
            configurationChangeSubject.send(())
        }
    }

    public static var configurationChangePublisher: AnyPublisher<Void, Never> {
        return configurationChangeSubject.eraseToAnyPublisher()
    }

    private static var configurationChangeSubject = PassthroughSubject<Void, Never>()

    public static var country = Country.england

    static func make<T: LocaleConsumer>(_ type: T.Type) -> T {
        let instance = T()
        localeConsumers.append(instance)
        instance.applyLocale(for: Localization.current.locale)
        return instance
    }

    // todo; could combine these two functions as they are essentially the same; this is only used in localizeURL and localizeForCountry
    func localize(_ key: String, default value: String = "", applyCurrentLanguageDirection: Bool = true) -> String {
        let string = _localize(key, tableName: nil, bundle: bundle, value: value, comment: "")
        return string.isEmpty ?
            key :
            applyCurrentLanguageDirection ? string.applyCurrentLanguageDirection() : string
    }

    func localize<Key: RawRepresentable>(_ key: Key, default value: String = "", applyCurrentLanguageDirection: Bool = true) -> String where Key.RawValue == String {
        let string = _localize(key.rawValue, tableName: nil, bundle: bundle, value: value, comment: "")
        return string.isEmpty ?
            key.rawValue :
            applyCurrentLanguageDirection ? string.applyCurrentLanguageDirection() : string
    }

    func localize<Key: RawRepresentable>(_ key: Key, arguments: [CVarArg]) -> String where Key.RawValue == String {

        let format = localize(key, applyCurrentLanguageDirection: false)
        let string = String(
            format: format,
            locale: locale,
            arguments: arguments
        )

        let actualString = string.isEmpty ?
            String(
                format: key.rawValue,
                locale: locale,
                arguments: arguments
            ) : string

        return actualString.applyCurrentLanguageDirection()
    }
}

extension Localization {
    func hasLocalizedValue<Key: RawRepresentable>(for key: Key) -> Bool where Key.RawValue == String {
        localize(key, default: "1") == localize(key, default: "2")
    }

    static func preferredLocaleIdentifier(from supportedLocalizations: [String]) -> String? {
        switch Localization.current.localeConfiguration {
        case .systemPreferred:
            return Bundle.preferredLocalizations(from: supportedLocalizations).first
        case .custom(let localeIdentifierString):
            let localeIdentifierValues = supportedLocalizations.map { LocaleIdentifier(rawValue: $0) }
            let localeIdentifier = LocaleIdentifier(rawValue: localeIdentifierString)

            if let id = localeIdentifierValues.filter({ $0.canonicalValue == localeIdentifier.canonicalValue }).first {
                return id.rawValue
            } else if let id = localeIdentifierValues.filter({ $0.languageCode == localeIdentifier.languageCode }).first {
                return id.rawValue
            } else {
                return Bundle.preferredLocalizations(from: supportedLocalizations).first
            }
        }
    }
}

public func systemPreferredLanguageCode(
    from supportedLocalizations: [String] = Bundle.main.supportedLocalizations
) -> String {
    Bundle.preferredLocalizations(from: supportedLocalizations).first ?? "en"
}

#warning("Revisit uses of this.")
// Looks like in many places that we call this getting we actually want an "active" locale
// (and not `Locale.current`)
public func currentLocaleIdentifier(
    localeConfiguration: LocaleConfiguration? = nil,
    supportedLocalizations: [String] = Bundle.main.supportedLocalizations
) -> String {
    switch localeConfiguration ?? Localization.current.localeConfiguration {
    case .systemPreferred: return systemPreferredLanguageCode(from: supportedLocalizations)
    case .custom(let localeIdentifier): return localeIdentifier
    }
}

public func localize(_ key: StringLocalizableKey, applyCurrentLanguageDirection: Bool = true) -> String {
    Localization.current.localize(key, applyCurrentLanguageDirection: applyCurrentLanguageDirection)
}

public func localize(_ key: StringLocalizableKey, localeConfiguration: LocaleConfiguration) -> String {
    Localization(configuration: localeConfiguration).localize(key)
}

public func localizeAndSplit(_ key: StringLocalizableKey, applyCurrentLanguageDirection: Bool = true) -> [String] {
    Localization.current.localize(key, applyCurrentLanguageDirection: false)
        .split(separator: "\n", omittingEmptySubsequences: true)
        .map(String.init)
        .map { applyCurrentLanguageDirection ? $0.applyCurrentLanguageDirection() : $0 }
}

public func localizeAndSplit(_ key: ParameterisedStringLocalizable) -> [String] {
    #warning("""
    We use replacingOccurrences(:) here because values in stringDict (XML)
    will escape backslash char since it's a special XML char
    """)
    return Localization.current.localize(key.key, arguments: key.arguments)
        .replacingOccurrences(of: "\\n", with: "\n")
        .split(separator: "\n", omittingEmptySubsequences: true)
        .map(String.init)
}

func localizeURL(_ key: StringLocalizableKey) -> URL {
    var rawValue = key.rawValue

    if let suffix = Localization.country.localizationSuffix {
        rawValue.append(suffix)
    }

    let localizedString = Localization.current.localize(rawValue, applyCurrentLanguageDirection: false)

    guard localizedString != rawValue else { return URL(string: localize(key, applyCurrentLanguageDirection: false))! }

    return URL(string: localizedString) ?? URL(string: localize(key, applyCurrentLanguageDirection: false))!
}

public func localizeForCountry(_ key: StringLocalizableKey) -> String {
    var rawValue = key.rawValue

    if let suffix = Localization.country.localizationSuffix {
        rawValue.append(suffix)
    }

    return Localization.current.localize(rawValue)
}

public func localizeForCountry(_ localizable: ParameterisedStringLocalizable) -> String {
    var rawValue = localizable.key.rawValue

    if let suffix = Localization.country.localizationSuffix {
        rawValue.append(suffix)
    }

    let format = Localization.current.localize(rawValue, applyCurrentLanguageDirection: false)

    let string = String(format: format, locale: Localization.current.locale, arguments: localizable.arguments)

    let actualString = string.isEmpty ?
    String(
        format: localizable.key.rawValue,
        locale: Localization.current.locale,
        arguments: localizable.arguments
    ) : string

    return actualString.applyCurrentLanguageDirection()
}

public func localizeForCountryAndSplit(_ key: StringLocalizableKey, applyCurrentLanguageDirection: Bool = true) -> [String] {
    var rawValue = key.rawValue

    if let suffix = Localization.country.localizationSuffix {
        rawValue.append(suffix)
    }

    if let newKey = StringLocalizableKey(rawValue: rawValue) {
        return Localization.current.localize(newKey, applyCurrentLanguageDirection: false)
            .split(separator: "\n", omittingEmptySubsequences: true)
            .map(String.init)
            .map { applyCurrentLanguageDirection ? $0.applyCurrentLanguageDirection() : $0 }
    } else {
        return localizeForCountry(key)
            .split(separator: "\n", omittingEmptySubsequences: true)
            .map(String.init)
    }
}

public func localize(_ localizable: ParameterisedStringLocalizable) -> String {
    Localization.current.localize(localizable.key, arguments: localizable.arguments)

}

private extension Country {
    var localizationSuffix: String? {
        switch self {
        case .england:
            return nil
        case .wales:
            return "_wls"
        }
    }
}

extension LocaleConfiguration {
    public func becomeCurrent() {
        let overrider = Localization.current.overrider
        Localization.current = Localization(configuration: self)
        Localization.current.overrider = overrider
    }
}

public extension Bundle {
    func localizedBundle(for language: String) -> Bundle? {
        url(forResource: language, withExtension: "lproj").flatMap {
            Bundle(url: $0)
        }
    }
}

public enum LocalizedContentType {
    case text
    case url
}

extension LocaleString {

    public func localizedString(contentType: LocalizedContentType = .text) -> String {
        guard let identifier = Localization.preferredLocaleIdentifier(
            from: Array(values.keys.map { $0.identifier })
        ), let string = self[Locale(identifier: identifier)] else {
            return ""
        }
        switch contentType {
        case .url:
            return string
        case .text:
            return string.applyCurrentLanguageDirection()
        }
    }
}

extension LocaleURL {
    public enum LocaleError: Error {
        case unknown
    }

    public func localizedURL() throws -> URL {
        guard let identifier = Localization.preferredLocaleIdentifier(
            from: Array(values.keys.map { $0.identifier })
        ), let url = self[Locale(identifier: identifier)] else {
            throw LocaleError.unknown
        }
        return url
    }
}

public extension String {
    func apply(direction: LanguageDirection) -> String {
        switch direction {
        case .rightToLeft:
            return "\u{200f}\(self)"
        case .leftToRight:
            return "\u{200e}\(self)"
        case .unknown:
            return self
        }
    }

    func applyCurrentLanguageDirection() -> String {
        apply(direction: currentLanguageDirection())
    }
}
