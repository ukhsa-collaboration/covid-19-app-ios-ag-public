//
// Copyright © 2021 DHSC. All rights reserved.
//

import ArgumentParser
import Foundation

struct ArchiveReportCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "archive",
        abstract: "Produces report from an Xcode archive."
    )
    
    @Argument(help: "Path to the archive to make a report for.")
    var archive: String
    
    @Option(help: "Path to use for the output.")
    var output: String
    
    func run() throws {
        let fileManager = FileManager()
        
        let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let reportFolder = URL(fileURLWithPath: output, relativeTo: currentDirectory)
        
        try fileManager.createDirectory(at: reportFolder, withIntermediateDirectories: true, attributes: nil)
        
        let appURL = try findApplication()
        let reporter = ExtendedReporter(appURL: appURL, reportFolder: reportFolder)
        try reporter.run()
    }
    
    private func findApplication() throws -> URL {
        let fileManager = FileManager()
        
        let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let archiveFolder = URL(fileURLWithPath: archive, relativeTo: currentDirectory)
        
        let archive = try Archive(url: archiveFolder)
        return archive.application.url
    }
    
}
