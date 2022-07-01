//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation
import XCTest
@testable import Localization

enum useCase: CaseIterable {
    case missingCopy
}

class TestLocalization: XCTestCase {

    let runner = ReportRunner()

    func testLocalizationReport() throws {
        try runner.run(name: "Localization Checks") {
            var sections: [Report.Section] = []
            for usecase in useCase.allCases {
                switch usecase {
                case .missingCopy:
                    sections.append(collectMissingCopy())
                }
            }
            return Report(title: "Localization Checks", sections: sections)
        }
    }

    private func collectMissingCopy() -> Report.Section {
        var checks = [Report.Check]()

        let allLanguages = Localization.current.bundle.localizations.filter {
            $0 != "Base"
        }

        allLanguages.forEach { language in
            var missingCopy: String = ""
            LocaleConfiguration.custom(localeIdentifier: language).becomeCurrent()
            missingCopy.append(contentsOf: LocalizationHelper.lookupMissingCopy(for: StringLocalizableKey.allCases, prefix: "Found missing copy:\n\n"))
            missingCopy.append(contentsOf: LocalizationHelper.lookupMissingCopy(for: ParameterisedStringLocalizable.Key.allCases))
            checks.append(Report.Check(check: language, notes: missingCopy, passed: missingCopy.isEmpty))
        }
        return Report.Section(body: "", checks: checks, title: "Missing copy check")
    }
}

private class LocalizationHelper {
    static func lookupMissingCopy<T: RawRepresentable>(for keys: [T], prefix: String? = nil) -> String where T.RawValue == String {
        var missingCopy: [String] = []
        keys.forEach { key in
            if !Localization.current.hasLocalizedValue(for: key) {
                missingCopy.append(key.rawValue)
            }
        }
        let list = ReportList(
            items: missingCopy.sorted().map { "`\($0)`" }
        )
        return list.items.count > 0 ? prefix != nil ? prefix! + list.markdownBody : list.markdownBody : ""
    }
}
