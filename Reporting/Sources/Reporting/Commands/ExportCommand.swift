//
// Copyright © 2020 NHSX. All rights reserved.
//

import ArgumentParser
import Foundation

struct ExportCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "export",
        abstract: "Export a production-ready ipa for a target."
    )
    
    @Argument(help: "Path to the main workspace.")
    var workspace: String
    
    @Option(help: "Name of scheme to export.")
    var scheme: String
    
    @Option(help: "Path to a folder used for the output. This is where the ipa and validation results will be saved")
    var exportPath: String
    
    func run() throws {
        try withArchive(perform: export)
    }
    
    private func withArchive(perform work: (URL) throws -> Void) throws {
        let fileManager = FileManager()
        
        let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        
        let temp = try fileManager.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: currentDirectory, create: true)
        defer { try? fileManager.removeItem(at: temp) }
        
        let archiveURL = temp
            .appendingPathComponent("archive")
            .appendingPathExtension("xcarchive")
        
        try Bash.run(
            "xcodebuild",
            "archive",
            "-workspace", workspace,
            "-scheme", scheme,
            "-archivePath", "\"\(archiveURL.path)\""
        )
        
        try work(archiveURL)
    }
    
    private func export(from archiveURL: URL) throws {
        let fileManager = FileManager()
        let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let exportURL = URL(fileURLWithPath: exportPath, relativeTo: currentDirectory)
        
        let temp = try fileManager.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: currentDirectory, create: true)
        defer { try? fileManager.removeItem(at: temp) }
        
        let archive = try Archive(url: archiveURL)
        let application = archive.application
        let info = application.appInfo
        
        guard case .some(.some(let bundleIdentifier)) = info.bundleIdentifier else {
            throw CustomError("Could not find the bundle identifier.")
        }
        
        let optionsURL = temp
            .appendingPathComponent("options")
            .appendingPathExtension("plist")
        
        let options = ExportOptions(
            method: "app-store",
            provisioningProfiles: [
                bundleIdentifier: "Exposure Notification - Distribution",
            ],
            signingCertificate: "Apple Distribution"
        )
        
        try PropertyListEncoder().encode(options).write(to: optionsURL)
        
        try Bash.run(
            "xcodebuild",
            "-exportArchive",
            "-archivePath", "\"\(archiveURL.path)\"",
            "-exportPath", "\"\(exportURL.path)\"",
            "-exportOptionsPlist", "\"\(optionsURL.path)\""
        )
    }
    
}

private struct ExportOptions: Codable {
    var method: String
    var provisioningProfiles: [String: String]
    var signingCertificate: String
}
