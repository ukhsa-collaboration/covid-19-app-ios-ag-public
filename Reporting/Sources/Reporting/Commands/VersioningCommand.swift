//
// Copyright © 2020 NHSX. All rights reserved.
//

import ArgumentParser
import Foundation

struct VersioningCommand: ParsableCommand {
    
    static var configuration = CommandConfiguration(
        commandName: "versioning",
        abstract: "Monitor tagged builds and update build number if required.",
        discussion: """
        This checks if there is a tag for the current build number. If there is a tag, and we have other commits since \
        then, this will increment the build number and pushes it on the current branch.
        """
    )
    
    @Option(help: "Tag prefix.")
    var tagPrefix: String
    
    @Option(help: "Path to xcconfig file managing the version/build number.")
    var xcconfig: String
    
    func run() throws {
        let fileManager = FileManager()
        let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let configURL = URL(fileURLWithPath: xcconfig, relativeTo: currentDirectory)
        
        var xcodeConfig = try XcodeConfiguration(url: configURL)
        
        let buildNumberConfigName = "BUILD_NUMBER"
        guard
            let buildNumberConfigLineIndex = xcodeConfig.lines.lastIndex(where: { $0.name == buildNumberConfigName }),
            case .configuration(_, let buildNumberString) = xcodeConfig.lines[buildNumberConfigLineIndex],
            let buildNumber = Int(buildNumberString)
        else {
            throw CustomError("Could not find \(buildNumberConfigName)")
        }
        
        let tags = try Git.tags()
        
        let maybeTag = tags.first { tag in
            let components = tag.components(separatedBy: "-")
            guard components.count == 3 else { return false }
            return components[0] == tagPrefix && components[2] == buildNumberString
        }
        
        guard let tag = maybeTag else {
            print("This build has not been uploaded yet.")
            return
        }
        
        let tagRevision = try Git.revision(for: tag)
        let headRevision = try Git.revision()
        
        guard tagRevision != headRevision else {
            print("No changes since last upload")
            return
        }
        
        print("Incrementing build number")
        let newBuildNumberString = String(buildNumber + 1)
        xcodeConfig.lines[buildNumberConfigLineIndex] = .configuration(name: buildNumberConfigName, value: newBuildNumberString)
        
        try xcodeConfig.save()
        
        try Git.add(path: configURL.path)
        try Git.commit(message: "Update build number to \(newBuildNumberString)")
        try Git.push(includingTags: false)
    }
    
}
