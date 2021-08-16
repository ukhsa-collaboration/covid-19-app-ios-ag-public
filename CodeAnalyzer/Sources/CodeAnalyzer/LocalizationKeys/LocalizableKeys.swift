//
// Copyright © 2021 DHSC. All rights reserved.
//

protocol LocalizableKeys {
    var keys: Set<LocalizableKey> { get }
}

protocol DefinedLocalizationKeys {
    var defaultKeys: Set<String> { get }
    var parameterizedKeys: Set<StringLocalizableKeyParser.ParameterizedKey> { get }
}

protocol UsedLocalizationKeys {
    var keys: Set<String> { get }
}
