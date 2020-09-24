//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

protocol LocaleConsumer {
    init()
    var locale: Locale! { get nonmutating set }
}

extension DateFormatter: LocaleConsumer {}

extension DateIntervalFormatter: LocaleConsumer {}

private extension LocaleConsumer {
    
    func applyLocale(for bundle: Bundle) {
        if bundle.bundleURL.pathExtension == "lproj" {
            // Only excerised in testing logic:
            // If the bundle is set to a specific language, that means we need to force that localisation.
            let localeIdentifier = bundle.bundleURL.deletingPathExtension().lastPathComponent
            locale = Locale(identifier: localeIdentifier)
        } else {
            locale = .autoupdatingCurrent
        }
    }
    
}

public struct Localization {
    private static var localeConsumers = [LocaleConsumer]()
    
    public static var bundle = Bundle.main {
        didSet {
            localeConsumers.forEach {
                $0.applyLocale(for: bundle)
            }
        }
    }
    
    public static var country = Country.england
    
    static func make<T: LocaleConsumer>(_ type: T.Type) -> T {
        let instance = T()
        localeConsumers.append(instance)
        instance.applyLocale(for: bundle)
        return instance
    }
    
    static func localize<Key: RawRepresentable>(_ key: Key, default value: String = "") -> String where Key.RawValue == String {
        let string = NSLocalizedString(key.rawValue, tableName: nil, bundle: bundle, value: value, comment: "")
        return string.isEmpty ? key.rawValue : string
    }
}

extension Localization {
    static func hasLocalizedValue<Key: RawRepresentable>(for key: Key) -> Bool where Key.RawValue == String {
        localize(key, default: "1") == localize(key, default: "2")
    }
}

public func localize(_ key: StringLocalizationKey) -> String {
    Localization.localize(key)
}

public func localizeAndSplit(_ key: StringLocalizationKey) -> [String] {
    Localization.localize(key).split(separator: "\n").map(String.init)
}

func localizeURL(_ key: StringLocalizationKey) -> URL {
    var rawValue = key.rawValue
    
    if let suffix = Localization.country.localizationSuffix {
        rawValue.append(suffix)
    }
    
    let localizedString = NSLocalizedString(rawValue, tableName: nil, bundle: Localization.bundle, value: "", comment: "")
    return URL(string: localizedString) ?? URL(string: localize(key))!
}

public func localizeForCountry(_ key: StringLocalizationKey) -> String {
    var rawValue = key.rawValue
    
    if let suffix = Localization.country.localizationSuffix {
        rawValue.append(suffix)
    }
    
    return NSLocalizedString(rawValue, tableName: nil, bundle: Localization.bundle, value: "", comment: "")
}

public func localizeForCountry(_ localizable: ParameterisedStringLocalizable) -> String {
    var rawValue = localizable.key.rawValue
    
    if let suffix = Localization.country.localizationSuffix {
        rawValue.append(suffix)
    }
    
    let format = NSLocalizedString(rawValue, tableName: nil, bundle: Localization.bundle, value: "", comment: "")
    
    let string = String(format: format, arguments: localizable.arguments)
    return string.isEmpty ? String(format: localizable.key.rawValue, arguments: localizable.arguments) : string
}

public func localize(_ localizable: ParameterisedStringLocalizable) -> String {
    let format = Localization.localize(localizable.key)
    let string = String(format: format, arguments: localizable.arguments)
    return string.isEmpty ? String(format: localizable.key.rawValue, arguments: localizable.arguments) : string
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
