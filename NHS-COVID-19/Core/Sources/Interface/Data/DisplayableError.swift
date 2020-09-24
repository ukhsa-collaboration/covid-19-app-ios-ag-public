//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import Localization

public struct DisplayableError: Error, Equatable {
    
    // We store values in this form so we keep the semantics of how the value is localised.
    // This is useful for testing, for example.
    private enum Value: Equatable {
        case key(StringLocalizationKey)
        case parameterisedKey(ParameterisedStringLocalizable)
        case verbatim(String)
    }
    
    private var value: Value
    
    public init(_ key: StringLocalizationKey) {
        value = .key(key)
    }
    
    public init(_ key: ParameterisedStringLocalizable) {
        value = .parameterisedKey(key)
    }
    
    // To be used only in testing.
    public init(testValue: String) {
        value = .verbatim(testValue)
    }
    
    public var localizedDescription: String {
        switch value {
        case .key(let key):
            return localize(key)
        case .parameterisedKey(let key):
            return localize(key)
        case .verbatim(let string):
            return string
        }
    }
    
}
