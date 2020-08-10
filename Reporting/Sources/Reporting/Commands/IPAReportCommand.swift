//
// Copyright © 2020 NHSX. All rights reserved.
//

import ArgumentParser
import Foundation

struct IPAReportCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "ipa",
        abstract: "Produces report from an ipa file."
    )
    
    @Argument(help: "Path to the ipa to make a report for.")
    var ipa: String
    
    @Option(help: "Path to use for the output.")
    var output: String
    
    func run() throws {
        let fileManager = FileManager()
        
        let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let reportFolder = URL(fileURLWithPath: output, relativeTo: currentDirectory)
        let ipaUrl = URL(fileURLWithPath: self.ipa, relativeTo: currentDirectory)
        
        let ipa = IPA(url: ipaUrl)
        try ipa.withApplication { application in
            try fileManager.createDirectory(at: reportFolder, withIntermediateDirectories: true, attributes: nil)
            let reporter = ArtefactReporter(appURL: application.url, reportFolder: reportFolder)
            try reporter.run()
        }
    }
    
}
