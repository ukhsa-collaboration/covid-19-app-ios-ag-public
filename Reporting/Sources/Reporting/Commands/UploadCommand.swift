//
// Copyright © 2020 NHSX. All rights reserved.
//

import ArgumentParser
import Foundation

struct UploadCommand: ParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "validate",
        abstract: "Validate a target against App Store Connect."
    )

    @Argument(help: "Path to the ipa to make a report for.")
    var ipa: String

    @Option(help: "App Store Connect API key.")
    var apiKey: String

    @Option(help: "App Store Connect Issuer ID.")
    var apiIssuer: String

    func run() throws {
        let fileManager = FileManager()
        let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let ipaURL = URL(fileURLWithPath: ipa, relativeTo: currentDirectory)
        let validationResultFile = ipaURL
            .deletingLastPathComponent()
            .appendingPathComponent("validation-result")
            .appendingPathExtension("json")

        let result = try Bash.runAndCapture(
            "xcrun altool", "--upload-app",
            "--file", "\"\(ipa)\"",
            "--type", "ios",
            "--apiKey", apiKey,
            "--apiIssuer", apiIssuer,
            "--output-format", "json"
        )

        try result.write(to: validationResultFile)

        try checkSuccess(validationResultFile: validationResultFile)
    }

    func checkSuccess(validationResultFile: URL) throws {
        let content = try String(contentsOf: validationResultFile, encoding: .utf8)
        if !content.contains("success-message") {
            throw CustomError("Upload to App Store Connect failed")
        }
    }

}
