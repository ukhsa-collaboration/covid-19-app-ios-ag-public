//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

struct Bash {
    static func run(_ command: String) throws {
        let process = Process()
        process.launchPath = "/bin/bash"
        process.arguments = ["-c", command]

        process.launch()
        process.waitUntilExit()
    }

    static func run(_ commandParts: String...) throws {
        try run(commandParts.joined(separator: " "))
    }

    static func runAndCapture(_ command: String) throws -> Data {
        let process = Process()
        process.launchPath = "/bin/bash"
        process.arguments = ["-c", command]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        return data
    }

    static func runAndCapture(_ commandParts: String...) throws -> Data {
        try runAndCapture(commandParts.joined(separator: " "))
    }

}
