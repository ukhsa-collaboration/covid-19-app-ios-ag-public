//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

struct ExtendedReporter {
    
    var appURL: URL
    
    var reportFolder: URL
    
    func run() throws {
        
        let fileManager = FileManager()
        let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        
        let baseFolder = currentDirectory.deletingLastPathComponent()
        
        let artefactReport = try ArtefactReporter().report(for: appURL)
        let codebaseReport = try CodebaseReporter().report(for: baseFolder)
        
        let report = Report(
            pages: artefactReport.pages + codebaseReport.pages,
            attachments: artefactReport.attachments + codebaseReport.attachments
        )
        try report.save(to: reportFolder)
    }
    
}
