//
// Copyright © 2020 NHSX. All rights reserved.
//

import ArgumentParser
import Foundation

struct GetCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "get",
        abstract: "Get information about the build.",
        subcommands: [
            GetVersionCommand.self,
            GetBuildNumberCommand.self,
        ]
    )
    
    struct GetVersionCommand: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "version",
            abstract: "Get Version number."
        )
        
        @Option(help: "Path to xcconfig file managing the version/build number.")
        var xcconfig: String
        
        func run() throws {
            let fileManager = FileManager()
            let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
            let configURL = URL(fileURLWithPath: xcconfig, relativeTo: currentDirectory)
            
            let xcodeConfig = try XcodeConfiguration(url: configURL)
            print(try xcodeConfig.value(for: "VERSION"))
        }
    }
    
    struct GetBuildNumberCommand: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "build-number",
            abstract: "Get Version number."
        )
        
        @Option(help: "Path to xcconfig file managing the version/build number.")
        var xcconfig: String
        
        func run() throws {
            let fileManager = FileManager()
            let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
            let configURL = URL(fileURLWithPath: xcconfig, relativeTo: currentDirectory)
            
            let xcodeConfig = try XcodeConfiguration(url: configURL)
            print(try xcodeConfig.value(for: "BUILD_NUMBER"))
        }
    }
    
}
