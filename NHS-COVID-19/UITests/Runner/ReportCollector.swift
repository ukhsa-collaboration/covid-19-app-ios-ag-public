//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import TestSupport

struct ReportCollector {

    private static var instance: ReportCollector?

    private var fileManager: FileManager
    private var encoder: JSONEncoder
    private var reportFolder: URL

    @_transparent
    func saveManifest(for useCase: UseCase) throws {
        let body = try encoder.encode(useCase)
        let file = reportFolder.appendingPathComponent(useCase.manifestFileName)
        try body.write(to: file)
    }

    @_transparent
    func appendScreenshots(_ screenshots: [String: Data], for useCase: UseCase) throws {
        let snapshotsFolder = reportFolder.appendingPathComponent(useCase.screenshotsFolderName)
        if !fileManager.fileExists(atPath: snapshotsFolder.path) {
            try fileManager.createDirectory(at: snapshotsFolder, withIntermediateDirectories: true, attributes: nil)
        }
        try screenshots.forEach { name, data in
            try data.write(to: reportFolder.appendingPathComponent(name))
        }
    }

}

extension ReportCollector {

    @_transparent
    static func shared() throws -> ReportCollector {
        if let instance = instance {
            return instance
        }
        let instance = try initialize()
        self.instance = instance
        return instance
    }

    @_transparent
    private static func initialize() throws -> ReportCollector {
        guard let testReportFolderPath = Bundle(for: Marker.self).infoDictionary?["testReportFolderPath"] as? String else {
            throw TestError("Test report folder not defined.")
        }
        let reportFolder = URL(fileURLWithPath: testReportFolderPath)
        let fileManager = FileManager()
        if fileManager.fileExists(atPath: reportFolder.path) {
            try fileManager.removeItem(at: reportFolder)
        }
        try fileManager.createDirectory(at: reportFolder, withIntermediateDirectories: true, attributes: nil)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return ReportCollector(
            fileManager: fileManager,
            encoder: encoder,
            reportFolder: reportFolder
        )
    }

}

private class Marker {}
