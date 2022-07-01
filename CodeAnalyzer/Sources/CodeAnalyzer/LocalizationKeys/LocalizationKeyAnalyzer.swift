//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

public class LocalizationKeyAnalyzer {
    private let localisationKeyParser: DefinedLocalizationKeys
    private let localizableStringKeyParser: LocalizableKeys
    private let localizableStringDictKeyParser: LocalizableKeys
    private let localizationKeysCalledFileParser: UsedLocalizationKeys

    /// Keys from both Localizable.strings and Localizable.stringsdict
    private var stringKeys: Set<LocalizableKey> {

        localizableStringKeyParser.keys.union(localizableStringDictKeyParser.keys)
    }

    public init(
        localizableStringsFile: URL,
        localizableStringsDictFile: URL,
        localisationKeyFile: URL,
        sourceFiles: [URL]
    ) throws {

        localisationKeyParser = try StringLocalizableKeyParser(file: localisationKeyFile)

        localizableStringKeyParser = try LocalizableStringKeyParser(file: localizableStringsFile)
        localizableStringDictKeyParser = try LocalizableStringDictParser(file: localizableStringsDictFile)

        let definedKeys = Set<String>(
            localisationKeyParser.parameterizedKeys.map {
                $0.identifier
            }
        ).union(localisationKeyParser.defaultKeys)

        localizationKeysCalledFileParser = try LocalizableKeysCalledFileParser(files: sourceFiles, definedKeys: definedKeys)
    }

    init(
        localisationKeyParser: DefinedLocalizationKeys,
        localizableStringKeyParser: LocalizableKeys,
        localizableStringDictKeyParser: LocalizableKeys,
        localizationKeysCalledFileParser: UsedLocalizationKeys
    ) {
        self.localisationKeyParser = localisationKeyParser
        self.localizableStringKeyParser = localizableStringKeyParser
        self.localizableStringDictKeyParser = localizableStringDictKeyParser
        self.localizationKeysCalledFileParser = localizationKeysCalledFileParser
    }

    /// Keys present in Localizable.strings and Localizable.stringsdict but not in StringLocalizableKey.swift
    public var undefinedKeys: Set<LocalizableKey> {
        // FIXME: Refactor - Beautify
        var stringKeysDict = [String: LocalizableKey]()
        stringKeys.forEach { stringKeysDict[$0.key] = $0 }

        let rawStringKeys = Set<String>(localizableStringKeyParser.keys.map { $0.key })

        let definedDefaultKeys = localisationKeyParser.defaultKeys
        let definedParameterizedKeys = localisationKeyParser.parameterizedKeys.map { $0.rawValue }
        let definedKeys = definedDefaultKeys.union(definedParameterizedKeys)

        let rawUndefinedKeys = rawStringKeys.subtracting(definedKeys)

        // Return Set<LocalizabeKey> represantation of rawUndefinedKeys
        var res: Set<LocalizableKey> = []

        rawUndefinedKeys.forEach {
            if let value = stringKeysDict[$0] {
                res.insert(value)
            }
        }
        return res

    }

    public var uncalledKeys: Set<LocalizableKey> {

        var stringKeysDict = [String: LocalizableKey]()
        stringKeys.forEach { stringKeysDict[$0.key] = $0 }

        let calledKeys = localizationKeysCalledFileParser.keys

        let uncalledDefaultKeys = localisationKeyParser.defaultKeys.subtracting(calledKeys)

        let uncalledParameterizedKeys = localisationKeyParser.parameterizedKeys.filter { !calledKeys.contains($0.identifier) }

        var res: Set<LocalizableKey> = []

        uncalledDefaultKeys.forEach {
            if let value = stringKeysDict[$0] {
                res.insert(value)
            }
        }

        uncalledParameterizedKeys.forEach {
            if let value = stringKeysDict[$0.rawValue] {
                res.insert(value)
            }
        }

        return res
    }

}

// MARK: - Unused localizable keys

extension LocalizationKeyAnalyzer {

    var findUnusedDefaultLocalizedKeys: Set<String> {
        []
    }

}
