//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

struct ReportCollector {
    
    private static var instance: ReportCollector?
    
    private var fileManager: FileManager
    private var encoder: JSONEncoder
    private var reportFolder: URL
    
    @_transparent
    func append(_ textReport: Report, for reportName: String) throws {
        if !fileManager.fileExists(atPath: reportFolder.path) {
            try fileManager.createDirectory(at: reportFolder, withIntermediateDirectories: true, attributes: nil)
        }
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let json = try jsonEncoder.encode(textReport)
        
        try json.write(to: reportFolder.appendingPathComponent(reportName).appendingPathExtension("json"))
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
        guard let textReportTempFolder = Bundle(for: Marker.self).infoDictionary?["textReportTempFolder"] as? String else {
            throw TestError()
        }
        let reportFolder = URL(fileURLWithPath: textReportTempFolder)
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

private struct TestError: Error {}
