//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

enum FileParserError: Error {
    case fileNotFound
    case unableToParse
}

class LocalizableStringKeyParser: LocalizableKeys {
    private var localizableStringsFile: URL

    var keys: Set<LocalizableKey> = []

    // MARK: - Constructor

    init(file: URL) throws {

        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: file.path) else {
            throw FileParserError.fileNotFound
        }

        localizableStringsFile = file

        keys = try parseLocalizableStrings()
    }

    // MARK: - Helper methods

    private func parseLocalizableStrings() throws -> Set<LocalizableKey> {

        guard let localizableDict = NSDictionary(contentsOf: localizableStringsFile) as? [String: String] else {
            throw FileParserError.unableToParse
        }

        return Set<LocalizableKey>(keys: Array(localizableDict.keys))
    }

}

public struct LocalizableKey: Hashable, CustomStringConvertible {
    var key: String
    var keyWithSuffix: String?

    public var description: String {
        if let keyWithSuffix = keyWithSuffix {
            return "\(key), \(keyWithSuffix)"
        } else {
            return key
        }
    }
}
