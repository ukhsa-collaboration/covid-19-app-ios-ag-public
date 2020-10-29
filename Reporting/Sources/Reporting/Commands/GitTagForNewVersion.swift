//
// Copyright © 2020 NHSX. All rights reserved.
//

import ArgumentParser
import Foundation

struct GitTagForNewVersion: ParsableCommand {
    
    static var configuration = CommandConfiguration(
        commandName: "new-version-tag",
        abstract: "Generates a git tag for a new version that does not have one yet"
    )
    
    @Option(help: "Tag prefix.")
    var tagPrefix: String
    
    @Option(help: "Path to xcconfig file managing the version/build number.")
    var xcconfig: String
    
    func run() throws {
        let tag = try self.tag()
        
        let tags = try Git.tags()
        
        if !tags.contains(tag) {
            print(tag)
        }
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
