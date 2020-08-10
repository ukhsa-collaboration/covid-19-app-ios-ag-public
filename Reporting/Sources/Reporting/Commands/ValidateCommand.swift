//
// Copyright © 2020 NHSX. All rights reserved.
//

import ArgumentParser
import Foundation

struct ValidateCommand: ParsableCommand {
    
    static var configuration = CommandConfiguration(
        commandName: "validate",
        abstract: "Validate a target against App Store Connect."
    )
    
    @Argument(help: "Path to the ipa to make a report for.")
    var ipa: String
    
    @Option(help: "App Store Connect username.")
    var username: String
    
    @Option(help: "App Store Connect password.")
    var password: String
    
    func run() throws {
        let fileManager = FileManager()
        let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let ipaURL = URL(fileURLWithPath: ipa, relativeTo: currentDirectory)
        let validationResultFile = ipaURL
            .deletingLastPathComponent()
            .appendingPathComponent("validation-result")
            .appendingPathExtension("json")
        
        let result = try Bash.runAndCapture(
            "xcrun altool", "--validate-app",
            "--file", "\"\(ipa)\"",
            "--type", "ios",
            "--username", username,
            "--password", password,
            "--output-format", "json"
        )
        
        try result.write(to: validationResultFile)
    }
    
}
