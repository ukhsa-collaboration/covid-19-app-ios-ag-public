//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation
import XCTest
@testable import Localization

import Foundation

class LocalizationStringFormatTests: XCTestCase {
    
    enum LocalizationKey: String {
        case numericArgument
    }
    
    // This makes sure locale injected is used for formating
    func testLocalizeForArabic() throws {
        
        try FileManager().makeTemporaryDirectory { tmpFolder in
            
            let bundle = Bundle(url: tmpFolder)!
            let locale = Locale(identifier: "ar")
            let localization = Localization(bundle: bundle, locale: locale)
            
            try arabicDict.write(to: tmpFolder.appendingPathComponent("Localizable.stringsdict"), atomically: true, encoding: .utf8)
            
            XCTAssertEqual("few".apply(direction: currentLanguageDirection()), localization.localize(LocalizationKey.numericArgument, arguments: [3]))
        }
    }
}

extension FileManager {
    
    /// Creates a temporary directory and calls the `operation` with it.
    ///
    /// The directory is automatically deleted after `operation` returns.
    ///
    /// - Parameter operation: The operation to perform in the directory.
    /// - Returns: The result of `operation`.
    /// - Throws: If `operation` throws, or if fails to create a temporary folder.
    public func makeTemporaryDirectory<Output>(perform operation: (URL) throws -> Output) throws -> Output {
        let directory = try url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: temporaryDirectory, create: true)
        defer { try? removeItem(at: directory) }
        
        return try operation(directory)
    }
    
}

let arabicDict = """
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>numericArgument</key>
        <dict>
            <key>NSStringLocalizedFormatKey</key>
            <string>%#@days@</string>
            <key>days</key>
            <dict>
                <key>NSStringFormatSpecTypeKey</key>
                <string>NSStringPluralRuleType</string>
                <key>NSStringFormatValueTypeKey</key>
                <string>li</string>
                <key>zero</key>
                <string>zero</string>
                <key>one</key>
                <string>one</string>
                <key>two</key>
                <string>two</string>
                <key>few</key>
                <string>few</string>
                <key>many</key>
                <string>many</string>
                <key>other</key>
                <string>other</string>
            </dict>
        </dict>
    </dict>
</plist>

"""
