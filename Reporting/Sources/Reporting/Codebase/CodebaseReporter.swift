//
// Copyright © 2021 DHSC. All rights reserved.
//

import CodeAnalyzer
import Foundation

struct CodebaseReporter {
    
    func report(for repoBaseFolder: URL) throws -> Report {
        
        let corePackageSourcesFolder = repoBaseFolder.appendingPathComponent(App.corePackageSourcesPathComponent)
        
        let localizationKeyAnalyzer = try LocalizationKeyAnalyzer(
            localizableStringsFile: corePackageSourcesFolder.appendingPathComponent(App.localizableStringsResourcePath),
            localizableStringsDictFile: corePackageSourcesFolder.appendingPathComponent(App.localizableStringsDictResourcePath),
            localisationKeyFile: corePackageSourcesFolder.appendingPathComponent(App.StringLocalizableKeyResourcePath),
            sourceFiles: App.localizedPackages.flatMap {
                getAllFiles(in: corePackageSourcesFolder.appendingPathComponent($0))
            }
        )
        
        return Report(
            pages: [
                ReportPage(
                    name: "Localised Assets Optimisation",
                    sections: [
                        [
                            ReportSection(title: "Localisation Cleanup", checks: [
                                IntegrityCheck(
                                    name: "Unused localisations",
                                    result: localizationKeyAnalyzer.undefinedKeys.isEmpty ? .passed : .failed(
                                        message: """
                                        These keys are localised, but are not defined in code:
                                        
                                        \(ReportList(items: localizationKeyAnalyzer.undefinedKeys.map(\.description).sorted()).markdownBody)
                                        """
                                    )
                                ),
                            ]),
                            ReportSection(title: "Code Cleanup", checks: [
                                IntegrityCheck(
                                    name: "Unused keys",
                                    result: localizationKeyAnalyzer.uncalledKeys.isEmpty ? .passed : .failed(
                                        message: """
                                        These keys are localised and defined in code, but are not actually used:
                                        \(ReportList(items: localizationKeyAnalyzer.uncalledKeys.map(\.description).sorted()).markdownBody)
                                        """
                                    )
                                ),
                            ]),
                        ],
                    ].flatMap { $0 }
                ),
            ],
            attachments: []
        )
    }
}

private extension CodebaseReporter {
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
