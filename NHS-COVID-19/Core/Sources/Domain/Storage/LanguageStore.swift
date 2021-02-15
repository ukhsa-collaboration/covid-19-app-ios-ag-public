//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

private struct LanguageInfo: Codable, DataConvertible {
    var languageCode: String
}

class LanguageStore {
    @Encrypted private var languageInfo: LanguageInfo? {
        didSet {
            languageCode = languageInfo?.languageCode
            configuration = LocaleConfiguration(localeIdentifier: languageInfo?.languageCode)
        }
    }
    
    @Published
    private(set) var configuration: LocaleConfiguration
    
    @Published
    private(set) var languageCode: String?
    
    init(store: EncryptedStoring) {
        _languageInfo = store.encrypted("language")
        let languageInfo = _languageInfo.wrappedValue
        languageCode = languageInfo?.languageCode
        configuration = LocaleConfiguration(localeIdentifier: languageInfo?.languageCode)
    }
    
    func save(localeConfiguration: LocaleConfiguration) {
        switch localeConfiguration {
        case .systemPreferred:
            languageInfo = nil
        case .custom(let localeIdentifier):
            languageInfo = LanguageInfo(languageCode: localeIdentifier)
        }
    }
    
    func delete() {
        languageInfo = nil
    }
}
