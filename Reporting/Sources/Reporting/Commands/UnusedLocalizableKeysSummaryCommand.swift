//
// Copyright © 2021 DHSC. All rights reserved.
//

import ArgumentParser
import CodeAnalyzer
import Foundation

struct UnusedLocalizableKeysSummaryCommand: ParsableCommand {
    
    static var configuration = CommandConfiguration(
        commandName: "localization-summary-report",
        abstract: "Produces report with unused/undefined localizable keys."
    )
    
    @Argument(help: "Path to a folder used for output. This is where the localization summary report will be saved.")
    var output: String
    
    func run() throws {
        let fileManager = FileManager()
        let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let outputFolder = URL(fileURLWithPath: output, relativeTo: currentDirectory)
        try fileManager.createDirectory(at: outputFolder, withIntermediateDirectories: true, attributes: nil)
        
        let localizableStringsFile = currentDirectory
            .deletingLastPathComponent()
            .appendingPathComponent("NHS-COVID-19/Core/Sources/Localization/Resources/en.lproj/Localizable.strings")
        
        let localizableStringsDictFile = currentDirectory
            .deletingLastPathComponent()
            .appendingPathComponent("NHS-COVID-19/Core/Sources/Localization/Resources/en.lproj/Localizable.stringsdict")
        
        let stringLocalizationKeyFile = currentDirectory
            .deletingLastPathComponent()
            .appendingPathComponent("NHS-COVID-19/Core/Sources/Localization/StringLocalizationKey.swift")
        
        let integrationDirectory = currentDirectory
            .deletingLastPathComponent()
            .appendingPathComponent("NHS-COVID-19/Core/Sources/Integration")
        let interfaceDirectory = currentDirectory
            .deletingLastPathComponent()
            .appendingPathComponent("NHS-COVID-19/Core/Sources/Interface")
        let localizationDirectory = currentDirectory
            .deletingLastPathComponent()
            .appendingPathComponent("NHS-COVID-19/Core/Sources/Localization")
        let scenariosDirectory = currentDirectory
            .deletingLastPathComponent()
            .appendingPathComponent("NHS-COVID-19/Core/Sources/Scenarios")
        
        var sourceFiles: [URL] = []
        sourceFiles += getAllFiles(in: integrationDirectory)
        sourceFiles += getAllFiles(in: interfaceDirectory)
        sourceFiles += getAllFiles(in: localizationDirectory)
        sourceFiles += getAllFiles(in: scenariosDirectory)
        
        let localizationKeyAnalyzer = try LocalizationKeyAnalyzer(
            localizableStringsFile: localizableStringsFile,
            localizableStringsDictFile: localizableStringsDictFile,
            localisationKeyFile: stringLocalizationKeyFile, sourceFiles: sourceFiles
        )
        
        var localizationSummaryReportString = "Undefined localizable keys (\(localizationKeyAnalyzer.undefinedKeys.count))\n\n"
        localizationKeyAnalyzer.undefinedKeys.forEach { localizationSummaryReportString += $0.description + "\n" }
        
        localizationSummaryReportString += "\n\nUnused localizable keys (\(localizationKeyAnalyzer.uncalledKeys.count))\n\n"
        localizationKeyAnalyzer.uncalledKeys.forEach { localizationSummaryReportString += $0.description + "\n" }
        
        let fileURL = outputFolder.appendingPathComponent("undefined_localizable_keys").appendingPathExtension("txt")
        
        try localizationSummaryReportString.write(
            to: fileURL,
            atomically: false,
            encoding: .utf8
        )
    }
}

extension UnusedLocalizableKeysSummaryCommand {
    func getAllFiles(in directoryURL: URL) -> [URL] {
        var files = [URL]()
        if let enumerator = FileManager.default.enumerator(
            at: directoryURL,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles,
                      .skipsPackageDescendants]
        ) {
            for case let fileURL as URL in enumerator {
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys: [.isRegularFileKey])
                    if fileAttributes.isRegularFile! {
                        files.append(fileURL)
                    }
                } catch { print(error, fileURL) }
            }
            return files
        }
        return []
    }
}
