//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

public struct SupportedLanguage {
    public static func allLanguages(
        currentLocaleIdentifier: String,
        supportedLocalizations: [String] = Bundle.main.supportedLocalizations
    ) -> [SelectableLanguage?] {
        
        let currentLocale = Locale(identifier: currentLocaleIdentifier)
        
        return supportedLocalizations.map {
            guard let (exonym, endonym) = Self.getLanguageTermsFrom(localeIdentifier: $0) else {
                return nil
            }
            return SelectableLanguage(isoCode: $0, exonym: exonym, endonym: endonym)
        }.sorted {
            // Moves nil elements at the end of an array
            guard let lhs = $0 else { return false }
            guard let rhs = $1 else { return true }
            return lhs.exonym.compare(rhs.exonym, locale: currentLocale) == .orderedAscending
        }
    }
    
    public static func getLanguageTermsFrom(localeIdentifier: String) -> (exonym: String, endonym: String)? {
        switch localeIdentifier {
        case "en": return (exonym: localize(.settings_language_en), endonym: localize(.settings_language_en, localeConfiguration: LocaleConfiguration.custom(localeIdentifier: localeIdentifier)))
        case "ar": return (exonym: localize(.settings_language_ar), endonym: localize(.settings_language_ar, localeConfiguration: LocaleConfiguration.custom(localeIdentifier: localeIdentifier)))
        case "bn": return (exonym: localize(.settings_language_bn), endonym: localize(.settings_language_bn, localeConfiguration: LocaleConfiguration.custom(localeIdentifier: localeIdentifier)))
        case "zh": return (exonym: localize(.settings_language_zh), endonym: localize(.settings_language_zh, localeConfiguration: LocaleConfiguration.custom(localeIdentifier: localeIdentifier)))
        case "gu": return (exonym: localize(.settings_language_gu), endonym: localize(.settings_language_gu, localeConfiguration: LocaleConfiguration.custom(localeIdentifier: localeIdentifier)))
        case "pl": return (exonym: localize(.settings_language_pl), endonym: localize(.settings_language_pl, localeConfiguration: LocaleConfiguration.custom(localeIdentifier: localeIdentifier)))
        case "pa": return (exonym: localize(.settings_language_pa), endonym: localize(.settings_language_pa, localeConfiguration: LocaleConfiguration.custom(localeIdentifier: localeIdentifier)))
        case "ro": return (exonym: localize(.settings_language_ro), endonym: localize(.settings_language_ro, localeConfiguration: LocaleConfiguration.custom(localeIdentifier: localeIdentifier)))
        case "so": return (exonym: localize(.settings_language_so), endonym: localize(.settings_language_so, localeConfiguration: LocaleConfiguration.custom(localeIdentifier: localeIdentifier)))
        case "tr": return (exonym: localize(.settings_language_tr), endonym: localize(.settings_language_tr, localeConfiguration: LocaleConfiguration.custom(localeIdentifier: localeIdentifier)))
        case "ur": return (exonym: localize(.settings_language_ur), endonym: localize(.settings_language_ur, localeConfiguration: LocaleConfiguration.custom(localeIdentifier: localeIdentifier)))
        case "cy": return (exonym: localize(.settings_language_cy), endonym: localize(.settings_language_cy, localeConfiguration: LocaleConfiguration.custom(localeIdentifier: localeIdentifier)))
        case "de": return (exonym: localize(.settings_language_cy), endonym: localize(.settings_language_cy, localeConfiguration: LocaleConfiguration.custom(localeIdentifier: localeIdentifier)))
        default:
            assertionFailure("Asserts when a new localization is added to the project")
            return nil
        }
    }
}

public struct SelectableLanguage: Equatable {
    public var isoCode: String
    public var exonym: String
    public var endonym: String
    
    public init(isoCode: String, exonym: String, endonym: String) {
        self.isoCode = isoCode
        self.exonym = exonym
        self.endonym = endonym
    }
    
    public static func == (firstLanguage: Self, secondLanguage: Self) -> Bool {
        firstLanguage.isoCode == secondLanguage.isoCode
    }
}
