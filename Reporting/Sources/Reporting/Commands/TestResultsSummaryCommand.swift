//
// Copyright © 2020 NHSX. All rights reserved.
//

import ArgumentParser
import Foundation

struct TestResultsSummaryCommand: ParsableCommand {
    
    static var configuration = CommandConfiguration(
        commandName: "summary",
        abstract: "Produces coverage and testresults (test summary) text files."
    )
    
    @Argument(help: "Path to test result bundle")
    var testResultBundle: String
    
    @Option(help: "Path to use for the Test Results Summary files.")
    var output: String
    
    func run() throws {
        let fileManager = FileManager()
        let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let outputFolder = URL(fileURLWithPath: output, relativeTo: currentDirectory)
        try fileManager.createDirectory(at: outputFolder, withIntermediateDirectories: true, attributes: nil)
        
        let testResultsJSONData = try Bash.runAndCapture(
            "xcrun xccov view",
            "--report",
            "--json", testResultBundle
        )
        
        // Write coverage test result
        
        let testSummaryReportGenerator = TestSummaryReportGenerator()
        let coverageData = try testSummaryReportGenerator.createCoverageSummary(from: testResultsJSONData)
        try coverageData.write(to: outputFolder.appendingPathComponent("coverage").appendingPathExtension("txt"))
        
        // Write Test results
        let actionsInvocationRecordData = try Bash.runAndCapture(
            "xcrun xcresulttool get",
            "--format",
            "json",
            "--path", testResultBundle
        )
        
        let actionsInvocationRecordJSONData = try JSONDecoder().decode(ActionsInvocationRecord.self, from: actionsInvocationRecordData)
        if let testReferenceID = actionsInvocationRecordJSONData.actions.first?.actionResult.testsRef.id {
            let testResultsSummaryJSONData = try Bash.runAndCapture(
                "xcrun xcresulttool get",
                "--format",
                "json",
                "--path", testResultBundle,
                "--id", testReferenceID
            )
            
            let coverageData = try testSummaryReportGenerator.createTestResultSummary(from: testResultsSummaryJSONData)
            try coverageData.write(to: outputFolder.appendingPathComponent("testResults").appendingPathExtension("txt"))
        }
        
    }
}
