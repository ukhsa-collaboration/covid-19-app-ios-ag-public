//
// Copyright © 2020 NHSX. All rights reserved.
//

import ArgumentParser
import Foundation

struct DeployLatestCommand: ParsableCommand {
    
    static var configuration = CommandConfiguration(
        commandName: "deploy-latest",
        abstract: "Upload the latest version of the app to App Store Connect."
    )
    
    @Argument(help: "Path to the workspace to make a report for.")
    var workspace: String
    
    @Option(help: "Name of scheme to export.")
    var scheme: String
    
    @Option(help: "App Store Connect API key.")
    var apiKey: String
    
    @Option(help: "App Store Connect Issuer ID.")
    var apiIssuer: String
    
    @Option(help: "Path to a folder used for the output. This is where the ipa and validation results will be saved.")
    var exportPath: String
    
    @Option(help: "Git tag for the this upload")
    var tag: String
    
    func run() throws {
        let fileManager = FileManager()
        let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let exportURL = URL(fileURLWithPath: exportPath, relativeTo: currentDirectory)
        
        print("Archiving…")
        var exportCommand = ExportCommand()
        exportCommand.workspace = workspace
        exportCommand.scheme = scheme
        exportCommand.exportPath = exportPath
        
        try exportCommand.run()
        
        #warning("Hack: Assumes application name is the same as scheme.")
        let ipaURL = exportURL
            .appendingPathComponent(scheme)
            .appendingPathExtension("ipa")
        
        var uploadCommand = UploadCommand()
        uploadCommand.ipa = ipaURL.path
        uploadCommand.apiKey = apiKey
        uploadCommand.apiIssuer = apiIssuer
        try uploadCommand.run()
        
        try Git.createTag(named: tag)
        try Git.push(includingTags: true)
    }
}
