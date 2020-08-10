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
    
    @Option(help: "Tag prefix.")
    var tagPrefix: String
    
    @Option(help: "Path to xcconfig file managing the version/build number.")
    var xcconfig: String
    
    @Option(help: "App Store Connect username.")
    var username: String
    
    @Option(help: "App Store Connect password.")
    var password: String
    
    @Option(help: "Path to a folder used for the output. This is where the ipa and validation results will be saved.")
    var exportPath: String
    
    func run() throws {
        let fileManager = FileManager()
        let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let exportURL = URL(fileURLWithPath: exportPath, relativeTo: currentDirectory)
        
        let tag = try self.tag()
        
        let tags = try Git.tags()
        
        guard !tags.contains(tag) else {
            print("No new version available to upload")
            return
        }
        
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
        uploadCommand.username = username
        uploadCommand.password = password
        try uploadCommand.run()
        
        try Git.createTag(named: tag)
        try Git.push(includingTags: true)
    }
    
    private func tag() throws -> String {
        let fileManager = FileManager()
        let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let configURL = URL(fileURLWithPath: xcconfig, relativeTo: currentDirectory)
        
        let xcodeConfig = try XcodeConfiguration(url: configURL)
        
        let version = try xcodeConfig.value(for: "VERSION")
        let buildNumber = try xcodeConfig.value(for: "BUILD_NUMBER")
        return "\(tagPrefix)-v\(version)-\(buildNumber)"
    }
    
}
