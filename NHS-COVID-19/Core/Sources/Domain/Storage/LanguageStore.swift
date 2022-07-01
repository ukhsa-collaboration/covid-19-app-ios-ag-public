//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

struct LanguageInfo {
    let languageCode: String?

    func configuration(supportedLocalizations: [String] = Bundle.main.supportedLocalizations) -> LocaleConfiguration {
        return LocaleConfiguration(localeIdentifier: languageCode, supportedLocalizations: supportedLocalizations)
    }
}

private struct LanguagePayload: Codable, DataConvertible {
    var languageCode: String
}

class LanguageStore {
    @PublishedEncrypted private var languagePayload: LanguagePayload?

    private(set) lazy var languageInfo: DomainProperty<LanguageInfo> = {
        $languagePayload.map { $0?.languageCode }.map(LanguageInfo.init)
    }()

    init(store: EncryptedStoring) {
        _languagePayload = store.encrypted("language")
    }

    func save(localeConfiguration: LocaleConfiguration) {
        switch localeConfiguration {
        case .systemPreferred:
            languagePayload = nil
        case .custom(let localeIdentifier):
            languagePayload = LanguagePayload(languageCode: localeIdentifier)
        }
    }

    func delete() {
        languagePayload = nil
    }
}
